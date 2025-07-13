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

FROM ghcr.io/graalvm/jdk-community:24-ol8 AS builder

# Install deps for jemalloc building
RUN microdnf install -y epel-release && \
    microdnf update && \
    microdnf install -y gcc gcc-c++ make git autoconf tar

RUN mkdir -p /opt /tmp/jprof /tmp/nmt /tmp/pmap /diagnostic

# We manually compile jemalloc here, as installing through apt-get (libjemalloc2) does not enable the profiling options we need in Jemalloc.
# If you look below, we use the --enable-prof flag in the autogen.sh script to enable profiling.
WORKDIR /opt
RUN git clone https://github.com/jemalloc/jemalloc.git && \
    cd jemalloc && \
    git checkout 5.3.0 && \
    ./autogen.sh --enable-prof && \
    make dist && \
    make && \
    make install

# Adapted from https://github.com/trenutoo/pterodactyl-images/blob/main/java-graalvm/21/Dockerfile
FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/graalvm/jdk-community:21-ol8

LABEL author="Softwarenoob" maintainer="admin@softwarenoob.com"
LABEL org.opencontainers.image.source="https://github.com/Software-Noob/pterodactyl-images"
LABEL org.opencontainers.image.licenses="MIT"

# Changes made here:
# - Added jemalloc-devel and graphviz, to provide access to the jeprof command (graphviz is a dependency of jeprof)
# We install the EPEL repository to have access to jeprof.
RUN microdnf install -y epel-release && \
    microdnf update && \
    microdnf install -y curl jemalloc-devel graphviz ca-certificates openssl git tar sqlite fontconfig tzdata iproute gcc gcc-c++ freetype libstdc++ lsof glibc glibc-locale-source glibc-langpack-en && \
    microdnf clean all && \
    adduser --home-dir /home/container container

USER container
ENV USER=container \
    HOME=/home/container

WORKDIR /home/container/

# Changes: Copy compiled libjemalloc.so file to final image.
COPY --from=builder /usr/local/lib/libjemalloc.so /usr/local/lib/libjemalloc.so
COPY ./../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
