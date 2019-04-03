#!/bin/bash

# Usage: update-to-head.sh release-0.5

target=$1

# Checkout the target branch.
git checkout "$target"

# Update upstream's master and rebase on top of it.
git fetch upstream master
git rebase upstream/master

# Update openshift's master and take all needed files from there.
git fetch openshift master
git checkout openshift/master openshift OWNERS_ALIASES OWNERS Makefile
make generate-dockerfiles
git add openshift OWNERS_ALIASES OWNERS Makefile
git commit -m "Update openshift specific files."