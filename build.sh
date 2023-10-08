#!/bin/bash

# Ensure safe execution
set -euo pipefail

echo "Building the project"
echo "===================="

echo "Cloning the repository..."
rm -rf build
mkdir -p build/rpms
git clone https://gitlab.gnome.org/GNOME/geary.git build/geary
VERSION=44.$(cd build/geary && git rev-list --count HEAD)~$(cd build/geary && git log -1 --format=%h)
echo "Version: $VERSION"

echo "Rendering spec file..."
GEARY_VERSION=${VERSION} envsubst < geary.spec.tpl > build/geary.spec

echo "Building the source..."
mv build/geary build/geary-${VERSION}
cd build && zip -r geary-${VERSION}.zip geary-${VERSION} && cd ..

echo "Building container image..."
cp Containerfile build/Containerfile
podman build -t geary-build-image -f build/Containerfile .

echo "Building rpm..."
podman run \
    --replace \
    --name geary-builder \
    -v $(pwd)/build/geary-${VERSION}.zip:/root/rpmbuild/SOURCES/geary-${VERSION}.zip \
    -e VERSION=${VERSION} \
    localhost/geary-build-image:latest \
    rpmbuild -bs /root/rpmbuild/SPECS/geary.spec
podman cp geary-builder:/root/rpmbuild/SRPMS/geary-${VERSION}-1.fc38.src.rpm build/
podman stop --ignore geary-builder
podman rm -f --ignore geary-builder
