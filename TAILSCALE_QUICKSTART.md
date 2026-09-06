# ERFAN OXIGEN - Tailscale Quickstart

Goal: one Windows PC acts as the ERFAN OXIGEN server while approved phones can connect from their own internet connections. They do not need to share the same Wi-Fi.

1. Install Tailscale on the server PC: https://tailscale.com/download/windows
2. Install Tailscale on Android phones: https://tailscale.com/download/android
3. Sign in devices to the same Tailscale network.
4. On the server PC run:

```powershell
tailscale ip -4
powershell -ExecutionPolicy Bypass -File .\backend\run_tailscale_server.ps1 -Port 8787
```

5. In ERFAN OXIGEN, open Backend settings and enter:

```text
http://<SERVER-TAILSCALE-IP>:8787
```

Example:

```text
http://100.86.23.10:8787
```

6. Test on the phone. The server must remain powered on and Tailscale connected.

Data safety: the backend only writes to the configured ERFAN OXIGEN data and files directories. Keep backups before moving the server to another PC.
