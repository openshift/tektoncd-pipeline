#This makefile is used by ci-operator

CGO_ENABLED=0
GOOS=linux
CORE_IMAGES=./cmd/bash ./cmd/controller ./cmd/entrypoint ./cmd/gsutil ./cmd/kubeconfigwriter ./cmd/nop ./cmd/webhook ./cmd/imagedigestexporter
CORE_IMAGES_WITH_GIT=./cmd/creds-init ./cmd/git-init

##
# You need to provide a RELEASE_VERSION when using targets like `push-image`, you can do it directly
# on the command like this: `make push-image RELEASE_VERSION=0.4.0`
RELEASE_VERSION=
REGISTRY_CI_URL=registry.svc.ci.openshift.org/openshift/tektoncd-v$(RELEASE_VERSION):tektoncd-pipeline
REGISTRY_RELEASE_URL=quay.io/openshift-pipeline/tektoncd-pipeline

# Install core images
install: installuidwrapper
	go install $(CORE_IMAGES) $(CORE_IMAGES_WITH_GIT)
.PHONY: install

# Run E2E tests on OpenShift
test-e2e:
	./openshift/e2e-tests-openshift.sh
.PHONY: test-e2e

# Generate Dockerfiles used by ci-operator. The files need to be committed manually.
generate-dockerfiles:
	./openshift/ci-operator/generate-dockerfiles.sh openshift/ci-operator/Dockerfile.in openshift/ci-operator/knative-images $(CORE_IMAGES)
	./openshift/ci-operator/generate-dockerfiles.sh openshift/ci-operator/Dockerfile-git.in openshift/ci-operator/knative-images $(CORE_IMAGES_WITH_GIT)
.PHONY: generate-dockerfiles

# NOTE(chmou): Install uidwraper for launching some binaries with fixed uid
UIDWRAPPER_PATH=./openshift/ci-operator/uidwrapper
installuidwrapper: $(UIDWRAPPER_PATH)
	install -m755 $(UIDWRAPPER_PATH) $(GOPATH)/bin/

# Generates a ci-operator configuration for a specific branch.
generate-ci-config:
	./openshift/ci-operator/generate-ci-config.sh $(BRANCH) > ci-operator-config.yaml
.PHONY: generate-ci-config

# Generate an aggregated knative yaml file with replaced image references
generate-release:
	@test $(RELEASE_VERSION) || { echo "You need to set the RELEASE_VERSION on the command line i.e: make RELEASE_VERSION=0.4.0"; exit ;1;}
	@./openshift/release/generate-release.sh v$(RELEASE_VERSION)
.PHONY: generate-release

push-image:
	@test $(RELEASE_VERSION) || { echo "You need to set the RELEASE_VERSION on the command line i.e: make RELEASE_VERSION=0.4.0"; exit ;1;}
	@set -ex; \
	for image in $(CORE_IMAGES);do \
		image=`basename $$image` ; \
		docker pull $(REGISTRY_CI_URL)-$$image ; \
		docker tag $(REGISTRY_CI_URL)-$$image $(REGISTRY_RELEASE_URL)-$$image:v$(RELEASE_VERSION) ; \
		docker tag $(REGISTRY_RELEASE_URL)-$$image:v$(RELEASE_VERSION) $(REGISTRY_RELEASE_URL)-$$image:latest; \
		docker push $(REGISTRY_RELEASE_URL)-$$image:v$(RELEASE_VERSION) ; \
		docker push $(REGISTRY_RELEASE_URL)-$$image:latest ; \
	done

.PHONY: push-image
