FROM eclipse-temurin:25-jdk-noble@sha256:534968c051301957beae735e7ba1db54d99ddecf08746d3b9d4f318cc132dbc3
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip curl \
    && pip install --break-system-packages --no-cache-dir uv \
    && uv pip install --system --break-system-packages --no-cache pytest==9.1.1 pytest-json-ctrf==0.5.2 \
    && mkdir -p /opt/paper \
    && curl -fsSL --retry 5 -o /opt/paper/paper.jar \
        https://fill-data.papermc.io/v1/objects/b51d49a5f62446b7cfc01e6c29e48e0ce6abd35a783134aace1047b839b178ef/paper-26.1.2-63.jar \
    && (cd /opt/paper && java -Dpaperclip.patchonly=true -jar paper.jar) \
    && rm -rf /var/lib/apt/lists/*
COPY . /tests/
