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

FROM ghcr.io/graalvm/jdk:ol8-java11 AS builder

# Install deps for mimalloc building
RUN microdnf install -y epel-release && \
    microdnf update && \
    microdnf install -y gcc gcc-c++ make git autoconf tar cmake

RUN mkdir -p /opt /tmp/jprof /tmp/nmt /tmp/pmap /diagnostic

WORKDIR /opt

# We manually compile mimalloc here
COPY scripts/build/mimalloc.sh /opt/mimalloc.sh
RUN chmod +x /opt/mimalloc.sh && /opt/mimalloc.sh

# Adapted from https://github.com/pterodactyl/yolks/blob/master/java/11/Dockerfile
FROM --platform=$TARGETOS/$TARGETARCH  ghcr.io/graalvm/jdk:ol8-java11

LABEL author="Softwarenoob" maintainer="admin@softwarenoob.com"
LABEL org.opencontainers.image.source="https://github.com/Software-Noob/pterodactyl-images"
LABEL org.opencontainers.image.licenses="MIT"

RUN microdnf install -y epel-release && \
    microdnf update && \
    microdnf install -y curl ca-certificates openssl git tar sqlite fontconfig tzdata iproute gcc gcc-c++ freetype libstdc++ lsof glibc glibc-locale-source glibc-langpack-en && \
    microdnf clean all && \
    adduser --home-dir /home/container container

USER container
ENV USER=container \
    HOME=/home/container

WORKDIR /home/container/

# Changes: Copy compiled libmimalloc.so file to final image.
COPY --from=builder /usr/local/lib64/libmimalloc.so /usr/local/lib/libmimalloc.so
COPY scripts/mimalloc.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
