# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-rdesktop:ubuntunoble

ARG DEBIAN_FRONTEND=noninteractive
ARG CLIENT_VERSION=36.0.0
ARG CLIENT_URL=https://down.115.com/client/115pc/lin/115br_v36.0.0.deb

LABEL org.opencontainers.image.title="docker-115" \
      org.opencontainers.image.description="115 desktop client in a LinuxServer rdesktop container" \
      org.opencontainers.image.version="${CLIENT_VERSION}"

RUN \
  echo "**** install 115 client runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    libasound2t64 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxkbcommon0 \
    libxshmfence1 \
    wget \
    xdg-utils && \
  echo "**** install 115 client ${CLIENT_VERSION} ****" && \
  curl -fsSL "${CLIENT_URL}" -o /tmp/115br.deb && \
  apt-get install -y --no-install-recommends /tmp/115br.deb && \
  chmod +x /usr/local/115Browser/115.sh /usr/local/115Browser/115Browser && \
  echo "**** cleanup ****" && \
  rm -f /tmp/115br.deb && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

COPY root/ /
