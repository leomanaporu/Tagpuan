# silent_worker.py
"""Background worker that runs silently after user consent.

- Verifies the presence of the ``.authorized`` flag file; exits if missing.
- Periodically (every 30 s) performs a remote HTTP GET request to a configurable endpoint to verify connectivity.
- Logs timestamped output and any errors to ``worker_log.txt``.
- Uses platform‑specific subprocess creation flags to suppress console windows on Windows (for any future subprocess calls).
"""
import os
import sys
import subprocess
import pathlib
import time
import datetime
import platform
import logging
import urllib.request

# Base directory (same as the consent handler).
BASE_DIR = pathlib.Path(__file__).resolve().parent
AUTH_FILE = BASE_DIR / ".authorized"
LOG_FILE = BASE_DIR / "worker_log.txt"

# Configure a simple file logger – no console output.
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s: %(message)s",
    handlers=[logging.FileHandler(LOG_FILE, encoding="utf-8")],
)

def check_authorization():
    """Exit immediately if the authorization marker is missing."""
    if not AUTH_FILE.is_file():
        logging.error("Authorization file missing. Exiting worker.")
        sys.exit(1)

def run_connectivity_check():
    """Perform a remote HTTP GET request to a configurable endpoint.
    Returns a tuple of (status_code, response_text)."""
    endpoint = os.getenv('CONNECTIVITY_URL', 'https://example.com/health')
    try:
        with urllib.request.urlopen(endpoint, timeout=15) as response:
            status = response.getcode()
            body = response.read().decode('utf-8', errors='replace')
            return status, body
    except Exception as e:
        logging.exception('Failed to perform connectivity check')
        return None, str(e)

def main():
    # Ensure we have consent before entering the loop.
    check_authorization()
    logging.info("Silent worker started.")
    while True:
        # Re‑check auth each iteration – allows rapid shutdown if file removed.
        if not AUTH_FILE.is_file():
            logging.info("Authorization file removed – terminating worker.")
            break
        status, body = run_connectivity_check()
        timestamp = datetime.datetime.utcnow().isoformat() + "Z"
        if status is not None:
            logging.info("[%s] connectivity check status: %s", timestamp, status)
        if body:
            logging.info("[%s] response body:\n%s", timestamp, body)
        # Sleep for 30 seconds.
        time.sleep(30)
    logging.info("Silent worker exiting.")

if __name__ == "__main__":
    main()
