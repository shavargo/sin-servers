# Stock SiN Multiplayer dedicated (Windows sin.exe) via Wine — same pattern as kingpin-servers Dockerfile.bots.
# Game data (base/*.sin) provided at runtime via /data/base volume.
FROM i386/debian:bookworm-slim

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		wine wine32 xvfb xauth \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /sin

# Runtime binaries are injected at image build from context (optional) or mounted at /data.
# Coolify/PoC: mount full Windows Multiplayer tree at /data (sin.exe + base/).

COPY configs/base/server.cfg /sin/server.cfg.template
COPY scripts/entrypoint.sh /sin/entrypoint.sh
RUN chmod +x /sin/entrypoint.sh \
	&& mkdir -p /sin/game \
	&& export WINEPREFIX=/sin/.wine WINEARCH=win32 \
	&& xvfb-run -a wineboot --init \
	&& wineserver -w \
	&& chmod -R a+rwX /sin

ENV SIN_PORT=22451 \
	SIN_HOSTNAME="Shavargos SiN DM" \
	SIN_MAXCLIENTS=16 \
	SIN_MAP=oilrigdm \
	WINEPREFIX=/sin/.wine \
	WINEARCH=win32 \
	WINEDEBUG=-all \
	DISPLAY=:99

EXPOSE 22451/udp 22451/tcp
ENTRYPOINT ["/sin/entrypoint.sh"]
