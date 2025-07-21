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

# Adapted from https://github.com/pterodactyl/yolks/blob/master/java/11/Dockerfile
FROM --platform=$TARGETOS/$TARGETARCH  ghcr.io/graalvm/jdk:ol8-java11

LABEL author="Softwarenoob" maintainer="admin@softwarenoob.com"
LABEL org.opencontainers.image.source="https://github.com/Software-Noob/pterodactyl-images"
LABEL org.opencontainers.image.licenses="MIT"

# Changes made here:
# - Added ljemalloc-devel and graphviz, to provide access to the jeprof command (graphviz is a dependency of jeprof)
# We install the EPEL repository to have access to jeprof.
RUN microdnf install -y epel-release && \
    microdnf update && \
    microdnf install -y curl ca-certificates openssl git tar sqlite fontconfig tzdata iproute gcc gcc-c++ freetype libstdc++ lsof glibc-locale-source glibc-langpack-en && \
    microdnf clean all && \
    adduser --home-dir /home/container container

## download and chmod jemalloc (improves download times)
RUN curl -o /usr/local/lib/libmimalloc.so https://ci.terrabytedev.com/job/mimalloc/lastSuccessfulBuild/artifact/build/libmimalloc.so && \
    chmod 644 /usr/local/lib/libmimalloc.so

USER container
ENV USER=container \
    HOME=/home/container

WORKDIR /home/container/

COPY ./../../scripts/mimalloc/entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
