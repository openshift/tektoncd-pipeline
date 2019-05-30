#!/usr/bin/env bash

source $(dirname $0)/resolve.sh

release=$1
output_file="openshift/release/tektoncd-pipeline-${release}.yaml"

if [ $release = "ci" ]; then
    image_prefix="image-registry.openshift-image-registry.svc:5000/tektoncd-pipeline/tektoncd-pipeline-"
    tag=""
else
    image_prefix="quay.io/openshift-pipeline/tektoncd-pipeline-"
    tag=$release
fi

resolve_resources config/ $output_file $image_prefix $tag
