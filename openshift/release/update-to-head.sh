#!/usr/bin/env bash

# Synchs the release-next branch to master and then triggers CI
# Usage: update-to-head.sh

set -e
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
[[ ${REPO_NAME} != tektoncd-* ]] && REPO_NAME=tektoncd-${REPO_NAME}
TODAY=`date "+%Y%m%d"`
OPENSHIFT_REMOTE=${OPENSHIFT_REMOTE:-openshift}

# Reset release-next to upstream/main.
git fetch upstream main
git checkout upstream/main --no-track -B release-next

# Update openshift's master and take all needed files from there.
git fetch ${OPENSHIFT_REMOTE} master
git checkout FETCH_HEAD openshift Makefile OWNERS_ALIASES OWNERS
make generate-dockerfiles

git add openshift OWNERS_ALIASES OWNERS Makefile
git commit -m ":open_file_folder: Update openshift specific files."

if [[ -d openshift/patches ]];then
    for f in openshift/patches/*.patch;do
        [[ -f ${f} ]] || continue
        git am ${f}
    done
fi

# Caution: Need to be applied after the patches
#
# Replace docker.io images with a mirror which doesn't get rate limited.
# prefer to use ecr since closest to our install but sometime gcr.io is better,
# for example on busybox the ecr image (public.ecr.aws/runecast/busybox)
# doesn't have latest tags while the gcr one does.
find . -type f -name '*.go' -o -name '*.yaml' | \
    xargs -P6 -L1 -r sed -E -i \
          -e 's,image: ubuntu$,image: public.ecr.aws/ubuntu/ubuntu:latest,' -e 's,"ubuntu","public.ecr.aws/ubuntu/ubuntu",g' \
          -e 's,"busybox","mirror.gcr.io/library/busybox",g' -e 's,image: busybox$,image: mirror.gcr.io/library/busybox,'

git commit -a -m ":robot: Switching image from docker.io to public cloud providers registry"

# set feature-flags to preserve defaults in GA release 1.4.x
# ref: https://github.com/tektoncd/pipeline/pull/3878
sed -i -e 's/\(disable-home-env-overwrite\).*/\1: false/' \
    -e 's/\(disable-working-directory-overwrite\).*/\1: false/' config/config-feature-flags.yaml

git commit -a -m ":robot: Setting feature flags as per Red Hat OpenShift Pipelines defaults"

git push -f ${OPENSHIFT_REMOTE} release-next

# Trigger CI
git checkout release-next -B release-next-ci

./openshift/release/generate-release.sh nightly

date > ci
git add ci openshift/release/tektoncd-pipeline-nightly.yaml
git commit -m ":robot: Triggering CI on branch 'release-next' after synching to upstream/master"

git push -f ${OPENSHIFT_REMOTE} release-next-ci

if hash hub 2>/dev/null; then
   # Test if there is already a sync PR in 
   COUNT=$(hub api -H "Accept: application/vnd.github.v3+json" repos/openshift/${REPO_NAME}/pulls --flat \
    | grep -c ":robot: Triggering CI on branch 'release-next' after synching to upstream/main") || true
   if [ "$COUNT" = "0" ]; then
      hub pull-request --no-edit -l "kind/sync-fork-to-upstream" -b openshift/${REPO_NAME}:release-next -h openshift/${REPO_NAME}:release-next-ci
   fi
else
   echo "hub (https://github.com/github/hub) is not installed, so you'll need to create a PR manually."
fi
