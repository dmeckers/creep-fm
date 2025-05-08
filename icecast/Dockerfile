FROM ubuntu:22.04

LABEL maintainer="Dmitrijs Meckers <gombovombo@gmail.com>"

ENV DEBIAN_FRONTEND "noninteractive"
ARG ICECAST_VERSION=2.4.0-kh16
ARG ICECAST_DOWNLOAD_LINK=https://github.com/karlheyes/icecast-kh/archive/icecast-$ICECAST_VERSION.tar.gz
ARG EXTRACT_CMD="tar xfazv"
ENV SYSCONF_DIR "/etc/icecast"

USER root

RUN useradd icecast

# build-essential - A package that includes essential tools for building software (e.g., GCC, make).
# -qq - No output except for errors.
# -y - Assume yes to all queries and do not prompt.
RUN apt -qq -y update && apt-get -qq -y install build-essential wget curl

# Download and extract Icecast source code
RUN apt -qq -y install libxml2-dev libxslt1-dev libogg-dev libvorbis-dev \
                           libflac-dev libtheora-dev libspeex-dev libopus-dev \
                           libssl-dev libcurl4-openssl-dev

# Download and extract Icecast source code
RUN wget $ICECAST_DOWNLOAD_LINK -O- | $EXTRACT_CMD - && \
    cd "icecast-kh-icecast-$ICECAST_VERSION" && mkdir $SYSCONF_DIR && \
    ./configure --with-curl --with-openssl --prefix=/usr --sysconfdir=$SYSCONF_DIR --localstatedir=/var && \
    make && make install

# Clean up
RUN rm -rvf "icecast-kh-icecast-$IC_VERSION" && rm -rf /var/lib/apt/lists/*
RUN apt autoclean && apt clean && apt autoremove

WORKDIR /home/icecast

COPY --chown=icecast config /home/icecast/config
COPY --chown=icecast docker-entrypoint.sh /home/icecast/

RUN chmod +x /home/icecast/docker-entrypoint.sh
RUN chown icecast:icecast /home/icecast/docker-entrypoint.sh

EXPOSE 8001

USER icecast

ENTRYPOINT [ "icecast", "-c", "/home/icecast/config/icecast.xml"]

