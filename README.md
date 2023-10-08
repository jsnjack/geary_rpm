geary rpm builder
======

This repository contains a script to build a rpm package for geary. It is based
on the spec file from the [official fedora package](https://src.fedoraproject.org/rpms/geary).

The script runs every week to provide a user with the latest geary version. The
version number has the following format `<main_version>.<numbr_of_commits>~<commit_id>`-1.

## Maintenance
- When a new major version is released, update the value of `MAJOR_VERSION` in `build.sh`
- Every 180 days COPR credentials need to be refreshed on [COPR API page](https://copr.fedorainfracloud.org/api/). This also needs to be reflected in [github repository settings](https://github.com/jsnjack/geary_rpm/settings/secrets/actions)
