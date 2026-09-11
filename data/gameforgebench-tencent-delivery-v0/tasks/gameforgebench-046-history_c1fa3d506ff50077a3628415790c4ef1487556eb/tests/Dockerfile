FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends nodejs \
    && pip install --no-cache-dir uv \
    && uv pip install --system --break-system-packages --no-cache pytest==9.1.1 pytest-json-ctrf==0.5.2 \
    && rm -rf /var/lib/apt/lists/*
COPY . /tests/
