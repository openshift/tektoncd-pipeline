#!/bin/sh

source $(dirname $0)/../vendor/github.com/knative/test-infra/scripts/e2e-tests.sh

set -x

readonly API_SERVER=$(oc config view --minify | grep server | awk -F'//' '{print $2}' | awk -F':' '{print $1}')
readonly OPENSHIFT_REGISTRY="${OPENSHIFT_REGISTRY:-"registry.svc.ci.openshift.org"}"
readonly TEST_NAMESPACE=tekton-pipeline-tests
readonly TEST_YAML_NAMESPACE=tekton-pipeline-tests-yaml
readonly TEKTON_PIPELINE_NAMESPACE=tekton-pipelines
readonly IGNORES="git-volume|gcs-archive|docker-basic"
readonly KO_DOCKER_REPO=image-registry.openshift-image-registry.svc:5000/tektoncd-pipeline

env

function install_tekton_pipeline(){
  header "Installing Tekton Pipeline"
  # Grant the necessary privileges to the service accounts Knative will use:
  oc adm policy add-scc-to-user anyuid -z tekton-pipelines-controller -n $TEKTON_PIPELINE_NAMESPACE
  oc adm policy add-cluster-role-to-user cluster-admin -z tekton-pipelines-controller -n $TEKTON_PIPELINE_NAMESPACE

  create_pipeline

  wait_until_pods_running $TEKTON_PIPELINE_NAMESPACE || return 1

  header "Tekton Pipeline Installed successfully"
}

function create_pipeline(){
  resolve_resources config/ tekton-pipeline-resolved.yaml
  oc apply -f tekton-pipeline-resolved.yaml
}

function resolve_resources(){
  local dir=$1
  local resolved_file_name=$2
  local registry_prefix="$OPENSHIFT_REGISTRY/$OPENSHIFT_BUILD_NAMESPACE/stable"
  > $resolved_file_name
  for yaml in $(find $dir -name "*.yaml" | grep -vE $IGNORES); do
    echo "---" >> $resolved_file_name
    #first prefix all test images with "test-", then replace all image names with proper repository and prefix images with "tekton-pipeline"
    sed -e 's%\(.* image: \)\(github.com\)\(.*\/\)\(test\/\)\(.*\)%\1\2 \3\4test-\5%' $yaml | \
    sed -e 's%\(.* image: \)\(github.com\)\(.*\/\)\(.*\)%\1 '"$registry_prefix"'\:tektoncd-pipeline-\4%' | \
    # process these images separately as they're passed as arguments to other containers
    sed -e 's%github.com/tektoncd/pipeline/cmd/bash%'"$registry_prefix"'\:tektoncd-pipeline-bash%g' | \
    sed -e 's%github.com/tektoncd/pipeline/cmd/creds-init%'"$registry_prefix"'\:tektoncd-pipeline-creds-init%g' | \
    sed -e 's%github.com/tektoncd/pipeline/cmd/entrypoint%'"$registry_prefix"'\:tektoncd-pipeline-entrypoint%g' | \
    sed -e 's%github.com/tektoncd/pipeline/cmd/git-init%'"$registry_prefix"'\:tektoncd-pipeline-git-init%g' | \
    sed -e 's%github.com/tektoncd/pipeline/cmd/kubeconfigwriter%'"$registry_prefix"'\:tektoncd-pipeline-kubeconfigwriter%g' | \
    sed -e 's%github.com/tektoncd/pipeline/cmd/nop%'"$registry_prefix"'\:tektoncd-pipeline-nop%g' \
    >> $resolved_file_name
    echo >> $resolved_file_name
  done
}

function enable_docker_schema2(){
  oc set env -n default dc/docker-registry REGISTRY_MIDDLEWARE_REPOSITORY_OPENSHIFT_ACCEPTSCHEMA2=true
}

function create_test_namespace(){
  oc new-project $TEST_YAML_NAMESPACE
  oc policy add-role-to-group system:image-puller system:serviceaccounts:$TEST_YAML_NAMESPACE -n $OPENSHIFT_BUILD_NAMESPACE
  oc new-project $TEST_NAMESPACE
  oc policy add-role-to-group system:image-puller system:serviceaccounts:$TEST_NAMESPACE -n $OPENSHIFT_BUILD_NAMESPACE
}

function run_go_e2e_tests(){
  header "Running Go e2e tests"
  go_test_e2e ./test -timeout=20m --kubeconfig $KUBECONFIG || return 1
}

function run_yaml_e2e_tests() {
  header "Running YAML e2e tests"
  oc project $TEST_YAML_NAMESPACE
  resolve_resources test/ tests-resolved.yaml
  oc apply -f tests-resolved.yaml

  # The rest of this function copied from test/e2e-common.sh#run_yaml_tests()
  # The only change is "kubectl get builds" -> "oc get builds.build.knative.dev"
  oc get project

  # Wait for tests to finish.
  echo ">> Waiting for tests to finish"
  for test in taskrun pipelinerun; do
     if validate_run ${test}; then
      echo "ERROR: tests timed out"
     fi
  done

  # Check that tests passed.
  echo ">> Checking test results"
  for test in taskrun pipelinerun; do
    if check_results ${test}; then
      echo ">> All YAML tests passed"
      return 0
    fi
  done

  # it failed, display logs
  for test in taskrun pipelinerun; do
    echo "<< State and Logs for ${test}"
    output_yaml_test_results ${test}
    output_pods_logs ${test}
  done
  return 1
}

function validate_run() {
  local tests_finished=0
  for i in {1..60}; do
    local finished="$(kubectl get $1.tekton.dev --output=jsonpath='{.items[*].status.conditions[*].status}')"
    if [[ ! "$finished" == *"Unknown"* ]]; then
      tests_finished=1
      break
    fi
    sleep 10
  done

  return ${tests_finished}
}

function check_results() {
  local failed=0
  results="$(kubectl get $1.tekton.dev --output=jsonpath='{range .items[*]}{.metadata.name}={.status.conditions[*].type}{.status.conditions[*].status}{" "}{end}')"
  for result in ${results}; do
    if [[ ! "${result,,}" == *"=succeededtrue" ]]; then
      echo "ERROR: test ${result} but should be succeededtrue"
      failed=1
    fi
  done

  return ${failed}
}

function output_yaml_test_results() {
  # If formatting fails for any reason, use yaml as a fall back.
  oc get $1.tekton.dev -o=custom-columns-file=${REPO_ROOT_DIR}/test/columns.txt || \
    oc get $1.tekton.dev -oyaml
}

function output_pods_logs() {
    echo ">>> $1"
    oc get $1.tekton.dev -o yaml
    local runs=$(kubectl get $1.tekton.dev --output=jsonpath="{.items[*].metadata.name}")
    set +e
    for run in ${runs}; do
	echo ">>>> $1 ${run}"
	case "$1" in
	    "taskrun")
		go run ./test/logs/main.go -tr ${run}
		;;
	    "pipelinerun")
		go run ./test/logs/main.go -pr ${run}
		;;
	esac
    done
    set -e
    echo ">>>> Pods"
    kubectl get pods -o yaml
}

function delete_build_pipeline_openshift() {
  echo ">> Bringing down Build"
  oc delete --ignore-not-found=true -f tekton-pipeline-resolved.yaml
  # Make sure that are no residual object in the tekton-pipelines namespace.
  oc delete --ignore-not-found=true taskrun.tekton.dev --all -n $TEKTON_PIPELINE_NAMESPACE
  oc delete --ignore-not-found=true pipelinerun.tekton.dev --all -n $TEKTON_PIPELINE_NAMESPACE
  oc delete --ignore-not-found=true task.tekton.dev --all -n $TEKTON_PIPELINE_NAMESPACE
  oc delete --ignore-not-found=true clustertask.tekton.dev --all -n $TEKTON_PIPELINE_NAMESPACE
  oc delete --ignore-not-found=true pipeline.tekton.dev --all -n $TEKTON_PIPELINE_NAMESPACE
  oc delete --ignore-not-found=true pipelineresources.tekton.dev --all -n $TEKTON_PIPELINE_NAMESPACE
}

function delete_test_resources_openshift() {
  echo ">> Removing test resources (test/)"
  oc delete --ignore-not-found=true -f tests-resolved.yaml
}

 function delete_test_namespace(){
   echo ">> Deleting test namespace $TEST_NAMESPACE"
   #oc policy remove-role-from-group system:image-puller system:serviceaccounts:$TEST_NAMESPACE -n $OPENSHIFT_BUILD_NAMESPACE
   #oc delete project $TEST_NAMESPACE
   oc policy remove-role-from-group system:image-puller system:serviceaccounts:$TEST_YAML_NAMESPACE -n $OPENSHIFT_BUILD_NAMESPACE
   oc delete project $TEST_YAML_NAMESPACE
 }

function teardown() {
  delete_test_namespace
  delete_test_resources_openshift
  delete_build_pipeline_openshift
}

create_test_namespace

enable_docker_schema2

install_tekton_pipeline

failed=0

run_go_e2e_tests || failed=1

run_yaml_e2e_tests || failed=1

(( failed )) && dump_cluster_state

teardown

(( failed )) && exit 1

success
