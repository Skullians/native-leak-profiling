#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM alpine:latest AS builder

# Install deps for mimalloc building
RUN apk add --no-cache \
        build-base \
        which \
        lsof \
        curl \
        ca-certificates \
        openssl \
        git \
        tar \
        sqlite \
        fontconfig \
        freetype \
        tzdata \
        iproute2 \
        libstdc++ \
        bash \
        cmake \
        autoconf

RUN mkdir -p /opt /tmp/jprof /tmp/nmt /tmp/pmap /diagnostic

WORKDIR /opt

# We manually compile mimalloc here
COPY scripts/build/mimalloc.sh /opt/mimalloc.sh
RUN chmod +x /opt/mimalloc.sh && /opt/mimalloc.sh

FROM --platform=$TARGETOS/$TARGETARCH amazoncorretto:21-alpine-jdk

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN apk add --no-cache bash shadow screen lsof curl ca-certificates openssl git tar sqlite fontconfig freetype tzdata iproute2 libstdc++ && \
    useradd -d /home/container -m container

USER container
ENV USER=container \
    HOME=/home/container

WORKDIR /home/container/

# Changes: Copy compiled libmimalloc.so file to final image.
COPY --from=builder /usr/local/lib/libmimalloc.so /usr/local/lib/libmimalloc.so
COPY scripts/mimalloc.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
