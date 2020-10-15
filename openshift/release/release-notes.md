# Tekton Pipelines v0.17.1

## Fixes

* :bug: [cherry-pick] Fix the logic for the disable-ha flag [(#3371)](https://github.com/tektoncd/pipeline/pull/3371) 

Default behaviour for leader-election-ha has been restored to "enabled".
The controller flag disable-ha will now disable HA support when set to true.

* :bug: [cherry-pick] Only send cloud events when condition changes [(#3370)](https://github.com/tektoncd/pipeline/pull/3370)

Fixes issue with duplicate cloud events. Cloud events are now sent only if a change in condition happened.

* :bug: [cherry-pick] Take -version into account in the controller coffee [(#3369)](https://github.com/tektoncd/pipeline/pull/3369)

Correctly set the release annotation on TaskRun based on the currently running pipeline instance version

* :bug: [cherry-pick] config: fix runAsUser inconsistency with images ice_cream [(#3368)](https://github.com/tektoncd/pipeline/pull/3368)

Fix inconsistent uid for the controller and webhook deployment, resulting in failure of installing tekton pipeline on minikube (and other platforms.)

<hr>

# Tekton Pipelines v0.17.0


## Features
* :sparkles: Base entrypoint image on distroless [(#3286)](https://github.com/tektoncd/pipeline/pull/3286)
Binary file (standard input) matches

* :sparkles: Provide configuration option to disallow omitting known_hosts [(#3283)](https://github.com/tektoncd/pipeline/pull/3283)
Provide configuration option to disallow omitting known_hosts in Git SSH Secret.

* :sparkles: Introduce Optional Workspaces [(#3274)](https://github.com/tektoncd/pipeline/pull/3274)
Introduce optional workspaces: A Task or Pipeline may declare a workspace optional and conditionally change their behaviour based on its presence. A TaskRun or PipelineRun may omit that workspace and thereby modify the Task or Pipeline behaviour.

* :sparkles: Update CRD definition to use apiextensions v1 [(#3236)](https://github.com/tektoncd/pipeline/pull/3236)
Update CRD to use apiextensions.k8s.io/v1 instead of v1beta1

* :sparkles: Bump knative to enable new features [(#3181)](https://github.com/tektoncd/pipeline/pull/3181)
knative is upgraded to a more recent version

* :sparkles: Make DefaultThreadsPerController, QPS and Burst configurable via flags [(#3156)](https://github.com/tektoncd/pipeline/pull/3156)
Allows DefaultThreadsPerController, QPS, and Burst to be configured via flags

* :sparkles: Fix(git): add warning of the mismatch of git cred and url [(#3136)](https://github.com/tektoncd/pipeline/pull/3136)
Fix(git): Tekton's credentials initialization now detects when an SSH credential is used with a non-SSH URL (and vice versa) in Git PipelineResources and will log a warning in Step containers.

* :sparkles: Add minimal initial API spec document [(#3131)](https://github.com/tektoncd/pipeline/pull/3131)
Add initial minimal API specification document

* :sparkles: Emit an event if overwriting PodTemplate affinity [(#2859)](https://github.com/tektoncd/pipeline/pull/2859)

* :sparkles: Add cloud events to metrics [(#2720)](https://github.com/tektoncd/pipeline/pull/2720)

* :sparkles: Run enhancements [(#3313)](https://github.com/tektoncd/pipeline/pull/3313)

* :sparkles: Introducing InternalTektonResultType as a ResultType [(#3138)](https://github.com/tektoncd/pipeline/pull/3138)

## Fixes

* :bug: Replace variables in Sidecar Script block [(#3318)](https://github.com/tektoncd/pipeline/pull/3318)
Fixed issue where script blocks in sidecars didn't have their variables replaced.

* :bug: Fix issue where workspace volume variable and pod volume conf differ [(#3315)](https://github.com/tektoncd/pipeline/pull/3315)
Fixed a bug where a workspace's volume name did not match the value from workspace..volume variables.

* :bug: Sort pod container statuses based on Step order in taskSpec [(#3256)](https://github.com/tektoncd/pipeline/pull/3256)
Steps in the TaskRun status field are now sorted according to the Step order specified in the taskSpec

* :bug: Fix version label on created pods point_down [(#3193)](https://github.com/tektoncd/pipeline/pull/3193)
Fix version label on created pods

* :bug: default service account [(#3168)](https://github.com/tektoncd/pipeline/pull/3168)
Service account when missing from pipelinerun/taskrun spec and ConfigMap, controller sets it to default in the spec.

* :bug: Add support for repeated PVC-claim but using subPath in AA-validation [(#3099)](https://github.com/tektoncd/pipeline/pull/3099)
Fixes a bug with validation for the Affinity Assistant when the same PVC is used for multiple workspaces but with different subPaths

* :bug: Fix annotation on v1beta1 field. [(#3328)](https://github.com/tektoncd/pipeline/pull/3328)
* :bug: Fix validation error on parameters monkey [(#3309)](https://github.com/tektoncd/pipeline/pull/3309)
* :bug: Use the test context in Reconcile tests [(#3285)](https://github.com/tektoncd/pipeline/pull/3285)
* :bug: Accept CloudEvents in any order for CE reconcile test [(#3292)](https://github.com/tektoncd/pipeline/pull/3292)
* :bug: Log cloud events to help debug issue 2992 [(#3282)](https://github.com/tektoncd/pipeline/pull/3282)
* :bug: Refactor cancellation test [(#3266)](https://github.com/tektoncd/pipeline/pull/3266)

## Misc

* :hammer: Derive cancel patch bytes once at controller startup [(#3316)](https://github.com/tektoncd/pipeline/pull/3316)
Fail more loudly at controller startup when we fail to marshal the JSON Patch request to cancel TaskRuns owned by cancelled PipelineRuns.

* :hammer: Remove test builders from validate_params_test.go [(#3281)](https://github.com/tektoncd/pipeline/pull/3281)

* :hammer: Replace google/cloud-sdk with GCR equivalent. [(#3280)](https://github.com/tektoncd/pipeline/pull/3280)

gcloud images now use GCR hosted equivalent instead of DockerHub.

* :hammer: Enhance v1beta1 validation code for pipelinerun cocktail [(#3279)](https://github.com/tektoncd/pipeline/pull/3279)
Binary file (standard input) matches

* :hammer: Enhance v1beta1 validation code for pipeline cocktail [(#3277)](https://github.com/tektoncd/pipeline/pull/3277)
Binary file (standard input) matches

* :hammer: Enhance v1beta1 validation code for taskrun cocktail [(#3270)](https://github.com/tektoncd/pipeline/pull/3270)
Binary file (standard input) matches

* :hammer: Enhance v1beta1 validation code for clustertask cocktail [(#3268)](https://github.com/tektoncd/pipeline/pull/3268)
Binary file (standard input) matches

* :hammer: Omit cleaning up the Affinity Assistant if disabled [(#3214)](https://github.com/tektoncd/pipeline/pull/3214)

* :hammer: Enhance v1beta1 validation code for task cocktail [(#3185)](https://github.com/tektoncd/pipeline/pull/3185)

Binary file (standard input) matches

* :hammer: tekton: migrate release task and pipeline to v1beta1 [(#3106)](https://github.com/tektoncd/pipeline/pull/3106)
Release pipeline and tasks are now using the v1beta1 API

* :hammer: refactoring pipelinerunstate - no logic changed at all [(#3326)](https://github.com/tektoncd/pipeline/pull/3326)
* :hammer: Add missing json annotations (#3291)
* :hammer: test: remove extra logs in task_validation_test.go [(#3290)](https://github.com/tektoncd/pipeline/pull/3290)
* :hammer: Include golang version in docs. [(#3272)](https://github.com/tektoncd/pipeline/pull/3272)
* :hammer: Remove unused test builder methods [(#3261)](https://github.com/tektoncd/pipeline/pull/3261)
* :hammer: Remove test builders from pipelinerun cancel_test.go [(#3260)](https://github.com/tektoncd/pipeline/pull/3260)
* :hammer: Remove test builders from apply_test.go [(#3259)](https://github.com/tektoncd/pipeline/pull/3259)
* :hammer: refactoring PipelineRunState to simplify logic for retrieving next tasks [(#3254)](https://github.com/tektoncd/pipeline/pull/3254)
* :hammer: Remove test builders from v1alpha1/pipeline_validation_test.go [(#3250)](https://github.com/tektoncd/pipeline/pull/3250)
* :hammer: Clean up metrics_test.go [(#3247)](https://github.com/tektoncd/pipeline/pull/3247)
* :hammer: Apply replacements in tasks and finally tasks separately [(#3244)](https://github.com/tektoncd/pipeline/pull/3244)
* :hammer: pkg/*: remove more v1alpha1 reference. [(#3233)](https://github.com/tektoncd/pipeline/pull/3233)
* :hammer: refactoring - pipelinerunstate [(#3231)](https://github.com/tektoncd/pipeline/pull/3231)
* :hammer: Clean up dag_test.go [(#3230)](https://github.com/tektoncd/pipeline/pull/3230)
* :hammer: Clean up examples_test.go [(#3229)](https://github.com/tektoncd/pipeline/pull/3229)
* :hammer: Remove test builder references from test/**/adoc.go [(#3228)](https://github.com/tektoncd/pipeline/pull/3228)
* :hammer: pkg/{termination,pod,reconciler}: use v1beta1 struct sake [(#3222)](https://github.com/tektoncd/pipeline/pull/3222)
* :hammer: Clean up multiarch_utils.go [(#3200)](https://github.com/tektoncd/pipeline/pull/3200)
* :hammer: Clean up e2e entrypoint_test.go [(#3199)](https://github.com/tektoncd/pipeline/pull/3199)
* :hammer: Clean up e2e Git PipelineResource tests [(#3198)](https://github.com/tektoncd/pipeline/pull/3198)
* :hammer: Update e2e cancellation tests [(#3195)](https://github.com/tektoncd/pipeline/pull/3195)
* :hammer: Remove tb.ArrayOrString [(#3184)](https://github.com/tektoncd/pipeline/pull/3184)
* :hammer: Remove release-note block indentation in PR template taco [(#3269)](https://github.com/tektoncd/pipeline/pull/3269)
* :hammer: Change git pipeline tests for s390x [(#3265)](https://github.com/tektoncd/pipeline/pull/3265)
* :hammer: Makefile: fix the all target circus_tent [(#3191)](https://github.com/tektoncd/pipeline/pull/3191)
* :hammer: TestReconcile_ExplicitDefaultSA flakiness fix fallen_leaf [(#3189)](https://github.com/tektoncd/pipeline/pull/3189)

## Docs
* :book: Fix the pipelinerun docs about completion time [(#3332)](https://github.com/tektoncd/pipeline/pull/3332)
Fixed incorrect documentation about pipeline run completion time and status.

* :book: Add docs demonstrating how to share a Workspace with Sidecars [(#3322)](https://github.com/tektoncd/pipeline/pull/3322)
Added an example and documentation showing how to share a Workspace between Steps and Sidecars in a Task.

* :book: Add a short example of using optional workspaces in when expressions [(#3308)](https://github.com/tektoncd/pipeline/pull/3308)
Added a short example of using optional workspaces in when expressions.

* :book: Fix some typos in docs [(#3297)](https://github.com/tektoncd/pipeline/pull/3297)

* :book: Update variables.md to mention the risk of not escaping your own parameters. [(#3296)](https://github.com/tektoncd/pipeline/pull/3296)

* :book: Update Release Cheet Sheat, remove instructions from README [(#3252)](https://github.com/tektoncd/pipeline/pull/3252)

Removed release directions from README in favor of release-cheat-sheet.

* :book: Move metadata under taskSpec in the documentation [(#3246)](https://github.com/tektoncd/pipeline/pull/3246)

* :book: Rename Artifact Storage to PipelineResource Storage in install doc [(#3209)](https://github.com/tektoncd/pipeline/pull/3209)

Clarified storage configuration for PipelineResources in install doc

* :book: Change Timeout Field [(#3157)](https://github.com/tektoncd/pipeline/pull/3157)

* :book: Add a clarifying comment to new workspace test [(#3329)](https://github.com/tektoncd/pipeline/pull/3329)

* :book: Add a short note documenting the new git ssh secret feature flag [(#3294)](https://github.com/tektoncd/pipeline/pull/3294)

* :book: Improve documetation for entrypoint binary [(#3288)](https://github.com/tektoncd/pipeline/pull/3288)

* :book: Adding link to documentation on supported fields for pod templates. [(#3284)](https://github.com/tektoncd/pipeline/pull/3284)

* :book: Reorganize Developing.md sections (fix for [#3263](https://github.com/tektoncd/pipeline/pull/3263)) [(#3264)](https://github.com/tektoncd/pipeline/pull/3264)

* :book: Add 0.16.3 docs link memo [(#3248)](https://github.com/tektoncd/pipeline/pull/3248)

* :book: Add docs for v0.16.x memo [(#3216)](https://github.com/tektoncd/pipeline/pull/3216)

* :book: Add nop-image to release instructions [(#3186)](https://github.com/tektoncd/pipeline/pull/3186)

* :book: Add results path variable to results docs [(#3144)](https://github.com/tektoncd/pipeline/pull/3144)