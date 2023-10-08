#!/bin/bash

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
    rpmbuild -ba /root/rpmbuild/SPECS/geary.spec
podman cp geary-builder:/root/rpmbuild/RPMS/x86_64/geary-${VERSION}-1.fc38.x86_64.rpm build/
podman stop --ignore geary-builder
podman rm -f --ignore geary-builder
