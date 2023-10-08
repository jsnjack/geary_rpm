FROM fedora:38
# Sync distro name with build.sh

RUN dnf install rpm-build copr-cli -y

COPY build/geary.spec /root/rpmbuild/SPECS/geary.spec
