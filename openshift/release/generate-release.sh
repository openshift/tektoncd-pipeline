#!/usr/bin/env bash
set -e

source $(dirname $0)/../resolve-yamls.sh

release=$1
output_file="openshift/release/tektoncd-pipeline-${release}.yaml"

if [ $release = "ci" ]; then
    image_prefix="image-registry.openshift-image-registry.svc:5000/tektoncd-pipeline/tektoncd-pipeline-"
else
    image_prefix="quay.io/openshift-pipeline/tektoncd-pipeline"
    tag=$release
fi

generate_pipeline_resources $output_file $image_prefix $tag

# Update value for pipeline.tekton.dev/release label from "devel" to $tag 
if [[ -n ${tag} ]]; then
    sed -i -r "s/\"?devel\"?$/${tag}/g" $output_file
    #"devel" to $tag where version is in args
    sed -i -r "s/\"?devel\",?$/\"${tag}\",/g" $output_file
fi
