FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git g++ make \
    && pip install --no-cache-dir uv \
    && uv pip install --system --break-system-packages --no-cache pytest==9.1.1 pytest-json-ctrf==0.5.2 \
    && git clone --depth 1 https://github.com/luau-lang/luau.git /tmp/luau \
    && make -C /tmp/luau -j$(nproc) luau \
    && install -m 0755 /tmp/luau/luau /usr/local/bin/luau \
    && rm -rf /tmp/luau /var/lib/apt/lists/*
COPY . /tests/
