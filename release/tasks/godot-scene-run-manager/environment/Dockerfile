FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ARG GODOT_VERSION=4.6.1
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip libfontconfig1 \
    && GODOT_ARCH="$(if [ "$TARGETARCH" = amd64 ]; then echo x86_64; else echo arm64; fi)" \
    && curl -fsSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.${GODOT_ARCH}.zip" \
    && unzip -q /tmp/godot.zip -d /opt/godot \
    && mv /opt/godot/Godot_v${GODOT_VERSION}-stable_linux.${GODOT_ARCH} /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm -rf /tmp/godot.zip /opt/godot

WORKDIR /app

COPY Main.tscn /app/Main.tscn
COPY project.godot /app/project.godot
COPY scripts/ /app/scripts/
