# OpenShift Pipelines 1.4

# Tekton Pipelines v0.22.0

## Features
N/A

## Deprecation Notices
N/A

## Backwards incompatible changes
N/A

## Fixes

* :bug: Serialize and deserialize Finally in PipelineRuns too ([#3816](https://github.com/tektoncd/pipeline/pull/3816))
Fix issue where PipelineRun with finally in nested pipeline spec would lose those finally tasks when converted down to v1alpha1 and back up to v1beta1 again.

* :bug: Change to avoid error when service account has empty secret name ([#3795](https://github.com/tektoncd/pipeline/pull/3795))
In case of an empty secret name, the taskRun was failing with CouldntGetTask as the GET request with an empty secret name return an error saying resource name may not be empty. Fixing such failing of a taskRun by avoiding an empty secret name in the kubeclient GET request.

* :bug: Disable Webhook PDB by default, document enabling it ([#3787](https://github.com/tektoncd/pipeline/pull/3787))
Disable PodDisruptionBudget for the webhook deployment by default

* :bug: Set minAvailable:1 to unblock node upgrades ([#3784](https://github.com/tektoncd/pipeline/pull/3784))
Modify webhook PodDisruptionBudget minAvailable to 1, so node upgrades aren't blocked

* :bug: Losslessly roundtrip Pipelines with Finally from beta to alpha and back ([#3779](https://github.com/tektoncd/pipeline/pull/3779))
v1beta1 Pipelines can now be requested with v1alpha1 version without losing Finally tasks. Applying the returned v1alpha1 version will store the resource as v1beta1 with the Finally section restored to its original state.

* :bug: Short term fix for Cloud Event Source ([#3761](https://github.com/tektoncd/pipeline/pull/3761))
Resolves [#2676](https://github.com/tektoncd/pipeline/issues/2676) by providing Cloud Event source value when selfLink unset

## Misc

* :hammer: Remove support for build-gcs and the gcs-fetcher image ([#3771](https://github.com/tektoncd/pipeline/pull/3771))

Remove support for build-gcs and the gcs-fetcher image

* :hammer: Remove tekton.dev/task label from taskrun of clustertasks ([#3764](https://github.com/tektoncd/pipeline/pull/3764))
Remove tekton.dev/task label from taskrun of clustertasks

# Tekton Pipelines v0.21.0

## Upgrade Notices

* Requires Kubernetes 1.17+ to run
* The controller now requires that the SYSTEM_NAMESPACE environment variable is set. This was set by default before, but is now required.

## Features

* :sparkles: WhenExpressions in Finally Tasks ([#3738](https://github.com/tektoncd/pipeline/pull/3738))

WhenExpressions are supported in Finally Tasks not only to provide efficient guarded execution but also to improve the
reusability of Tasks in Finally

* :sparkles: Allow pipeline results to use custom task results ([#3694](https://github.com/tektoncd/pipeline/pull/3694))

Pipeline results now can refer to pipeline tasks that run custom tasks and produce results.

* :sparkles: Support multiple secrets of type dockercfg and dockerconfigjson ([#3659](https://github.com/tektoncd/pipeline/pull/3659))

Adds support for multiple secrets of type dockercfg or dockerconfigjson

* :sparkles: add sparse checkout to git ([#3646](https://github.com/tektoncd/pipeline/pull/3646))

* :sparkles: Implement Pending PipelineRun status (TEP-0015) ([#3522](https://github.com/tektoncd/pipeline/pull/3522))

Added PipelineRunPending setting to PipelineRun Spec Status to allow creating PipelineRuns in a Pending state.

* :sparkles: consuming task results in finally ([#3242](https://github.com/tektoncd/pipeline/pull/3242))

Final tasks can be configured to consume results of PipelineTasks from tasks section.

## Deprecation Notices
N/A

## Backwards incompatible changes
N/A

## Fixes

* :bug: Make volume mount names RFC1123 DNS label strict ([#3740](https://github.com/tektoncd/pipeline/pull/3740))

Fixed a bug where a secret name with dots (e.g. gcr.io) led to a TaskRun creation failure, because the secret name was used internally as part of a volume mount name. These volume mount name have the be RFC1123 DNS label conform and therefore disallow dots as part of the name.

* :bug: Validate Context Variables in Finally Tasks ([#3733](https://github.com/tektoncd/pipeline/pull/3733))

Added validation for Context variables in Finally Tasks

* :bug: Change to use the FilteredPodInformer to only watch Tekton relevant pods ([#3725](https://github.com/tektoncd/pipeline/pull/3725))

Performance improvement: Only watch Pods managed by Tekton, instead of all Pods on the cluster

* :bug: Fix duplicate Pods when TaskRun or Pod labels are changed ([#3708](https://github.com/tektoncd/pipeline/pull/3708))

Fix duplicate Pods when TaskRun or Pod labels are changed

* :bug: Fix stuck PipelineRun caused by optional workspace ([#3702](https://github.com/tektoncd/pipeline/pull/3702))

Fixed bug where PipelineRun that didn't provide an optional workspace to the Pipeline would stall until timing out.

* :bug: Fix bug where step status ordering did not match step container ordering ([#3679](https://github.com/tektoncd/pipeline/pull/3679))

Fixed bug where sorted order of step statuses did not match order of step containers.

* :bug: set task as failed ([#3571](https://github.com/tektoncd/pipeline/pull/3571))

Declare task failure when it hits CreateContainerConfigError instead of setting it to unknown i.e. running.

* :bug: Move resolution of Pipeline Results to end of completed/successful reconcile ([#3684](https://github.com/tektoncd/pipeline/pull/3684))

## Misc

* :hammer: Document deprecation of the build-gcs PipelineResource type ([#3728](https://github.com/tektoncd/pipeline/pull/3728))

Deprecate the build-gcs sub-type of the storage PipelineResource

* :hammer: Add nonroot user to pipeline's build-base image ([#3727](https://github.com/tektoncd/pipeline/pull/3727))

Added non-root user 65532 to pipelines' build-base image. Git-init can now be used to clone repositories as a non-root user.

* :hammer: Validate dependencies between resolved resources in a PipelineRun ([#3711](https://github.com/tektoncd/pipeline/pull/3711))

Added extra validations before PipelineRun can start: all result variables in the Pipeline must be valid and optional workspaces from a pipeline can only be passed to tasks expecting optional workspaces.

# Tekton Pipelines v0.20.1

## Fixes

* :hammer: [cherry-pick] validate execution status variable ([#3697](https://github.com/tektoncd/pipeline/pull/3697))

Avoid validating task results while validating context variable to access execution status since it follows similar pattern $(tasks.taskname.results.status) where status is result of some task compared to context variable for referencing execution status $(tasks.taskname.status).

# Tekton Pipelines v0.20.0

## Upgrade Notices

* Tekton v0.20.0 requires Kubernetes 1.17+ to run.

## Features

* :sparkles: Allow custom tasks to use workspaces, service accounts, pod templates ([#3660](https://github.com/tektoncd/pipeline/pull/3660))

Allow custom tasks to use workspaces, service accounts, and pod templates

* :sparkles: access execution status of any task in finally ([#3390](https://github.com/tektoncd/pipeline/pull/3390))

Introducing a variable $(tasks..status) to access execution status of any non finally pipelineTask in finally.

## Fixes

* :bug: Change leader-election RBAC to be namespaced ([#3639](https://github.com/tektoncd/pipeline/pull/3639))

The tekton-pipelines-webhook-leaderelection and tekton-pipelines-controller-leaderelection ClusterRoleBindings have been changed to RoleBindings, and the tekton-pipelines-leader-election ClusterRole has been changed to a Role.

* :bug: Fix bug where PipelineRun emits task results that were never produced ([#3472](https://github.com/tektoncd/pipeline/pull/3472))

Fix bug where PipelineRun emits task results that were never produced. Previously a Pipeline Result that contained an invalid variable would be added to the PipelineRun with that unreplaced variable intact. Now a Pipeline Result that contains an invalid variable will not be emitted by the PipelineRun at all.

## Misc

* :hammer: Remove creds-init image from build and deploy ([#3665](https://github.com/tektoncd/pipeline/pull/3665))

The creds-init helper image is no longer part of Pipelines' build. The image has not been in use for several releases.

* :hammer: Remove v1beta1 from possible AdmissionReview versions ([#3640](https://github.com/tektoncd/pipeline/pull/3640))

* :hammer: Run controller and webhook also as non-root group. Drop capabilities. ([#3611](https://github.com/tektoncd/pipeline/pull/3611))
