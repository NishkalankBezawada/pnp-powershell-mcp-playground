---
theme: default
layout: default
---

# Pre-flight checks.

`Using the PnP PowerShell MCP server, run a pre-flight check in three steps. Report back after each step.\n\nSTEP 1. Check the environment: is pwsh available, is the PnP.PowerShell module installed and current enough, is this session connected, and if so as which account and URL?\n\nSTEP 2. If the session is not connected, prove that it can connect. Connect to the tenant admin site, then run Get-PnPWeb and show me the Url and Title that come back. That is a real round trip to the service rather than a local state check.\n\nSTEP 3. Now disconnect again so the next demo starts from a clean slate. Run Disconnect-PnPOnline, then check the session status once more and confirm it reports not connected. Leaving it disconnected is intentional, so do not reconnect. Note Connection parameters are in Create-lists-demo/environment/.env file.`