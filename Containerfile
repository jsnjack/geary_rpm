FROM fedora:40

RUN dnf install rpm-build copr-cli jq -y

COPY build/geary.spec /root/rpmbuild/SPECS/geary.spec
