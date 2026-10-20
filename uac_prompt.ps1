<#
.SYNOPSIS
    Standalone Windows UAC-Style Prompt (Non-Admin Terminal Launcher)
.DESCRIPTION
    Presents an authentic native Windows User Account Control (UAC) dialog
    outside the browser. When confirmed, it launches a standard (non-admin)
    PowerShell terminal with dark web / horror telemetry integration.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# Play authentic Windows UAC exclamation audio prompt
try {
    [System.Media.SystemSounds]::Exclamation.Play()
} catch {}

# Create Main UAC Dialog Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "User Account Control"
$form.Size = New-Object System.Drawing.Size(500, 360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Top UAC Title & Shield Bar
$topBanner = New-Object System.Windows.Forms.Panel
$topBanner.Size = New-Object System.Drawing.Size(500, 50)
$topBanner.Location = New-Object System.Drawing.Point(0, 0)
$topBanner.BackColor = [System.Drawing.Color]::FromArgb(235, 137, 24) # Amber / Yellow for Unknown Publisher

# Shield / Warning Symbol
$shieldLabel = New-Object System.Windows.Forms.Label
$shieldLabel.Text = [char]0x26A0 # Warning triangle
$shieldLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$shieldLabel.ForeColor = [System.Drawing.Color]::White
$shieldLabel.Size = New-Object System.Drawing.Size(44, 44)
$shieldLabel.Location = New-Object System.Drawing.Point(14, 5)
$topBanner.Controls.Add($shieldLabel)

# Title Text in Banner
$bannerTitle = New-Object System.Windows.Forms.Label
$bannerTitle.Text = "User Account Control"
$bannerTitle.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$bannerTitle.ForeColor = [System.Drawing.Color]::White
$bannerTitle.Size = New-Object System.Drawing.Size(400, 30)
$bannerTitle.Location = New-Object System.Drawing.Point(58, 12)
$topBanner.Controls.Add($bannerTitle)
$form.Controls.Add($topBanner)

# Question Prompt
$questionLabel = New-Object System.Windows.Forms.Label
$questionLabel.Text = "Do you want to allow this app from an unknown publisher to make changes to your device?"
$questionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$questionLabel.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$questionLabel.Size = New-Object System.Drawing.Size(450, 48)
$questionLabel.Location = New-Object System.Drawing.Point(24, 62)
$form.Controls.Add($questionLabel)

# App Details Container
$detailsBox = New-Object System.Windows.Forms.Panel
$detailsBox.Size = New-Object System.Drawing.Size(450, 95)
$detailsBox.Location = New-Object System.Drawing.Point(24, 115)
$detailsBox.BackColor = [System.Drawing.Color]::White
$detailsBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

# App Name
$appNameLabel = New-Object System.Windows.Forms.Label
$appNameLabel.Text = "Darknet Isolation Terminal (Node 0x7F)"
$appNameLabel.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
$appNameLabel.ForeColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$appNameLabel.Location = New-Object System.Drawing.Point(12, 10)
$appNameLabel.Size = New-Object System.Drawing.Size(420, 22)
$detailsBox.Controls.Add($appNameLabel)

# Publisher
$pubLabel = New-Object System.Windows.Forms.Label
$pubLabel.Text = "Publisher: Unknown / Untracked Actor"
$pubLabel.ForeColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
$pubLabel.Location = New-Object System.Drawing.Point(12, 34)
$pubLabel.Size = New-Object System.Drawing.Size(420, 20)
$detailsBox.Controls.Add($pubLabel)

# File origin
$originLabel = New-Object System.Windows.Forms.Label
$originLabel.Text = "File origin: Hard drive on this computer (Non-Admin Terminal)"
$originLabel.ForeColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
$originLabel.Location = New-Object System.Drawing.Point(12, 58)
$originLabel.Size = New-Object System.Drawing.Size(420, 20)
$detailsBox.Controls.Add($originLabel)

$form.Controls.Add($detailsBox)

# "Show more details" Toggle
$moreDetailsLink = New-Object System.Windows.Forms.LinkLabel
$moreDetailsLink.Text = "Show more details"
$moreDetailsLink.Location = New-Object System.Drawing.Point(24, 218)
$moreDetailsLink.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($moreDetailsLink)

# Expanded Details Box (Initially Hidden)
$extendedBox = New-Object System.Windows.Forms.TextBox
$extendedBox.Multiline = $true
$extendedBox.ReadOnly = $true
$extendedBox.ScrollBars = "Vertical"
$extendedBox.BackColor = [System.Drawing.Color]::FromArgb(248, 248, 248)
$extendedBox.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$extendedBox.Text = "Target Executable: powershell.exe`r`nPrivilege Mode: Standard User (Non-Elevated / Non-Admin)`r`nLocation: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`r`nNetwork Status: Intercept Relay Node Active"
$extendedBox.Location = New-Object System.Drawing.Point(24, 242)
$extendedBox.Size = New-Object System.Drawing.Size(450, 70)
$extendedBox.Visible = $false
$form.Controls.Add($extendedBox)

$detailsExpanded = $false
$moreDetailsLink.Add_Click({
    if (-not $script:detailsExpanded) {
        $form.Size = New-Object System.Drawing.Size(500, 440)
        $extendedBox.Visible = $true
        $moreDetailsLink.Text = "Hide details"
        $buttonPanel.Location = New-Object System.Drawing.Point(0, 330)
        $script:detailsExpanded = $true
    } else {
        $extendedBox.Visible = $false
        $form.Size = New-Object System.Drawing.Size(500, 360)
        $moreDetailsLink.Text = "Show more details"
        $buttonPanel.Location = New-Object System.Drawing.Point(0, 255)
        $script:detailsExpanded = $false
    }
})

# Bottom Button Panel
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Size = New-Object System.Drawing.Size(500, 70)
$buttonPanel.Location = New-Object System.Drawing.Point(0, 255)
$buttonPanel.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)

# "Yes" Button (Launches Non-Admin Terminal)
$btnYes = New-Object System.Windows.Forms.Button
$btnYes.Text = "Yes"
$btnYes.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
$btnYes.Size = New-Object System.Drawing.Size(100, 32)
$btnYes.Location = New-Object System.Drawing.Point(260, 18)
$btnYes.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$btnYes.DialogResult = [System.Windows.Forms.DialogResult]::Yes

# "No" Button
$btnNo = New-Object System.Windows.Forms.Button
$btnNo.Text = "No"
$btnNo.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
$btnNo.Size = New-Object System.Drawing.Size(100, 32)
$btnNo.Location = New-Object System.Drawing.Point(372, 18)
$btnNo.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$btnNo.DialogResult = [System.Windows.Forms.DialogResult]::No

$buttonPanel.Controls.Add($btnYes)
$buttonPanel.Controls.Add($btnNo)
$form.Controls.Add($buttonPanel)

# Form defaults
$form.AcceptButton = $btnYes
$form.CancelButton = $btnNo

# Show the UAC dialog
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    # Launch standard Non-Admin PowerShell Terminal
    $themePayload = @'
Clear-Host
$host.UI.RawUI.WindowTitle = "[!] UNTRACKED ONION TERMINAL // NODE 0x7F [NON-ADMIN]"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"

Write-Host "==========================================================================" -ForegroundColor Red
Write-Host "  [!] LEVEL-7 DARKNET ISOLATION TERMINAL // NODE 0x7F" -ForegroundColor Red
Write-Host "  [!] MODE: STANDARD USER (NON-ADMINISTRATIVE EXECUTION)" -ForegroundColor Yellow
Write-Host "  [!] CONNECTION: UNENCRYPTED PROXY RELAY (ACTIVE)" -ForegroundColor DarkRed
Write-Host "==========================================================================" -ForegroundColor Red
Write-Host ""
Write-Host "  * Host Name   : $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "  * Current User: $env:USERNAME (Non-Elevated Session)" -ForegroundColor Cyan
Write-Host "  * Local IP    : $((Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Ethernet*','Wi-Fi*' -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [!] SYSTEM WARNING: DO NOT DISCONNECT POWER OR TERMINATE RECONNAISSANCE." -ForegroundColor DarkYellow
Write-Host "  [!] You have full non-admin terminal access. Run any command below." -ForegroundColor White
Write-Host ""
'@

    # Explicitly spawn non-admin powershell process without elevation
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-NoExit", "-Command", $themePayload
} else {
    Write-Host "UAC Prompt declined by user."
}

$form.Dispose()

