FROM fedora:38
# Sync distro name with build.sh

RUN dnf install rpm-build dnf-plugins-core git -y

COPY build/geary.spec /root/rpmbuild/SPECS/geary.spec

RUN dnf builddep /root/rpmbuild/SPECS/geary.spec -y
