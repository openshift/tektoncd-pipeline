# OpenShift Pipelines 1.5

# Tekton Pipelines v0.24.3


## Fixes

* :hammer: Setup WorkingDir for place-tools init container to avoid permission error ([#4025](https://github.com/tektoncd/pipeline/pull/4025)) Fixes bug [#3978](https://github.com/tektoncd/pipeline/issues/3978)

* :hammer: This is a minor release to fix the delta between v0.24.1 and v0.24.2.



# Tekton Pipelines v0.24.2

## Upgrade Notices

See upgrade notices for [v0.24.0](https://github.com/tektoncd/pipeline/releases/tag/v0.24.0).
Sidecar Workspaces field is annotated in lowercase instead of pascalcase, so Pipelines using them need to be reapplied.

## Fixes

* :bug: [cherry-pick] Fix Workspaces in Sidecar to be serialized as workspaces not Workspaces ([#4013](https://github.com/tektoncd/pipeline/pull/4013))
  Sidecar Workspaces field is annotated in lowercase instead of pascalcase.

* :bug: [cherry-pick] Update tektoncd/plumbing. ([#4009](https://github.com/tektoncd/pipeline/pull/4009))


* :bug: Revert Fix issue with 23 in Script blocks ([#3942](https://github.com/tektoncd/pipeline/pull/3942))
  Revert fix for instances of "\$\$" in script blocks. Kubernetes replaces "\$\$" with a single "\$" and your scripts need to deal appropriately with these instances.


# Tekton Pipelines v0.24.1

## Misc

* :hammer: Revert Fix issue with 37 in Script blocks ([#3938](https://github.com/tektoncd/pipeline/pull/3938))
  Revert fix for instances of "\$\$" in script blocks. Kubernetes replaces "\$\$" with a single "\$" and your scripts need to deal appropriately with these instances.



# Tekton Pipelines v0.24.0

## Upgrade Notices

* Release v0.24.0 of Tekton requires Kubernetes v1.18+.
* The default value of disable-home-env-overwrite and disable-working-dir-overwrite has been changed to true. See the [e-mail thread](https://groups.google.com/g/tekton-dev/c/C-PL8VYN51E) and the [pull request](https://github.com/tektoncd/pipeline/pull/3878) for more details.

## Features

* :sparkles: Allow dot character in resource names ([#3893](https://github.com/tektoncd/pipeline/pull/3893))
  Allow resource names to contain the dot character (".")
  Resource names now validated using the common validation.IsDNS1123Subdomain() function

* :sparkles: Feat: Adding hostAliases in PodTemplate spec. ([#3889](https://github.com/tektoncd/pipeline/pull/3889))
  Feat: Add hostAliases in PodTemplate spec which provides Pod-level override of hostname resolution by modifing /etc/hosts.

* :sparkles: Implement TEP-0033: Add enable-api-fields feature-flag ([#3881](https://github.com/tektoncd/pipeline/pull/3881))
  A new feature-flag, "enable-api-fields" has been added. Valid values are "alpha" and "stable". It defaults to "stable".

Setting the "enable-api-fields" flag tells Tekton what level of API stability you require in the cluster. As new features are added to Pipelines we'll first place those features under the "alpha" flag. When the feature is ready we'll promote it to "stable". This process is described in TEP-0033[1].

Opting in to "alpha" gives you early exposure to exciting new features as they're added to Pipelines but those features are still undergoing development and could be subject to backwards-incompatible changes.

[1] https://github.com/tektoncd/community/blob/main/teps/0033-tekton-feature-gates.md

* :sparkles: Disable the default workingDir and HOME overrides ([#3878](https://github.com/tektoncd/pipeline/pull/3878))
  Steps no longer receive a default HOME env var of "/tekton/home", nor a default workingDir of "/workspace".

action required: if you rely on these defaults you now have a choice to make: either update your Task steps to include the workingDir and HOME env or set the "disable-home-env-overwrite" and "disable-working-directory-overwrite" feature flags to "false". We plan to continue supporting these flags for another 9 months following the release of 0.24 and then they too will be removed.

* :sparkles: an aggregate status of tasks in finally ([#3817](https://github.com/tektoncd/pipeline/pull/3817))
  Introducing a variable $(tasks.status) to access aggregate execution status of tasks in finally.

* :sparkles: Add Step and Sidecar Workspaces feature ([#3700](https://github.com/tektoncd/pipeline/pull/3700))
  New alpha feature added: "Step and Sidecar Workspaces":
  \- Requires "enable-api-fields: alpha" feature gate.
  \- Sidecars in a Task now receive Workspaces, just like Steps do.
  \- Steps and Sidecars can now specify which Workspaces they want access to. This isolates the workspace to only those Steps or Sidecars that need them, allowing Task authors to limit exposure of sensitive data like credentials.
  \- The default behaviour for workspaces in Steps remains the same - all Steps get access to them.

* :sparkles: Make entrypoint binary build for Windows ([#3876](https://github.com/tektoncd/pipeline/pull/3876))

## Upgrade Notices

* :rotating_light: The disable-home-env-overwrite and disable-working-dir-overwrite are now deprecated ([#3878](https://github.com/tektoncd/pipeline/pull/3878))
  The default value of these flags has been changed to true. The flags are still available so that the old behaviour can still be configured; the flags are now deprecated and will be removed in 9 months from now. [e-mail thread](https://groups.google.com/g/tekton-dev/c/C-PL8VYN51E)

## Fixes

* :bug: validate the context variable in when expressions ([#3899](https://github.com/tektoncd/pipeline/pull/3899))
  Do not allow when expressions in dag to specify the context variable accessing the execution status of any other task - $(tasks.<pipelineTask>.status)

* :bug: Fix issue with "\$\$" in Script blocks ([#3888](https://github.com/tektoncd/pipeline/pull/3888))
  Fix a bug where the literal characters "\$\$" in a Step's script block would be replaced with a single "$".

* :bug: Skip sidecar deletion logic for canceled or timed-out TaskRun ([#3877](https://github.com/tektoncd/pipeline/pull/3877))
  Do not run sidecar deletion logic for canceled or timed-out taskrun where pod was deleted

* :bug: Bump distroless/base:debug image ([#3890](https://github.com/tektoncd/pipeline/pull/3890))

## Misc

* :hammer: Remove cluster-wide namespace list/watch permissions ([#3880](https://github.com/tektoncd/pipeline/pull/3880))
  The controller SA no longer requests cluster-wide permission to list and watch namespaces.

* :hammer: Use v1 API for RoleBinding raccoon ([#3872](https://github.com/tektoncd/pipeline/pull/3872))
  Using rbac.authorization.k8s.io/v1 instead of rbac.authorization.k8s.io/v1beta1 for RoleBinding as it is being deprecated starting in 1.17.

* :hammer: Add alpha feature gate tests (integration & examples) to our CI ([#3917](https://github.com/tektoncd/pipeline/pull/3917))
  Pipelines now e2e tests every commit against both the "stable" and "alpha" feature gates.

* :hammer: Test multiple scripts in one task executing with different UIDs ([#3914](https://github.com/tektoncd/pipeline/pull/3914))
  Added test for running Scripts with differing securityContexts in the same Task.

* :hammer: Add a nodeAffinity rule to the controller and webhook deployments ([#3909](https://github.com/tektoncd/pipeline/pull/3909))
  Controller and Webhook pods will no longer be scheduled on Windows nodes if any exist in a Kubernetes cluster.

* :hammer: Enable Bundles and Custom Tasks when feature gate is set to alpha ([#3908](https://github.com/tektoncd/pipeline/pull/3908))
  Switching the "enable-api-fields" feature gate to "alpha" also turns on Tekton Bundles and Custom Tasks support, since these are alpha features.

* :hammer: Bump knative to 0.22 mage ([#3883](https://github.com/tektoncd/pipeline/pull/3883))
  Update knative dependency to 0.22, and default minimum kubernetes version supported, v1.18.0

    * :hammer: Updates the Tekton Bundle spec and resolver to be more explicit. ([#3869](https://github.com/tektoncd/pipeline/pull/3869))
    * :hammer: Fix lint issues ([#3926](https://github.com/tektoncd/pipeline/pull/3926))
    * :hammer: Remove field name from error returned during feature gate validation ([#3918](https://github.com/tektoncd/pipeline/pull/3918))
    * :hammer: Remove random suffixes on creds-init volumes ([#3907](https://github.com/tektoncd/pipeline/pull/3907))
    * :hammer: Add test YAML helpers ([#3905](https://github.com/tektoncd/pipeline/pull/3907))
    * :hammer: Last minute fixups from review feedback on "enable-api-fields" PR ([#3904](https://github.com/tektoncd/pipeline/pull/3904))
    * :hammer: Resolving integration test failures by bumping plumbing ([#3894](https://github.com/tektoncd/pipeline/pull/3894))
    * :hammer: Add doc links for 0.23.0 to README and update release-cheat-sheet ([#3868](https://github.com/tektoncd/pipeline/pull/3868))

# Tekton Pipelines v0.23.0


## Features
* :sparkles: Remove YAML merge and variable from config YAML ([#3842](https://github.com/tektoncd/pipeline/pull/3842))
  Make release.yaml more easily consumed by tools like kustomize and ytt



## Fixes
* :bug: PVC: Use Owner UIDs instead of Owner names. ([#3856](https://github.com/tektoncd/pipeline/pull/3856))
  Misc
* :hammer: Use v1 instead of v1beta1 for robot ([#3859](https://github.com/tektoncd/pipeline/pull/3859))
  Using rbac.authorization.k8s.io/v1 instead of rbac.authorization.k8s.io/v1beta1 for ClusterRoleBinding as it is being deprecated starting in 1.17.

* :hammer: Further limit cluster-wide read-write permissions ([#3832](https://github.com/tektoncd/pipeline/pull/3832))
  Remove cluster-wide write access to ConfigMaps, LimitRanges and remove all cluster-wide access to Deployments

* :hammer: Remove cluster-wide write access to ServiceAccounts and Secrets ([#3831](https://github.com/tektoncd/pipeline/pull/3831))
  Remove cluster-wide write access to ServiceAccounts and Secrets

* :hammer: Remove unused image-cache CRD ([#3850](https://github.com/tektoncd/pipeline/pull/3850))
  The Image CRD in the caching.internal.knative.dev group is not used by Tekton and is not included anymore in the release.

* :hammer: Change to use new base images for git and pullrequest images ([#3828](https://github.com/tektoncd/pipeline/pull/3828))
  Add nonroot user in the PullRequest init base image

* :hammer: Add Dockerfile for pullrequest nonroot build base image ([#3810](https://github.com/tektoncd/pipeline/pull/3810))

Add Dockerfile for pullrequset nonroot build base image

   * :hammer: Pull request template spring cleaning tulip ([#3866](https://github.com/tektoncd/pipeline/pull/3866))
   * :hammer: refactor pipelineTask validation ([#3848](https://github.com/tektoncd/pipeline/pull/3848))
   * :hammer: refactoring validate pipelineTask name ([#3818](https://github.com/tektoncd/pipeline/pull/3818))
   * :hammer: Add ability to run e2e tests on top of nightly release ([#3847](https://github.com/tektoncd/pipeline/pull/3847))
   * :hammer: Use "no-cache" in the buildkit based builds ([#3834](https://github.com/tektoncd/pipeline/pull/3834))
   * :hammer: Update self, community and plumbing reference to use main… mage ([#3821](https://github.com/tektoncd/pipeline/pull/3821))