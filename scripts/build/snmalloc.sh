#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${1:-/tmp/snmalloc}"
# Latest release unless overridden, main is snmalloc's development branch
SNMALLOC_REF="${SNMALLOC_REF:-$(git ls-remote --tags --refs https://github.com/microsoft/snmalloc.git | grep -oE 'refs/tags/[0-9]+\.[0-9]+\.[0-9]+$' | sed 's#refs/tags/##' | sort -V | tail -n1)}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d snmalloc ]; then
    echo "Cloning snmalloc $SNMALLOC_REF"
    git clone --depth 1 --branch "$SNMALLOC_REF" https://github.com/microsoft/snmalloc.git
fi

cd snmalloc
mkdir -p build
cd build

echo "Building snmalloc"
# snmalloc recommends clang, gcc emits libatomic calls for its 128-bit atomics.
# SNMALLOC_OPTIMISE_FOR_CURRENT_MACHINE stays off so the library isn't built for the CI runner's CPU (-march=native).
CC=clang CXX=clang++ cmake -G Ninja ../ \
    -DCMAKE_BUILD_TYPE=Release \
    -DSNMALLOC_BUILD_TESTING=OFF \
    -DSNMALLOC_STATIC_LIBRARY=OFF \
    -DSNMALLOC_OPTIMISE_FOR_CURRENT_MACHINE=OFF
ninja
ninja install

echo "snmalloc installed"
