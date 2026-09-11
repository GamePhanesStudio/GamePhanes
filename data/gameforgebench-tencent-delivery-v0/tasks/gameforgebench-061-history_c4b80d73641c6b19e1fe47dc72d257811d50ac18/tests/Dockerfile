FROM eclipse-temurin:25-jdk-noble@sha256:534968c051301957beae735e7ba1db54d99ddecf08746d3b9d4f318cc132dbc3
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip curl python3-yaml nodejs \
    && pip install --break-system-packages --no-cache-dir uv \
    && uv pip install --system --break-system-packages --no-cache pytest==9.1.1 pytest-json-ctrf==0.5.2 \
    && mkdir -p /opt/paper \
    && curl -fsSL --retry 5 -o /opt/paper/paper.jar \
        https://fill-data.papermc.io/v1/objects/cabed3ae77cf55deba7c7d8722bc9cfd5e991201c211665f9265616d9fe5c77b/paper-1.20.4-499.jar \
    && rm -rf /var/lib/apt/lists/*
COPY . /tests/
