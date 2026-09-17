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

FROM debian:bookworm-slim AS builder

# Install deps for mimalloc building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        which \
        lsof \
        curl \
        ca-certificates \
        openssl \
        git \
        tar \
        sqlite3 \
        fontconfig \
        libfreetype6 \
        tzdata \
        iproute2 \
        libstdc++6 \
        cmake \
        autoconf && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt /tmp/jprof /tmp/nmt /tmp/pmap /diagnostic

WORKDIR /opt

# We manually compile mimalloc here
COPY scripts/build/mimalloc.sh /opt/mimalloc.sh
RUN chmod +x /opt/mimalloc.sh && /opt/mimalloc.sh

# wanted glibc 2.36, and amazon linux 2023 (which is what regular alpine-jdk images are based on) is STILL 2.34...
# so i'm basing it off of debian and packaging that perra in
FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://apt.corretto.aws/corretto.key -o /etc/apt/keyrings/corretto.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/corretto.asc] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends java-25-amazon-corretto-jdk screen lsof openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 numactl libstdc++6 && \
    useradd -d /home/container -m container && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/java && ln -sfn /usr/lib/jvm/java-25-amazon-corretto /opt/java/openjdk

ENV JAVA_HOME=/opt/java/openjdk \
    PATH=/opt/java/openjdk/bin:$PATH

USER container
ENV USER=container \
    HOME=/home/container

WORKDIR /home/container/

# Changes: Copy compiled libmimalloc.so file to final image.
COPY --from=builder /usr/local/lib/libmimalloc.so* /usr/local/lib/
COPY scripts/mimalloc.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
