FROM --platform=linux/amd64 python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip libfontconfig1 \
    && pip install --no-cache-dir uv \
    && uv pip install --system --break-system-packages --no-cache pytest==9.1.1 pytest-json-ctrf==0.5.2 \
    && GODOT_ARCH=x86_64 \
    && curl -fsSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/4.6.1-stable/Godot_v4.6.1-stable_linux.${GODOT_ARCH}.zip" \
    && unzip -q /tmp/godot.zip -d /opt/godot \
    && mv "/opt/godot/Godot_v4.6.1-stable_linux.${GODOT_ARCH}" /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm -rf /tmp/godot.zip /opt/godot /var/lib/apt/lists/*
COPY . /tests/
