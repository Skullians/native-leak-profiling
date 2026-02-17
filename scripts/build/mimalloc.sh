#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${1:-/tmp/mimalloc}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d mimalloc ]; then
    echo "Cloning mimalloc"
    git clone https://github.com/microsoft/mimalloc
fi

cd mimalloc
mkdir -p build
cd build

echo "Building mimalloc"
cmake -DMI_BUILD_TESTS=OFF ../
make install

echo "mimalloc installed"