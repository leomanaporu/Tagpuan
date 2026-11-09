// server.js - Centralized Multi-Device Command Broker
// ------------------------------------------------------
// This Node.js server uses Express and Socket.io to manage persistent
// WebSocket connections from remote mobile clients and an admin dashboard.
// It maintains an in‑memory registry of connected devices, forwards telemetry
// and admin commands, and broadcasts device list updates to the admin UI.

const express = require('express');
const http = require('http');
const path = require('path');
const socketIo = require('socket.io');
// Optional compression library for binary payloads
const msgpack = require('msgpack-lite');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Serve static assets (admin dashboard, client pages) from this folder
app.use(express.static(path.join(__dirname)));

// In‑memory device registry: deviceID -> { socketId, lastSeen, status, battery }
const deviceRegistry = {};

// Helper to broadcast the current device list to all admin clients
function broadcastDeviceList() {
  const list = Object.entries(deviceRegistry).map(([deviceID, info]) => ({
    deviceID,
    socketId: info.socketId,
    lastSeen: info.lastSeen,
    status: info.status,
    battery: info.battery,
  }));
  io.of('/admin').emit('admin_device_list', list);
}

io.of('/client').on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Expect the client to emit a registration payload containing a persistent deviceID
  socket.on('register_device', (payload) => {
    // Payload may be a MsgPack Buffer or plain JSON
    let data = typeof payload === 'object' && payload.type === 'Buffer' ? msgpack.decode(Buffer.from(payload)) : payload;
    const deviceID = data.deviceID || socket.id; // fallback to socket.id if not provided
    deviceRegistry[deviceID] = {
      socketId: socket.id,
      lastSeen: Date.now(),
      status: 'online',
      battery: data.battery || null,
    };
    console.log(`Device registered: ${deviceID}`);
    broadcastDeviceList();
  });

  socket.on('client_heartbeat', (payload) => {
    let data = typeof payload === 'object' && payload.type === 'Buffer' ? msgpack.decode(Buffer.from(payload)) : payload;
    const deviceID = data.deviceID;
    if (deviceRegistry[deviceID]) {
      deviceRegistry[deviceID].lastSeen = Date.now();
    }
    broadcastDeviceList();
  });

  socket.on('telemetry_update', (payload) => {
    let data = typeof payload === 'object' && payload.type === 'Buffer' ? msgpack.decode(Buffer.from(payload)) : payload;
    const deviceID = data.deviceID;
    if (deviceRegistry[deviceID]) {
      deviceRegistry[deviceID].battery = data.battery;
      deviceRegistry[deviceID].status = data.status;
      deviceRegistry[deviceID].lastSeen = Date.now();
    }
    // Forward telemetry to admin namespace for real‑time display
    io.of('/admin').emit('telemetry_update', { deviceID, telemetry: data });
    broadcastDeviceList();
  });

  socket.on('disconnect', () => {
    // Clean up any registry entries that belong to this socket
    for (const [deviceID, info] of Object.entries(deviceRegistry)) {
      if (info.socketId === socket.id) {
        delete deviceRegistry[deviceID];
        console.log(`Device disconnected: ${deviceID}`);
      }
    }
    broadcastDeviceList();
  });
});

// Admin namespace – dashboards connect here
io.of('/admin').on('connection', (socket) => {
  console.log('Admin dashboard connected:', socket.id);
  // Push current device list on new admin connection
  broadcastDeviceList();

  // Admin requests a status report from a specific device
  socket.on('request_status', ({ deviceID }) => {
    const target = deviceRegistry[deviceID];
    if (target) {
      io.to(target.socketId).emit('admin_request_status', { requestId: Date.now() });
    }
  });

  // Admin requests telemetry logs from a specific device
  socket.on('request_logs', ({ deviceID }) => {
    const target = deviceRegistry[deviceID];
    if (target) {
      io.to(target.socketId).emit('admin_request_logs', { requestId: Date.now() });
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Multi‑Device Command Broker listening on http://localhost:${PORT}`);
});

