#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${1:-/tmp/jemalloc}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d jemalloc ]; then
    echo "Cloning jemalloc"
    git clone https://github.com/facebook/jemalloc.git
fi

cd jemalloc

echo "Running autogen"
./autogen.sh --enable-prof

echo "Building jemalloc"
make dist
make
make install

echo "jemalloc installed"