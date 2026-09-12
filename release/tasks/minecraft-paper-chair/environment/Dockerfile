FROM forge-cc-open-source:minecraft

WORKDIR /app
RUN apt-get -o Acquire::Retries=5 update \
    && apt-get -o Acquire::Retries=5 install -y --no-install-recommends ca-certificates curl openjdk-17-jdk-headless \
    && mkdir -p /opt/paper \
    && curl -fsSL --retry 5 -o /opt/paper/paper.jar https://fill-data.papermc.io/v1/objects/cabed3ae77cf55deba7c7d8722bc9cfd5e991201c211665f9265616d9fe5c77b/paper-1.20.4-499.jar \
    && echo 'cabed3ae77cf55deba7c7d8722bc9cfd5e991201c211665f9265616d9fe5c77b  /opt/paper/paper.jar' | sha256sum -c - \
    && curl -fsSL --retry 5 -o /opt/paper/paper-api.jar https://repo.papermc.io/repository/maven-public/io/papermc/paper/paper-api/1.20.4-R0.1-SNAPSHOT/paper-api-1.20.4-R0.1-20241030.192207-176.jar \
    && rm -rf /var/lib/apt/lists/*
COPY data/ /app/data/
COPY src/ /app/src/

WORKDIR /app
RUN python -m pip install --no-cache-dir pytest pyyaml
ENTRYPOINT []
CMD ["sleep", "infinity"]
