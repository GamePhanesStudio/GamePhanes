FROM eclipse-temurin:25-jdk-noble@sha256:534968c051301957beae735e7ba1db54d99ddecf08746d3b9d4f318cc132dbc3

WORKDIR /app
RUN apt-get -o Acquire::Retries=5 update \
    && apt-get -o Acquire::Retries=5 install -y --no-install-recommends ca-certificates curl python3 python3-pytest python3-yaml \
    && mkdir -p /opt/paper \
    && curl -fsSL --retry 5 -o /opt/paper/paper.jar https://fill-data.papermc.io/v1/objects/cabed3ae77cf55deba7c7d8722bc9cfd5e991201c211665f9265616d9fe5c77b/paper-1.20.4-499.jar \
    && echo 'cabed3ae77cf55deba7c7d8722bc9cfd5e991201c211665f9265616d9fe5c77b  /opt/paper/paper.jar' | sha256sum -c - \
    && curl -fsSL --retry 5 -o /opt/paper/paper-api.jar https://repo.papermc.io/repository/maven-public/io/papermc/paper/paper-api/1.20.4-R0.1-SNAPSHOT/paper-api-1.20.4-R0.1-20241030.192207-176.jar \
    && rm -rf /var/lib/apt/lists/*
COPY src/ /app/src/

WORKDIR /app
ENTRYPOINT []
CMD ["sleep", "infinity"]
