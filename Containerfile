#################################################
# Build stage
################################################
FROM alpine:3.23 AS builder
RUN apk add --no-cache curl unzip
WORKDIR /build

# Download and extract Hytale Downloader
RUN curl -L -o downloader.zip https://downloader.hytale.com/hytale-downloader.zip \
    && unzip downloader.zip -d downloader \
    && mv ./downloader/hytale-downloader-linux-amd64 hytale-downloader \
    && chmod +x hytale-downloader \
    && rm -rf downloader downloader.zip

COPY entrypoint.py .

#################################################
# Runtime stage
################################################
FROM eclipse-temurin:25-jre-alpine-3.23
RUN apk add --no-cache \
    python3 unzip curl iproute2 ca-certificates \
    tzdata jq libc6-compat libstdc++ gcompat

ENV HYTALE_HOME=/opt/hytale-server
ENV USER=hytale
ENV USER_GID=1001
ENV USER_UID=1001

WORKDIR ${HYTALE_HOME}

# Create user
RUN addgroup -S -g ${USER_GID} ${USER} \
    && adduser -S -D -h ${HYTALE_HOME} -u ${USER_UID} -G ${USER} ${USER} \
    && chown -R ${USER}:${USER} ${HYTALE_HOME}

COPY --from=builder --chown=root:root /build/hytale-downloader /usr/local/bin/hytale-downloader
COPY --from=builder --chown=root:root /build/entrypoint.py /usr/local/bin/entrypoint.py

USER hytale
EXPOSE 5520/udp

ENTRYPOINT [ "/usr/bin/python3", "/usr/local/bin/entrypoint.py" ]
