FROM eclipse-temurin:25-jdk-noble@sha256:534968c051301957beae735e7ba1db54d99ddecf08746d3b9d4f318cc132dbc3
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip curl python3-yaml xz-utils \
    && pip install --break-system-packages --no-cache-dir uv \
    && uv pip install --system --break-system-packages --no-cache pytest==9.1.1 pytest-json-ctrf==0.5.2 \
    && mkdir -p /opt/paper \
    && curl -fsSL --retry 5 -o /opt/paper/paper.jar \
        https://fill-data.papermc.io/v1/objects/b51d49a5f62446b7cfc01e6c29e48e0ce6abd35a783134aace1047b839b178ef/paper-26.1.2-63.jar \
    && (cd /opt/paper && java -Dpaperclip.patchonly=true -jar paper.jar) \
    && ARCH=$(uname -m) \
    && if [ "$ARCH" = "aarch64" ]; then NODE_ARCH=arm64; else NODE_ARCH=x64; fi \
    && curl -fsSL --retry 5 -o /tmp/node.tar.xz \
        "https://nodejs.org/dist/v22.12.0/node-v22.12.0-linux-${NODE_ARCH}.tar.xz" \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --no-same-owner \
    && rm /tmp/node.tar.xz \
    && rm -rf /var/lib/apt/lists/*
COPY client/ /opt/mc-client/
RUN cd /opt/mc-client && npm ci --omit=dev
COPY . /tests/
