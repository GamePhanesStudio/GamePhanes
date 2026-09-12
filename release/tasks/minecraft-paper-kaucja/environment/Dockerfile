FROM node:22-bookworm-slim@sha256:83f487e0a63425e5b4d146fb5e5be574bcbe1b7b843d3ebafdd95eaf7767a7e5 AS client
WORKDIR /opt/mc-client
COPY client/package*.json ./
RUN npm ci --ignore-scripts --omit=dev

FROM eclipse-temurin:25-jdk-noble@sha256:534968c051301957beae735e7ba1db54d99ddecf08746d3b9d4f318cc132dbc3
RUN apt-get update && apt-get install -y --no-install-recommends python3 curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/paper
RUN curl -fLsS --retry 4 -o paper.jar https://fill-data.papermc.io/v1/objects/b51d49a5f62446b7cfc01e6c29e48e0ce6abd35a783134aace1047b839b178ef/paper-26.1.2-63.jar \
    && echo 'b51d49a5f62446b7cfc01e6c29e48e0ce6abd35a783134aace1047b839b178ef  paper.jar' | sha256sum -c - \
    && java -Dpaperclip.patchonly=true -jar paper.jar
WORKDIR /app
COPY --from=client /usr/local/bin/node /usr/local/bin/node
COPY --from=client /opt/mc-client /opt/mc-client
COPY build.sh /app/build.sh
COPY src/ /app/src/
COPY entrypoint.sh /usr/local/bin/gameforgebench-entrypoint
RUN chmod +x /usr/local/bin/gameforgebench-entrypoint
WORKDIR /app
