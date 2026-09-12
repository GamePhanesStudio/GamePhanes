FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates chromium python3 python3-yaml \
    && rm -rf /var/lib/apt/lists/*

COPY rubric.yaml /app/rubric.yaml
COPY index.html /app/index.html
COPY src/ /app/src/

WORKDIR /app
RUN uv pip install --system --no-cache pyyaml
