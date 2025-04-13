FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HABRIDGE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="saarg"

# install packages
RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    libcap \
    nss \
    openjdk8-jre \
    sqlite-libs && \
  echo "**** install ha-bridge ****" && \
  if [ -z ${HABRIDGE_RELEASE+x} ]; then \
    HABRIDGE_RELEASE=$(curl -sL "https://api.github.com/repos/bwssytems/ha-bridge/releases/latest" \
    | jq -r '.tag_name'); \
  fi && \
  mkdir -p \
    /app && \
  curl -o \
    /app/ha-bridge.jar -L \
    "https://github.com/bwssytems/ha-bridge/releases/download/${HABRIDGE_RELEASE}/ha-bridge-${HABRIDGE_RELEASE:1}.jar" && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version

# Grant java the capability to bind to privileged ports
RUN setcap 'cap_net_bind_service=+ep' /usr/lib/jvm/java-1.8-openjdk/bin/java

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80
VOLUME /config
