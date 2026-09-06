# ERFAN OXIGEN - Tailscale server mode

This mode lets approved devices reach the ERFAN OXIGEN backend over Tailscale without requiring all phones to be on the same Wi-Fi and without buying a public server or domain.

## Windows server
1. Install Tailscale from https://tailscale.com/download/windows
2. Sign in to the same Tailscale network used by the approved phones.
3. Confirm the server has a Tailscale IPv4:

```powershell
tailscale ip -4
```

4. Start the backend:

```powershell
powershell -ExecutionPolicy Bypass -File .\backend\run_tailscale_server.ps1 -Port 8787
```

5. On a client device, use the server's Tailscale IPv4, for example:

```text
http://100.x.y.z:8787
```

## Android client
Install Tailscale from Google Play or the official Android download page. Sign in to the same tailnet, then open ERFAN OXIGEN and set the Backend URL to the server's Tailscale IPv4 and port.

Official Android download: https://tailscale.com/download/android
Google Play: https://play.google.com/store/apps/details?id=com.tailscale.ipn

## Important
- The server PC must be powered on and Tailscale must be connected.
- This is private network access; it does not make the backend publicly reachable on the open internet.
- Keep `backend/data` and `backend/files` backed up.
- If you move the server to another PC, install Tailscale there, sign in to the same tailnet, restore the data/files, start the backend, and update the app's Backend URL to the new Tailscale IP.
