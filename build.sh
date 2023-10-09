#!/bin/bash

# Ensure safe execution
set -euo pipefail

MAJOR_VERSION=44

echo "Building the project"
echo "===================="

echo "Cloning the repository..."
rm -rf build
mkdir -p build/rpms
git clone https://gitlab.gnome.org/GNOME/geary.git build/geary
VERSION=${MAJOR_VERSION}.$(cd build/geary && git rev-list --count HEAD)~$(cd build/geary && git log -1 --format=%h)
echo "Version: $VERSION"

echo "Rendering spec file..."
GEARY_VERSION=${VERSION} envsubst < geary.spec.tpl > build/geary.spec

echo "Building the source..."
mv build/geary build/geary-${VERSION}
cd build && zip -r geary-${VERSION}.zip geary-${VERSION} && cd ..

echo "Building container image..."
cp Containerfile build/Containerfile
podman build -t geary-build-image -f build/Containerfile .

echo "Rendering copr auth file..."
COPR_LOGIN=${COPR_LOGIN} COPR_TOKEN=${COPR_TOKEN} envsubst < copr.tpl > build/copr

echo "Building rpm..."
podman run \
    --name geary-builder \
    -d --rm \
    -v $(pwd)/build/copr:/root/.config/copr \
    -v $(pwd)/build/geary-${VERSION}.zip:/root/rpmbuild/SOURCES/geary-${VERSION}.zip \
    localhost/geary-build-image:latest \
    bash -c "tail -f /dev/null"
test $(podman exec geary-builder bash -c "copr-cli list-packages jsnjack/geary --with-latest-build --output-format json | jq .[0].latest_build.source_package.version") = "\"${VERSION}\"" && echo "Package already exists" && exit 0
podman exec geary-builder bash -c "rpmbuild -bs /root/rpmbuild/SPECS/geary.spec"
podman exec geary-builder bash -c "ls /root/rpmbuild/SRPMS/geary-*.src.rpm | xargs -t -I % copr-cli build geary %"
podman kill --signal=SIGKILL geary-builder
