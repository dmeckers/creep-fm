FROM ubuntu:25.04

WORKDIR /home/liquidsoap

LABEL maintainer="Dmitry Mecker <gombovombo@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Install all system dependencies - added more media libraries
RUN apt -qq -y update && apt -qq -y install --no-install-recommends \
    sudo wget curl git ffmpeg pulseaudio python3 python-is-python3 ca-certificates \
    python3-brotli yt-dlp bubblewrap opam build-essential m4 pkg-config \
    unzip rsync libpcre3-dev libffi-dev libcurl4-gnutls-dev \
    libssl-dev libmad0-dev libtag1-dev libmp3lame-dev libvorbis-dev \
    libflac-dev libfaad-dev libsamplerate0-dev \
    lame vorbis-tools flac libmp3lame0 libshine-dev libspeex-dev \
    libopus-dev libtheora-dev libogg-dev libopencore-amrnb-dev \
    && update-ca-certificates -f

# Create liquidsoap user
RUN useradd -s /usr/bin/bash -m liquidsoap \
    && usermod -aG sudo liquidsoap \
    && echo 'liquidsoap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /home/liquidsoap/.opam \
    && chown -R liquidsoap:liquidsoap /home/liquidsoap

# Install Liquidsoap via OPAM
USER liquidsoap
RUN opam init --disable-sandboxing --auto-setup --yes

# Install Liquidsoap with all media codecs
RUN eval $(opam env) && \
    opam install --confirm-level=unsafe-yes --yes \
    lame mad faad fdkaac flac ogg opus speex theora vorbis ffmpeg shine && \
    opam install --assume-depexts --confirm-level=unsafe-yes --yes liquidsoap

# Add OPAM bin to PATH
ENV PATH="/home/liquidsoap/.opam/default/bin:${PATH}"

# Clean up
USER root
RUN rm -rf /var/lib/apt/lists/* \
    && apt clean \
    && apt autoremove

EXPOSE 1234 8002

USER liquidsoap

# Replace this with your actual liquidsoap startup command
CMD ["liquidsoap" , "/etc/liquidsoap/script.liq"]