#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${1:-/tmp/gperftools}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Latest stable gperftools release (release candidates are tagged x.y.90 and up), unless one is given.
GPERFTOOLS_TAG="${GPERFTOOLS_TAG:-$(git ls-remote --tags --refs https://github.com/gperftools/gperftools.git 'gperftools-*' \
    | awk -F/ '{print $3}' | grep -Ev '\.9[0-9]$' | sort -V | tail -n1)}"

if [ ! -d gperftools ]; then
    echo "Cloning gperftools ($GPERFTOOLS_TAG)"
    git clone --depth 1 --branch "$GPERFTOOLS_TAG" https://github.com/gperftools/gperftools.git
fi

cd gperftools

echo "Running autogen"
./autogen.sh

# Only tcmalloc_minimal is needed: no profilers, no debug allocator.
echo "Building tcmalloc"
./configure --enable-minimal --disable-debugalloc
make -j"$(nproc)"
make install

echo "tcmalloc installed"
