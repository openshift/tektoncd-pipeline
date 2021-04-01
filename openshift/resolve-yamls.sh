#!/usr/bin/env bash
TMP=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMP}; }
trap clean EXIT

# Take all yamls in $dir and generate a all in one yaml file with resolved registry image/tag
function resolve_resources() {
  local dir=$1
  local resolved_file_name=$2
  local ignores=$3
  local registry_prefix=$4
  local image_tag=${5}

  # This would get only one set of truth from the Makefile for the image lists
  #
  # % grep "^CORE_IMAGES" Makefile
  # CORE_IMAGES=./cmd/controller ./cmd/entrypoint ./cmd/kubeconfigwriter ./cmd/nop ./cmd/webhook ./cmd/imagedigestexporter
  # CORE_IMAGES_WITH_GIT=./cmd/creds-init ./cmd/git-init
  # to:
  #  % grep '^CORE_IMAGES' Makefile|sed -e 's/.*=//' -e 's,./cmd/,,g'|tr -d '\n'|sed -e 's/ /|/g' -e 's/^/(/' -e 's/$/)\n/'
  # (controller|entrypoint|kubeconfigwriter|nop|webhook|imagedigestexportercreds-init|git-init)
  local image_regexp=$(grep '^CORE_IMAGES' $(git rev-parse --show-toplevel)/Makefile| \
                           sed -e 's/.*=//' -e 's,./cmd/,,g'|tr '\n' ' '| \
                           sed -e 's/ /|/g' -e 's/^/(/' -e 's/|$/)\n/')

  >$resolved_file_name
  for yaml in $(find $dir -name "*.yaml" | grep -vE $ignores | sort); do
    echo "---" >>$resolved_file_name
    if [[ -n ${image_tag} ]];then
        # This is a release format the output would look like this :
        # quay.io/openshift-pipeline/tektoncd-pipeline-bash:$image_tag
        #
        # NOTE(chmou): We are using our owns stuff for external images :
        #
        # tianon/true@sha* => openshift/ci-operator/tekton-images/nop/Dockerfile
        # gcr.io/distroless/base@sha* => registry.access.redhat.com/ubi8/ubi-minimal:latest \
        sed -e "s,ko://,,g"  -e "s%tianon/true.*\(\"\)%${registry_prefix}-nop:${image_tag}\1%" \
            -e "s%gcr.io/distroless/base.*\(\"\)%registry.access.redhat.com/ubi8/ubi-minimal:latest\1%" \
            -e "s%\(.* image:\)\(github.com\)\(.*\/\)\(.*\)%\1 ${registry_prefix}-\4:${image_tag}%" $yaml \
            -r -e "s,github.com/tektoncd/pipeline/cmd/${image_regexp},${registry_prefix}-\1:${image_tag},g" \
            > ${TMP}
     else
        # This is CI which get built directly to the user registry namespace i.e: $OPENSHIFT_BUILD_NAMESPACE
        # The output would look like this :
        # internal-registry:5000/usernamespace:tektoncd-pipeline-bash
        #
        # note: test image are images only used for testing not for releases
        #
        # NOTE(chmou): We are using our owns stuff for external images :
        #
        # tianon/true@sha* => openshift/ci-operator/tekton-images/nop/Dockerfile
        # gcr.io/distroless/base@sha* => registry.access.redhat.com/ubi8/ubi-minimal:latest \
         sed -e "s,ko://,,g" -e "s%tinaon/true.*\(\"\)%${registry_prefix}:tektoncd-pipeline-nop\1%" \
             -e "s%gcr.io/distroless/base.*\(\"\)%registry.access.redhat.com/ubi8/ubi-minimal:latest\1%" \
             -e 's%\(.* image:\)\(github.com\)\(.*\/\)\(test\/\)\(.*\)%\1\2 \3\4test-\5%' $yaml \
             -e "s%\(.* image:\)\(github.com\)\(.*\/\)\(.*\)%\1 ""$registry_prefix"'\:tektoncd-pipeline-\4%'  \
             -re "s,github.com/tektoncd/pipeline/cmd/${image_regexp},${registry_prefix}:tektoncd-pipeline-\1,g" \
             > ${TMP}
    fi

	# Remove runAsUser: id, openshift takes care of randoming them and we dont need a fixed uid for that 
	sed -i '/runAsUser: [0-9]*/d' ${TMP}

    # Adding the labels: openshift.io/cluster-monitoring on Namespace to add the cluster-monitoring
    # See: https://docs.openshift.com/container-platform/4.1/logging/efk-logging-deploying.html
    grep -qzP "kind: Namespace\nmetadata:\n\ \ name:\ tekton-pipelines" ${TMP} && sed -i '/^\ \ labels:/a \ \ \ \ openshift.io/cluster-monitoring:\ \"true\"' ${TMP}

    cat ${TMP} >> $resolved_file_name

    # Fix to ill formated images
    # dynamically get the Build image reference on each pr's before running yaml tests
    # Eg: gcr.io/tekton-releases/registry.ci.openshift.org/ci-op-qy1fnwv7/stable:tektoncd-pipeline-git-init:v0.11.3 --> registry.ci.openshift.org/ci-op-qy1fnwv7/stable:tektoncd-pipeline-git-init
    sed -i -r -e "s,gcr.io/tekton-releases/${registry_prefix}:tektoncd-pipeline-${image_regexp}(.*),${registry_prefix}:tektoncd-pipeline-\1,g" $resolved_file_name

    echo >>$resolved_file_name
  done
}

function generate_pipeline_resources() {
    local output_file=$1
    local image_prefix=$2
    local image_tag=$3

    resolve_resources config/ $output_file noignore $image_prefix $image_tag

    # Appends addon configs such as prometheus monitoring config
    for yaml in $(find openshift/addons/ -name "*.yaml" | sort); do
      echo "---" >> $output_file
      cat ${yaml} >> $output_file
    done
}
