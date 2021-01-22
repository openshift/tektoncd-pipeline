# OpenShift Pipelines TP-1.3

# Tekton Pipelines v0.19.0

## Features

* :sparkles: Do not allow use of deprecated Conditions with custom tasks ([#3601](https://github.com/tektoncd/pipeline/pull/3601))

  Disallow use of Conditions in pipeline tasks that reference custom tasks

* :sparkles: Add variable expansion for ImagePullPolicy in Tasks. See #3423 ([#3488](https://github.com/tektoncd/pipeline/pull/3488))

  Add variable expansion in Tasks for fields:

  * spec.steps[].imagePullPolicy
  * spec.sidecar[].imagePullPolicy

* :sparkles: Add an unsuccessful TaskRun testcase in conformance tests ([#3454](https://github.com/tektoncd/pipeline/pull/3454))

## Deprecation Notices
* :rotating_light: The PascalCase fields in WhenExpressions is deprecated
  
  Tasks and Pipelines with WhenExpressions that were created using Tekton Pipelines v0.16.x need to be reapplied to fix the case of their json annotations ([#3570](https://github.com/tektoncd/pipeline/pull/3570))

## Fixes
* :bug: Fix PipelineRun serviceAccountNames for finally tasks ([#3560](https://github.com/tektoncd/pipeline/pull/3560))

  Fixes a bug where PipelineRun's serviceAccountNames and taskPodSpecs couldn't be applied on finally tasks and resulted in an error.

* :bug: Fix duplicate TaskRuns when Pipeline/PipelineRun labels are changed ([#3558](https://github.com/tektoncd/pipeline/pull/3558))

  Fix an issue where the PipelineRun controller could create duplicate TaskRuns if a Pipeline's or PipelineRun's labels are changed while the PipelineRun is running

* :bug: Consider not-found pod as permanent error when taskrun is done ([#3542](https://github.com/tektoncd/pipeline/pull/3542))

  Fix an issue where the taskrun controller would continue reconciling completed taskruns if pods in case of evicted pods

* :bug: Fix script step on CRI-O runtime ([#3526](https://github.com/tektoncd/pipeline/pull/3526))

<hr>

# Tekton Pipelines v0.18.1

## Fixes

* :bug: [cherry-pick] Fix recursion issue on Skip ([#3534](https://github.com/tektoncd/pipeline/pull/3534))

  Fix and issue in the pipeline state resolution which lead to very long or failed start times and high controller CPU in case of pipelines with a large number of dependencies between tasks (40+).

* :bug: [cherry-pick] Change the webhook name to pipeline-webhook ([#3533](https://github.com/tektoncd/pipeline/pull/3533))

  Fix an issue that caused the webhook, under certain conditions, to fail to acquire a lease and not function correctly as a result.
<hr>

# Tekton Pipelines v0.18.0

## Features

* :sparkles: Add readiness and liveness probes in controller ([#3489](https://github.com/tektoncd/pipeline/pull/3489))

* :sparkles: Add timestaps in logs ([#3392](https://github.com/tektoncd/pipeline/pull/3392))
  
  Add timestamp in the logs of the tekton pipelines controller and webhook

* :sparkles: Add feature flag to disable creds-init ([#3379](https://github.com/tektoncd/pipeline/pull/3379))

  Tekton's built-in credential mechanism can now be disabled by setting the disable-creds-init feature-flag to "true".

* :sparkles: Fixes [#3086](https://github.com/tektoncd/pipeline/pull/3086) - amd64 images are pulled on all the architectures ([#3337](https://github.com/tektoncd/pipeline/pull/3337))
  
  The entrypoint lookup will pull the image for the controller's architecture instead of amd64 to better support different architectures

* :sparkles: Update -shell-image to a multi-arch version ([#3334](https://github.com/tektoncd/pipeline/pull/3334))
  
  Use a multi-arch shell-image

* :sparkles: When Expressions Status ([#3333](https://github.com/tektoncd/pipeline/pull/3333))

  Resolved When Expressions are listed in the Skipped Tasks and the Task Runs sections of the Status

* :sparkles: update submodules with --init flag ([#3321](https://github.com/tektoncd/pipeline/pull/3321))
  
  Git-init can now clone recursive submodules.

* :sparkles: Upgrade knative -> 0.18 ([#3319](https://github.com/tektoncd/pipeline/pull/3319))
  
  **Breaking Change:**

  This release will drop the resource_name label from webhook_request_(count, latencies_bucket) metrics. This this breaking change with no replacement for those relying on these metrics. The omission of these metrics will improve the overall memory usage of the webhook and the stability of the /metrics endpoint.

* :sparkles: perf: create (pipeline|task)run timeout checks in background ([#3302](https://github.com/tektoncd/pipeline/pull/3302))
  
  controller and startup time is improved when lots of namespaces are being managed

* :sparkles: Step timeout ([#3087](https://github.com/tektoncd/pipeline/pull/3087))
  
  Task authors can now specify a timeout for a Step in the TaskSpec.

## Fixes
* :bug: Adjust PipelineRun's StartTime based on TaskRun state. ([#3461](https://github.com/tektoncd/pipeline/pull/3461))
  
  Fixes a bug where PipelineRun may report as Failed when it really timed out.

* :bug: Make ConditionCheck container names DNS-safe ([#3394](https://github.com/tektoncd/pipeline/pull/3394))

  Fixes a bug where condition validation may fail with long condition names.

* :bug: Don't fail immediately on missing resources. ([#3385](https://github.com/tektoncd/pipeline/pull/3385))
  
  Add a grace period for resources to appear before failing *Runs

* :bug: Switch webhook liveness/readiness probes to use http ports ([#3349](https://github.com/tektoncd/pipeline/pull/3349))

* :bug: Attempt to fix another structured-merge-diff failures. ([#3348](https://github.com/tektoncd/pipeline/pull/3348))

  action required: Drop pointers from inline struct when embedding TaskSpec in v1beta1

* :bug: avoid requeuing taskrun in case of permanent error ([#3068](https://github.com/tektoncd/pipeline/pull/3068))
  
  Do not requeue taskrun if it was rejected with permanent error. This bug was causing the incorrect metrics for tekton_taskrun_count{status="failed"}.

* :bug: Check that events are at least expected ones ([#3375](https://github.com/tektoncd/pipeline/pull/3375))
* :bug: Eliminate redundant Pod Get. ([#3496](https://github.com/tektoncd/pipeline/pull/3496))
* :bug: tests: fix potential races with t.Parallel and loops loop ([#3493](https://github.com/tektoncd/pipeline/pull/3493))
* :bug: Fix error path through test. ([#3474](https://github.com/tektoncd/pipeline/pull/3474))
* :bug: fix finally e2e test ([#3464](https://github.com/tektoncd/pipeline/pull/3464))
* :bug: Don't "Follow" when dumping test pod logs. ([#3447](https://github.com/tektoncd/pipeline/pull/3447))
* :bug: Make t.Parallel() come first ([#3425](https://github.com/tektoncd/pipeline/pull/3425))
* :bug: release: fix the publish task definition bookmark_tabs ([#3376](https://github.com/tektoncd/pipeline/pull/3376))
* :bug: Update the revision used with kaniko. ([#3363](https://github.com/tektoncd/pipeline/pull/3363))
* :bug: Pass test ctx to taskrun reconciler instead of background ctx ([#3445](https://github.com/tektoncd/pipeline/pull/3445))

<hr>

# Tekton Pipelines v0.17.3

## Fixes
* :bug: [cherry-pick] Avoid dangling symlinks in git-init ([#3485](https://github.com/tektoncd/pipeline/pull/3485))
  
  Fixed a bug in git-init that allowed a circular symlink to be created from /root/.ssh to itself if no SSH credentials are present in the service account and the disable-home-env-overwrite flag is set to "true".

* :bug: [cherry-pick] pkg/git: fix ssh credentials detection crab ([#3484](https://github.com/tektoncd/pipeline/pull/3484))

  fix ssh credential wrong detection in git-init
<hr>

# Tekton Pipelines v0.17.2

## Fixes
* :bug: [cherry-pick] Fix TaskRunSpec overrides when empty clamp ([#3441](https://github.com/tektoncd/pipeline/pull/3441))

  Fix invalid ServiceAccount or PodTemplate in case of not specified in an existing taskRunSpec.

* :bug: [cherry-pick] Fix json annotations in WhenExpression ([#3421](https://github.com/tektoncd/pipeline/pull/3421))

  pipelines with when expressions created in v0.16.3 can be run
<hr>

# Tekton Pipelines v0.17.1

## Fixes
* :bug: [cherry-pick] Fix the logic for the disable-ha flag ([#3371](https://github.com/tektoncd/pipeline/pull/3371))

  Default behaviour for leader-election-ha has been restored to "enabled".
The controller flag disable-ha will now disable HA support when set to true.

* :bug: [cherry-pick] Only send cloud events when condition changes ([#3370](https://github.com/tektoncd/pipeline/pull/3370))
  
  Fixes issue with duplicate cloud events. Cloud events are now sent only if a change in condition happened.

* :bug: [cherry-pick] Take -version into account in the controller coffee ([#3369](https://github.com/tektoncd/pipeline/pull/3369))

  Correctly set the release annotation on TaskRun based on the currently running pipeline instance version

* :bug: [cherry-pick] config: fix runAsUser inconsistency with images ice_cream ([#3368](https://github.com/tektoncd/pipeline/pull/3368))
  
  Fix inconsistent uid for the controller and webhook deployment, resulting in failure of installing tekton pipeline on minikube (and other platforms.)
<hr>

# Tekton Pipelines v0.17.0

## Features
* :sparkles: Base entrypoint image on distroless ([#3286](https://github.com/tektoncd/pipeline/pull/3286))
  
  Binary file (standard input) matches

* :sparkles: Provide configuration option to disallow omitting known_hosts ([#3283](https://github.com/tektoncd/pipeline/pull/3283))
  
  Provide configuration option to disallow omitting known_hosts in Git SSH Secret.

* :sparkles: Introduce Optional Workspaces ([#3274](https://github.com/tektoncd/pipeline/pull/3274))
  
  Introduce optional workspaces: A Task or Pipeline may declare a workspace optional and conditionally change their behaviour based on its presence. A TaskRun or PipelineRun may omit that workspace and thereby modify the Task or Pipeline behaviour.

* :sparkles: Update CRD definition to use apiextensions v1 ([#3236](https://github.com/tektoncd/pipeline/pull/3236))
  
  Update CRD to use apiextensions.k8s.io/v1 instead of v1beta1

* :sparkles: Bump knative to enable new features ([#3181](https://github.com/tektoncd/pipeline/pull/3181))

  knative is upgraded to a more recent version

* :sparkles: Make DefaultThreadsPerController, QPS and Burst configurable via flags ([#3156](https://github.com/tektoncd/pipeline/pull/3156))
  
  Allows DefaultThreadsPerController, QPS, and Burst to be configured via flags

* :sparkles: Fix(git): add warning of the mismatch of git cred and url ([#3136](https://github.com/tektoncd/pipeline/pull/3136))
  
  Fix(git): Tekton's credentials initialization now detects when an SSH credential is used with a non-SSH URL (and vice versa) in Git PipelineResources and will log a warning in Step containers.

* :sparkles: Emit an event if overwriting PodTemplate affinity ([#2859](https://github.com/tektoncd/pipeline/pull/2859))

* :sparkles: Add cloud events to metrics ([#2720](https://github.com/tektoncd/pipeline/pull/2720))

* :sparkles: Run enhancements ([#3313](https://github.com/tektoncd/pipeline/pull/3313))

* :sparkles: Introducing InternalTektonResultType as a ResultType ([#3138](https://github.com/tektoncd/pipeline/pull/3138))

## Fixes
* :bug: Replace variables in Sidecar Script block ([#3318](https://github.com/tektoncd/pipeline/pull/3318))
  
  Fixed issue where script blocks in sidecars didn't have their variables replaced.

* :bug: Fix issue where workspace volume variable and pod volume conf differ ([#3315](https://github.com/tektoncd/pipeline/pull/3315))
  
  Fixed a bug where a workspace's volume name did not match the value from workspace..volume variables.

* :bug: Sort pod container statuses based on Step order in taskSpec ([#3256](https://github.com/tektoncd/pipeline/pull/3256))
  
  Steps in the TaskRun status field are now sorted according to the Step order specified in the taskSpec

* :bug: Fix version label on created pods point_down ([#3193](https://github.com/tektoncd/pipeline/pull/3193))
  
  Fix version label on created pods

* :bug: default service account ([#3168](https://github.com/tektoncd/pipeline/pull/3168))
  
  Service account when missing from pipelinerun/taskrun spec and ConfigMap, controller sets it to default in the spec.

* :bug: Add support for repeated PVC-claim but using subPath in AA-validation ([#3099](https://github.com/tektoncd/pipeline/pull/3099))

  Fixes a bug with validation for the Affinity Assistant when the same PVC is used for multiple workspaces but with different subPaths

* :bug: Fix annotation on v1beta1 field. ([#3328](https://github.com/tektoncd/pipeline/pull/3328))
* :bug: Fix validation error on parameters monkey ([#3309](https://github.com/tektoncd/pipeline/pull/3309))
* :bug: Use the test context in Reconcile tests ([#3285](https://github.com/tektoncd/pipeline/pull/3285))
* :bug: Accept CloudEvents in any order for CE reconcile test ([#3292](https://github.com/tektoncd/pipeline/pull/3292))
* :bug: Log cloud events to help debug issue 2992 ([#3282](https://github.com/tektoncd/pipeline/pull/3282))
* :bug: Refactor cancellation test ([#3266](https://github.com/tektoncd/pipeline/pull/3266))

<hr>