# SiN dedicated servers (Wine wrapper only)

This repo is **Docker/Wine scaffolding only** — same idea as Kingpin’s private host mounts.

**Do not commit or publish SiN game files.** `sin.exe`, paks, dlls, and anything from SiN Gold / Multiplayer stay on the host after a legitimate purchase. They are gitignored.

| App | Compose | Port |
|-----|---------|------|
| sin-dm | `docker-compose.dm.yml` | UDP **22451** |

## Host game tree (private)

On the Coolify VPS, copy your purchased **SiN 1 Multiplayer** install to **`/data/sin-private/`**:

- `sin.exe`, `ref_gl.dll`, `ref_soft.dll`, `steam_api.dll`, `steam_appid.txt`
- `base/pak0.sin`, `base/pak1.sin`, `base/gamex86.dll`
- Optional: extra content-only paks under `base/` (never CPAK’s `gamex86.dll`)

Compose bind-mounts that path read-only at `/data` inside the container.

## Coolify (current)

Deployed as a **Docker Compose Empty** service (`sin-dm`) so nothing game-related goes through GitHub:

1. Build image on the host: `docker build -t sin-servers:dm .` (from this repo’s Dockerfile only)
2. Compose uses `image: sin-servers:dm` + `pull_policy: never` + `/data/sin-private:/data:ro`
3. Open host firewall **UDP 22451**

If you later point Coolify at this git repo, still only scaffolding ships — game data remains `/data/sin-private`.

## Client

Join with **SiN 1 Multiplayer** (stock), address `YOUR_IP:22451`.
