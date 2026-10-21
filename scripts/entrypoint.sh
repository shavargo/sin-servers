#!/bin/sh
set -eu

# Expect Steam "SiN 1 Multiplayer" layout at /data:
#   /data/sin.exe, /data/ref_*.dll, /data/base/pak0.sin, gamex86.dll, …
DATA="${SIN_DATA:-/data}"
GAME=/sin/game

if [ ! -f "$DATA/sin.exe" ]; then
	echo "ERROR: missing $DATA/sin.exe (mount SiN 1 Multiplayer root at /data)" >&2
	exit 1
fi

mkdir -p "$GAME/base"
# Sync runtime without clobbering server.cfg we generate
cp -a "$DATA/sin.exe" "$DATA"/*.dll "$DATA"/steam_appid.txt "$GAME/" 2>/dev/null || true
cp -a "$DATA/base/." "$GAME/base/"

cp -f /sin/server.cfg.template "$GAME/base/server.cfg"

PORT="${SIN_PORT:-22451}"
HOST="${SIN_HOSTNAME:-Shavargos SiN DM}"
MAX="${SIN_MAXCLIENTS:-16}"
MAP="${SIN_MAP:-oilrigdm}"

{
	grep -v -E '^(set hostname |set hostport |set maxclients |map )' "$GAME/base/server.cfg" || true
	printf 'set hostname "%s"\n' "$HOST"
	printf 'set hostport %s\n' "$PORT"
	printf 'set maxclients %s\n' "$MAX"
	printf 'map %s\n' "$MAP"
} > "$GAME/base/server.cfg.tmp"
mv "$GAME/base/server.cfg.tmp" "$GAME/base/server.cfg"

export WINEPREFIX="${WINEPREFIX:-/sin/.wine}"
export WINEARCH="${WINEARCH:-win32}"
export WINEDEBUG="${WINEDEBUG:--all}"
export DISPLAY="${DISPLAY:-:99}"

rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
Xvfb :99 -screen 0 640x480x16 -nolisten tcp >/tmp/xvfb.log 2>&1 &
sleep 0.5

cd "$GAME"
exec wine sin.exe +set dedicated 1 +set hostport "$PORT" +set vid_ref soft +set s_initsound 0 +exec server.cfg
