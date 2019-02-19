#!/bin/sh 

source $(dirname $0)/../vendor/github.com/knative/test-infra/scripts/e2e-tests.sh

set -x

readonly SERVING_VERSION=v0.2.2
readonly EVENTING_VERSION=v0.2.1

readonly SERVING_BASE=https://github.com/knative/serving/releases/download/${SERVING_VERSION}
readonly ISTIO_CRD_RELEASE=${SERVING_BASE}/istio-crds.yaml
readonly ISTIO_RELEASE=${SERVING_BASE}/istio.yaml
readonly SERVING_RELEASE=${SERVING_BASE}/release.yaml

readonly EVENTING_RELEASE=https://github.com/knative/eventing/releases/download/${EVENTING_VERSION}/release.yaml

readonly K8S_CLUSTER_OVERRIDE=$(oc config current-context | awk -F'/' '{print $2}')
readonly API_SERVER=$(oc config view --minify | grep server | awk -F'//' '{print $2}' | awk -F':' '{print $1}')
readonly INTERNAL_REGISTRY="docker-registry.default.svc:5000"
readonly USER=$KUBE_SSH_USER #satisfy e2e_flags.go#initializeFlags()
readonly OPENSHIFT_REGISTRY="${OPENSHIFT_REGISTRY:-"registry.svc.ci.openshift.org"}"
readonly SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY:-"~/.ssh/google_compute_engine"}"
readonly INSECURE="${INSECURE:-"false"}"
readonly EVENTING_NAMESPACE=knative-eventing
readonly BUILD_PIPELINE_NAMESPACE=knative-build-pipeline
readonly TEST_NAMESPACE=e2etest
readonly TEST_FUNCTION_NAMESPACE=e2etestfn3


env

function enable_admission_webhooks(){
  header "Enabling admission webhooks"
  add_current_user_to_etc_passwd
  disable_strict_host_checking
  echo "API_SERVER=$API_SERVER"
  echo "KUBE_SSH_USER=$KUBE_SSH_USER"
  chmod 600 ~/.ssh/google_compute_engine
  echo "$API_SERVER ansible_ssh_private_key_file=${SSH_PRIVATE_KEY}" > inventory.ini
  ansible-playbook ${REPO_ROOT_DIR}/openshift/admission-webhooks.yaml -i inventory.ini -u $KUBE_SSH_USER
  rm inventory.ini
}

function add_current_user_to_etc_passwd(){
  if ! whoami &>/dev/null; then
    echo "${USER:-default}:x:$(id -u):$(id -g):Default User:$HOME:/sbin/nologin" >> /etc/passwd
  fi
  cat /etc/passwd
}

function disable_strict_host_checking(){
  cat >> ~/.ssh/config <<EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
}

function install_istio(){
  header "Installing Istio"
  # Grant the necessary privileges to the service accounts Istio will use:
  oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z default -n istio-system
  oc adm policy add-scc-to-user anyuid -z prometheus -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-egressgateway-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-citadel-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-ingressgateway-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-cleanup-old-ca-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-mixer-post-install-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-mixer-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z istio-sidecar-injector-service-account -n istio-system
  oc adm policy add-scc-to-user anyuid -z cluster-local-gateway-service-account -n istio-system
  oc adm policy add-cluster-role-to-user cluster-admin -z istio-galley-service-account -n istio-system
  
  # Deploy the latest Istio release
  oc apply -f $ISTIO_CRD_RELEASE
  oc apply -f $ISTIO_RELEASE

  # Ensure the istio-sidecar-injector pod runs as privileged
  oc get cm istio-sidecar-injector -n istio-system -o yaml | sed -e 's/securityContext:/securityContext:\\n      privileged: true/' | oc replace -f -
  # Monitor the Istio components until all the components are up and running
  wait_until_pods_running istio-system || return 1
  header "Istio Installed successfully"
}

function install_knative_serving(){
  header "Installing Knative Serving"

  # Grant the necessary privileges to the service accounts Knative will use:
  oc adm policy add-scc-to-user anyuid -z build-controller -n knative-build
  oc adm policy add-scc-to-user anyuid -z controller -n knative-serving
  oc adm policy add-scc-to-user anyuid -z autoscaler -n knative-serving
  oc adm policy add-cluster-role-to-user cluster-admin -z build-controller -n knative-build
  oc adm policy add-cluster-role-to-user cluster-admin -z controller -n knative-serving

  curl -L ${SERVING_RELEASE} | sed '/nodePort/d' | oc apply -f -
  
  echo ">>> Setting SSL_CERT_FILE for Knative Serving Controller"
  oc set env -n knative-serving deployment/controller SSL_CERT_FILE=/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt

  echo ">> Patching knative-ingressgateway"
  oc patch hpa -n istio-system knative-ingressgateway --patch '{"spec": {"maxReplicas": 1}}'

  wait_until_pods_running knative-build || return 1
  wait_until_pods_running knative-serving || return 1
  wait_until_service_has_external_ip istio-system knative-ingressgateway || fail_test "Ingress has no external IP"
  header "Knative Installed successfully"
}

function install_knative_eventing(){
  header "Installing Knative Eventing"

  # Create knative-eventing namespace, needed for imagestreams
  oc create namespace $EVENTING_NAMESPACE

  # Grant the necessary privileges to the service accounts Knative will use:
  oc annotate clusterrolebinding.rbac cluster-admin 'rbac.authorization.kubernetes.io/autoupdate=false' --overwrite
  oc annotate clusterrolebinding.rbac cluster-admins 'rbac.authorization.kubernetes.io/autoupdate=false' --overwrite

  oc adm policy add-scc-to-user anyuid -z eventing-controller -n $EVENTING_NAMESPACE
  oc adm policy add-scc-to-user anyuid -z in-memory-channel-dispatcher -n $EVENTING_NAMESPACE
  oc adm policy add-scc-to-user anyuid -z in-memory-channel-controller -n $EVENTING_NAMESPACE

  curl -L ${EVENTING_RELEASE} | sed '/nodePort/d' | oc apply -f -

  oc adm policy add-cluster-role-to-user cluster-admin -z eventing-controller -n $EVENTING_NAMESPACE
  oc adm policy add-cluster-role-to-user cluster-admin -z in-memory-channel-dispatcher -n $EVENTING_NAMESPACE
  oc adm policy add-cluster-role-to-user cluster-admin -z in-memory-channel-controller -n $EVENTING_NAMESPACE
  oc adm policy add-cluster-role-to-user cluster-admin -z default -n knative-sources

  echo ">>> Setting SSL_CERT_FILE for Knative Eventing Controller"
  oc set env -n $EVENTING_NAMESPACE deployment/eventing-controller SSL_CERT_FILE=/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt

  wait_until_pods_running $EVENTING_NAMESPACE
}

function install_knative_build_pipeline(){
  header "Installing Knative Build Pipeline"

  # Create knative-build-pipeline namespace, needed for imagestreams
  oc create namespace $BUILD_PIPELINE_NAMESPACE

  # Grant the necessary privileges to the service accounts Knative will use:
  oc adm policy add-scc-to-user anyuid -z build-pipeline-controller -n $BUILD_PIPELINE_NAMESPACE
  oc adm policy add-cluster-role-to-user cluster-admin -z build-pipeline-controller -n $BUILD_PIPELINE_NAMESPACE

  resolve_resources config/ $BUILD_PIPELINE_NAMESPACE build-pipeline-resolved.yaml

  # Remove nodePort spec as the ports do not fall into the range allowed by OpenShift
  sed '/nodePort/d' build-pipeline-resolved.yaml | oc apply -f - --validate=true

  wait_until_pods_running $BUILD_PIPELINE_NAMESPACE || return 1
}

function resolve_resources(){
  local dir=$1
  local resolved_file_name=$3
  local registry_prefix="$OPENSHIFT_REGISTRY/$OPENSHIFT_BUILD_NAMESPACE/stable"
  > $resolved_file_name
  for yaml in $(find $dir -maxdepth 1 -name "*.yaml" | sort); do
    echo -e "\n---" >> $resolved_file_name
    #first prefix all test images with "test-", then replace all image names with proper repository
    sed -e 's/\(.* image: \)\(github.com\)\(.*\/\)\(test\/\)\(.*\)/\1\2 \3\4test-\5/' $yaml | \
    sed -e 's%\(.* image: \)\(github.com\)\(.*\/\)\(.*\)%\1 '"$registry_prefix"'\:knative-build-pipeline-\4%' | \
    # process these images separately as they're passed as arguments to other containers
    sed -e 's%github.com/knative/build-pipeline/cmd/kubeconfigwriter%'"$registry_prefix"'\:knative-build-pipeline-kubeconfigwriter%g' | \
    sed -e 's%github.com/knative/build-pipeline/cmd/creds-init%'"$registry_prefix"'\:knative-build-pipeline-creds-init%g' | \
    sed -e 's%github.com/knative/build-pipeline/cmd/git-init%'"$registry_prefix"'\:knative-build-pipeline-git-init%g' | \
    sed -e 's%github.com/knative/build-pipeline/cmd/nop%'"$registry_prefix"'\:knative-build-pipeline-nop%g' | \
    sed -e 's%github.com/knative/build-pipeline/cmd/bash%'"$registry_prefix"'\:knative-build-pipeline-bash%g' | \
    sed -e 's%github.com/knative/build-pipeline/cmd/gsutil%'"$registry_prefix"'\:knative-build-pipeline-gsutil%g' \
    >> $resolved_file_name
  done
}

function enable_docker_schema2(){
  oc set env -n default dc/docker-registry REGISTRY_MIDDLEWARE_REPOSITORY_OPENSHIFT_ACCEPTSCHEMA2=true
}

function run_e2e_tests(){
  header "Running tests"

#  export KO_DOCKER_REPO=registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}

  options=""
  (( EMIT_METRICS )) && options="-emitmetrics"
  report_go_test \
    -v -tags=e2e -count=1 -timeout=20m \
    ./test \
    --kubeconfig $KUBECONFIG \
    ${options} || return 1
}

function delete_istio_openshift(){
  echo ">> Bringing down Istio"
  oc delete --ignore-not-found=true -f $ISTIO_RELEASE
  oc delete --ignore-not-found=true -f $ISTIO_CRD_RELEASE
}

function delete_serving_openshift() {
  echo ">> Bringing down Serving"
  oc delete --ignore-not-found=true -f $SERVING_RELEASE
}

function delete_knative_eventing(){
  header "Bringing down Eventing"
  oc delete --ignore-not-found=true -f $EVENTING_RELEASE
}

function delete_knative_build_pipeline(){
  header "Brinding down Knative Build-Pipeline"
  oc delete --ignore-not-found=true -f build-pipeline-resolved.yaml
}

function delete_in_memory_channel_provisioner(){
  header "Bringing down In-Memory ClusterChannelProvisioner"
  oc delete --ignore-not-found=true -f channel-resolved.yaml
}

function teardown() {
  delete_in_memory_channel_provisioner
  delete_knative_build_pipeline
  delete_knative_eventing
  delete_serving_openshift
  delete_istio_openshift
}

enable_admission_webhooks

install_istio

enable_docker_schema2

install_knative_serving

install_knative_eventing

install_knative_build_pipeline

failed=0

run_e2e_tests || failed=1

(( failed )) && dump_cluster_state

teardown

(( failed )) && exit 1

success