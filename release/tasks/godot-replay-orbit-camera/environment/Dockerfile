# Public, reproducible base: astral uv (python3.12) on Debian bookworm-slim.
# Codex (a supported Harbor agent that can solve this task) needs a real Node,
# ripgrep, and curl at run time. To keep the image reproducible from public
# sources only, we pre-bake them from the official public nodejs.org tarball and
# the Debian packages here instead of relying on codex doing an apt install at
# runtime against fast-moving mirrors.
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
ARG GODOT_VERSION=4.6.1
ARG TARGETARCH
WORKDIR /app

RUN set -eux; apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip \
       libfontconfig1 git ripgrep procps xz-utils \
    && rm -rf /var/lib/apt/lists/*

ARG NODE_VER=22.14.0
RUN set -eux; \
    NODE_ARCH="$(if [ "$TARGETARCH" = amd64 ]; then echo x64; else echo arm64; fi)"; \
    NODE_ROOT="/opt/node-v${NODE_VER}-linux-${NODE_ARCH}"; \
    curl -fsSL -o /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-${NODE_ARCH}.tar.xz"; \
    tar -xJf /tmp/node.tar.xz -C /opt; \
    ln -sf "$NODE_ROOT/bin/node" /usr/local/bin/node; \
    ln -sf "$NODE_ROOT/bin/npm" /usr/local/bin/npm; \
    rm -f /tmp/node.tar.xz

RUN set -eux; \
    GODOT_ARCH="$(if [ "$TARGETARCH" = amd64 ]; then echo x86_64; else echo arm64; fi)"; \
    curl -fsSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.${GODOT_ARCH}.zip"; \
    unzip -q /tmp/godot.zip -d /opt/godot; \
    mv "/opt/godot/Godot_v${GODOT_VERSION}-stable_linux.${GODOT_ARCH}" /usr/local/bin/godot; \
    chmod +x /usr/local/bin/godot; \
    rm -rf /tmp/godot.zip /opt/godot

RUN uv pip install --system pytest pyyaml

# Pre-install aider from the public PyPI (aider.chat ships a pip package; the
# curl installer needs network at trial time). Public, rebuildable. Providing
# `aider` inside the image lets the Harbor `aider` agent skip its runtime curl
# install and go straight to the model.
ARG AIDER_VER=0.86.2
RUN set -eux; \
    python -m pip install --break-system-packages "aider-chat==${AIDER_VER}" || \
    pip install "aider-chat==${AIDER_VER}" || \
    uv pip install --system "aider-chat==${AIDER_VER}"; \
    aider --version

# Pre-install the @openai/codex CLI (public npm) so Harbor's codex agent setup
# short-circuits instead of running apt-get/nvm at trial time.
RUN set -eux; \
    npm install -g "@openai/codex@0.153.4"; \
    CODEX_BIN="$(find /opt/node-*/lib/node_modules/@openai/codex/node_modules/@openai/codex-*/vendor/*/bin/codex 2>/dev/null | head -1)"; \
    ln -sf "$CODEX_BIN" /usr/local/bin/codex; \
    ln -sf "$(find /opt/node-*/lib/node_modules/@openai/codex -maxdepth 2 -name codex.js | head -1)" /usr/local/bin/codex.js 2>/dev/null || true; \
    codex --version

COPY Main.tscn /app/Main.tscn
COPY project.godot /app/project.godot
COPY scripts/ /app/scripts/

WORKDIR /app

# Pre-install opencode-ai (public npm) so Harbor opencode install() short-circuits.
RUN set -eux; \
    npm i -g opencode-ai; \
    OCB="$(find /opt/node-*/lib/node_modules/opencode-ai/node_modules/opencode-*/bin/opencode 2>/dev/null | head -1)"; \
    ln -sf "$OCB" /usr/local/bin/opencode; \
    opencode --version
