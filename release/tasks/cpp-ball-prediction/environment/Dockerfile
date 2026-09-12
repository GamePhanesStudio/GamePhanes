FROM debian:bookworm-slim

RUN apt-get -o Acquire::http::Timeout=30 -o Acquire::Retries=3 update \
    && apt-get install -y --no-install-recommends g++ python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --break-system-packages pytest pyyaml


WORKDIR /app
COPY src /app/src/
