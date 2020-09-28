# OpenShift Pipelines TP-1.2

# Tekton Pipelines v0.16.3

## Fixes

* :bug: Fix nil pointer exception in case the PipelineRun timeout is not specified (nor default applied)timer_clock (https://github.com/tektoncd/pipeline/pull/3241)

<hr>

# Tekton Pipelines v0.16.2

## Upgrade Notices

When expressions will now work when combined with other more complicated DAG features!

## Fixes

When expression fixes for https://github.com/tektoncd/pipeline/pull/3196 https://github.com/tektoncd/pipeline/pull/3203 and https://github.com/tektoncd/pipeline/pull/3188:

* :bug: Fix to honor When expressions in presence of finally tasks. When expression parameters were not getting resolved in presence of finally tasks and were causing check to skip always return false. Applied fix to when expression parameters resolution function to make sure parameters are substituted with its respective values.
* :bug: Fix pipelinerun to apply task results to the leaf nodes of DAG before checking if its time to run finally tasks so that when expressions have resolved task results before the check.
* :bug: Fix pipelinerun to detect and terminate by only evaluating when expressions when all its parents are visited/done instead of evaluating in advance.
* :bug: Tasks with WhenExpressions using variable replacements were not executed when the WhenExpressions evaluate to false

Fix for https://github.com/tektoncd/pipeline/pull/3205:

* :bug: Omit potential NotFound events when cleaning up the Affinity Assistant

<hr>

# Tekton Pipelines v0.16.1

## Fixes

* :bug: This release fixes an issue with the cloud event delivery that lead to an increasingly high number of open (idle) connections towards the configured target URL. The fix is achieved by disabling keep-alive, which means that - at least for now - we will be setting up a new connection for every cloud event. This is the current behaviour too, only now old connections will be closed immediately. (https://github.com/tektoncd/pipeline/pull/3201, https://github.com/tektoncd/pipeline/pull/3215)

<hr>

# Tekton Pipelines v0.16.0

## Upgrade Notices

* :mega: The tekton-pipelines-controller and tekton-pipelines-controller are https://github.com/tektoncd/pipeline/releasesnow configured to run as a non-root user. (https://github.com/tektoncd/pipeline/pull/2967)

## Features

* :sparkles: Liveness and readiness probes are available for webhook. (https://github.com/tektoncd/pipeline/pull/3162)

* :sparkles: To run a Task only when certain criteria are met, it is now possible to guard task execution using
the when field, which allows you to list a series of references to WhenExpressions that contain
an Input, an Operator and Values. The valid Operators are in and notin. The WhenExpressions are ANDed. (https://github.com/tektoncd/pipeline/pull/3135)

* :sparkles: Update step statuses on TaskRun in event of cancellation or timeout (https://github.com/tektoncd/pipeline/pull/3088)

* :sparkles: fix(substition): fix configmap and secret volume param substition (https://github.com/tektoncd/pipeline/pull/3071)

* :sparkles: User can access the uid of the PipelineRun that a Pipeline is running in using context.pipelineRun.uid, User can access the uid of the TaskRun that a Task is running in using context.taskRun.uid, All context variables that are supported so far are now validated. (https://github.com/tektoncd/pipeline/pull/3017)

* :sparkles: Adding support for git-lfs repositories in git-init by adding the package in the git-init image (https://github.com/tektoncd/pipeline/pull/3006)

* :sparkles: The TaskRun.Status.ResourcesResult field now contains a URL for Git and Image PipelineResources, containing the URL of the resource data. (https://github.com/tektoncd/pipeline/pull/2975)

* :sparkles: Pipeline authors can now specify metadata while embedding tasks (using taskSpec) into their pipeline. (https://github.com/tektoncd/pipeline/pull/2826)

## Deprecation Notices

* rotating_light Conditions CRD deprecated, use WhenExpressions instead. (https://github.com/tektoncd/pipeline/pull/3135)

* rotating_light PipelineRun.Spec.ServiceAccountNames is being deprecated in favor of PipelineRun.Spec.TaskRunSpec[].ServiceAccountName (https://github.com/tektoncd/pipeline/pull/3028)

## Fixes

* :bug: Fixes a bug with validation for the Affinity Assistant when the same PVC is used for multiple workspaces but with different subPaths (https://github.com/tektoncd/pipeline/pull/3099)

* :bug: Fix an issue where PipelineRuns would pass validation even when a workspace binding was missing required volume info. (https://github.com/tektoncd/pipeline/pull/3096)

* :bug: When a TaskRun or PipelineRun completes, the go routine waiting for it to timeout will now stop (as it was designed to do!) instead of always re-reconciling (https://github.com/tektoncd/pipeline/pull/3078)

* :bug: The tekton-pipelines-controller and tekton-pipelines-controller are now configured to run as a non-root user. To match these reduced requirements, the tekton-pipelines PodSecurityPolicy updates its runAsUser rule to use MustRunAsNonRoot and is further tightened-up to only allow "use" in the tekton-pipelines namespace. (https://github.com/tektoncd/pipeline/pull/2967)

* :bug: Use ko:// in e2e tests to exercise current code upside_down_face (https://github.com/tektoncd/pipeline/pull/2902)

## Misc

* :hammer: PipelineRun.Spec.ServiceAccountNames is being deprecated in favor of PipelineRun.Spec.TaskRunSpec[].ServiceAccountName (https://github.com/tektoncd/pipeline/pull/3028)

* :hammer: Update the TestTaskRunStatus e2e test to work on s390x architectures. (https://github.com/tektoncd/pipeline/pull/3061)

* :hammer: Refactor Task Results Substitution (https://github.com/tektoncd/pipeline/pull/3169)

* :hammer: Refactor Pipeline Parameters Validation (https://github.com/tektoncd/pipeline/pull/3167)

* :hammer: Migrate some test builder references to structs (https://github.com/tektoncd/pipeline/pull/3124)

* :hammer: Don't set TTY:true in the place-scripts step used to power script mode.(https://github.com/tektoncd/pipeline/pull/3120)

* :hammer: Make this example actually run runner (https://github.com/tektoncd/pipeline/pull/3079)

* :hammer: Separate Step and Sidecar types (https://github.com/tektoncd/pipeline/pull/3077)

* :hammer: Fix an error formatting in taskrun reconciler (https://github.com/tektoncd/pipeline/pull/3073)

* :hammer: Remove the pkg/logging directory. (https://github.com/tektoncd/pipeline/pull/3058)

* :hammer: Add v0.14.3 links to docs and examples (https://github.com/tektoncd/pipeline/pull/3046)

* :hammer: Cleanup some code in artifact storage. (https://github.com/tektoncd/pipeline/pull/2965)

* :hammer: Remove /bin/ash from examples (https://github.com/tektoncd/pipeline/pull/3143)

* :hammer: Clean up test cases in pipelinerun_test.go (https://github.com/tektoncd/pipeline/pull/3134)

* :hammer: Add concurrency limit to roadmap (https://github.com/tektoncd/pipeline/pull/3130)

* :hammer: Allow to specify target cluster architecture for tests (https://github.com/tektoncd/pipeline/pull/3128)

* :hammer: Makefile: bump gosec and golangci version (https://github.com/tektoncd/pipeline/pull/3121)

* :hammer: Add multiarch specific fixes to the pipeline tests (https://github.com/tektoncd/pipeline/pull/3107)

* :hammer: Add yamllint check and fix errors (https://github.com/tektoncd/pipeline/pull/3101)

* :hammer: fix(typo): fix typos in docs (https://github.com/tektoncd/pipeline/pull/3093)

* :hammer: Allow skipping some YAML tests (https://github.com/tektoncd/pipeline/pull/3069)

* :hammer: The nop container image now includes the LICENSE and source code from vendor like the other images. (https://github.com/tektoncd/pipeline/pull/3042)

* :hammer: Add the nop image to the nightly pipeline release (https://github.com/tektoncd/pipeline/pull/3041)

* :hammer: Bump controller's image, nginx: 1.19.1, google/cloud-sdk: 302.0.0-slim (https://github.com/tektoncd/pipeline/pull/3002)

## Docs

* :book: Remove documentation advocating for test builders (https://github.com/tektoncd/pipeline/pull/3182)

* :book: Remove vendor-specific cluster setup instructions (https://github.com/tektoncd/pipeline/pull/3174)

* :book: Update--cluster-version flag (https://github.com/tektoncd/pipeline/pull/3165)

* :book: Fix typo in entrypoint folder (https://github.com/tektoncd/pipeline/pull/3153)

* :book: Add Conditions CRD to deprecated features list (https://github.com/tektoncd/pipeline/pull/3150)

* :book: Add documentation on how to install nightly releases. (https://github.com/tektoncd/pipeline/pull/3147)

* :book: Update Openshift installation documentation (https://github.com/tektoncd/pipeline/pull/3114)

* :book: Fix broken link in auth.md (https://github.com/tektoncd/pipeline/pull/3095)

* :book: Add docs link for 0.15.2 (https://github.com/tektoncd/pipeline/pull/3084)

* :book: Fix small typo in install doc for default workspace config (https://github.com/tektoncd/pipeline/pull/3074)

* :book: Rewrite the "Authentication" doc for clarity and flow. (https://github.com/tektoncd/pipeline/pull/3066)

* :book: Update Docker Desktop setup and separate out MiniKube setup (https://github.com/tektoncd/pipeline/pull/3065)

* :book: Add links to v0.15.1 docs (https://github.com/tektoncd/pipeline/pull/3062)

* :book: Include More Details on Pod Deletion for Cancelled/Timed Out TaskRuns (https://github.com/tektoncd/pipeline/pull/3053)

* :book: Add v0.15.0 links to docs and examples (https://github.com/tektoncd/pipeline/pull/3043)

* :book: Add initial documentation for Runs (https://github.com/tektoncd/pipeline/pull/2943)

<hr>

# Tekton Pipelines v0.15.2

## Fixes

* :bug: Ensure pullrequest-init is based on a root image (https://github.com/tektoncd/pipeline/pull/3055)

<hr>

# Tekton Pipelines v0.15.1

## Fixes

* :bug: Ensure pullrequest-init is based on a root image (https://github.com/tektoncd/pipeline/pull/3055)

<hr>

# Tekton Pipelines v0.15.0

## Upgrade Notices

* :mega: The minimum Kubernetes version is now 1.16. mega

## Known Issues

There is a known issue with PullRequest Resources in 0.15.0: Tasks that write a pr.json file to be used by an output PullRequest PipelineResource will see permission errors when run: The output PullRequest Resource will attempt to read the pr.json file but will not be able to because the injected PullRequest Step is not running as root. To workaround this issue in the short term you can modify permissions on the pr.json file to be world-readable (e.g. run chmod 777 on the pr.json file in your Step). A 0.15 point release is planned to address this issue.

## Features

* :sparkles: Use cloud event native retries for cloud event pipeline resource (https://github.com/tektoncd/pipeline/pull/3003)

    Cloud events sent via CloudEventPipelineResource now use retries with backoff.

* :sparkles: Add pipeline run support for cloud events (https://github.com/tektoncd/pipeline/pull/2938)

    Add cloud events for pipeline runs via the configuration option default-cloud-events-sink.

    When the default sink is setup, cloud events are sent, else they're disabled.

    Send cloud events (when enabled) from the pipeline run and controller, for all non-error
events that are already notified via k8s events.

* :sparkles: Add Default TaskRun Workspace Bindings to config-default (https://github.com/tektoncd/pipeline/pull/2930)

    Users can now set a default Workspace configuration for any Workspaces that a Task declares but that a TaskRun does not explicitly provide. It can be set in the config-defaults ConfigMap in default-task-run-workspace-binding.

* :sparkles: Add namespace variable interpolation for pipelinerun namespace and (https://github.com/tektoncd/pipeline/pull/2926)

    Add namespace variable interpolation in context. for pipelinerun namespace and taskrun namespace.

* :sparkles: Wire up webhook validation for Run objects (https://github.com/tektoncd/pipeline/pull/2916)

* :sparkles: Define a helper method pkg/controller.FilterRunRef (https://github.com/tektoncd/pipeline/pull/2915)

* :sparkles: Define v1alpha1 Run type and generated scaffolding (https://github.com/tektoncd/pipeline/pull/2871)

    Introduce the Run CRD. The new CRD will support the definition of new
kind of Tasks to be integrated in the pipelines.

    Runs are an experimental alpha feature and should be expected to change
in breaking ways or even be removed.

    Runs are not currently integrated with Pipelines, and require a running
third-party controller to actually perform any work. Without a third-party
controller, Runs will just exist without a status indefinitely.

* :sparkles: Validate TaskRun compatibility with the Affinity Assistant (https://github.com/tektoncd/pipeline/pull/2885)

    A TaskRun that mount more than one PVC-backed workspace is incompatible
with the Affinity Assistant. Validation has been added to handle this case.

* :sparkles: Allow variable substitution inside csi volumes parameters (https://github.com/tektoncd/pipeline/pull/2643)

    This PR allow to use parameters in CSI volume parameters.

* :sparkles: PR upload validates comment file extension (https://github.com/tektoncd/pipeline/pull/2462)

    Comment files under a PullRequest need to have either:no extension: for comment files that contain comment as plain text
.json extension: for comment files in JSON format


## Fixes
* :bug: Add omitempty for SchedulerName, ImagePullSecrets, HostNetwork (https://github.com/tektoncd/pipeline/pull/3032)

* :bug: Make string variable interpolation deterministic, and single-pass. (https://github.com/tektoncd/pipeline/pull/3024)

* :bug: Fix assignments to nil map issues (https://github.com/tektoncd/pipeline/pull/3001)

* :bug: Update shell-image to current gcr.io/distroless/base:debug SHA (https://github.com/tektoncd/pipeline/pull/2999)

* :bug: Use a hash of the workspace name in PVCs from template (https://github.com/tektoncd/pipeline/pull/2961)

* :bug: Remove ssh-keyscan from git credential initialization (https://github.com/tektoncd/pipeline/pull/2953)

* :bug: Dont write creds-init files if none of that type are mounted (https://github.com/tektoncd/pipeline/pull/2940)

* :bug: dep: update golang.org/x/text to v0.3.3 (https://github.com/tektoncd/pipeline/pull/2929)

* :bug: variable substitution in finally section (https://github.com/tektoncd/pipeline/pull/2908)

* :bug: change value of app.kubernetes.io/version label (https://github.com/tektoncd/pipeline/pull/2900)

* :bug: Include Task name in err message when validating (https://github.com/tektoncd/pipeline/pull/2899)

* :bug: cloudevent: make sure we enter the channel before… (https://github.com/tektoncd/pipeline/pull/2895)

* :bug: Fix TestTaskRunPipelineRunCancel failure (https://github.com/tektoncd/pipeline/pull/2850)

## Misc

* :hammer: Run TestReconcileTimeouts as separate tests alarm_clock (https://github.com/tektoncd/pipeline/pull/3030)

* :hammer: Add nop-image to release configs (https://github.com/tektoncd/pipeline/pull/3025)

* :hammer: Align release-generated .ko.yaml with repo config (https://github.com/tektoncd/pipeline/pull/3018)

* :hammer: Remove default flag values for image names (https://github.com/tektoncd/pipeline/pull/3016)

* :hammer: Add a minimal nop image (https://github.com/tektoncd/pipeline/pull/3014)

* :hammer: deleting hard coded taskrun controller name (https://github.com/tektoncd/pipeline/pull/3012)

* :hammer: Some timeout refactoring (https://github.com/tektoncd/pipeline/pull/3011)

* :hammer: Update the google/go-containerregistry library to an actual release. (https://github.com/tektoncd/pipeline/pull/2988)

* :hammer: Use filepath.Join instead of string formatting. (https://github.com/tektoncd/pipeline/pull/2985)

* :hammer: Change podconvert.MakePod func into a configuration struct with methods (https://github.com/tektoncd/pipeline/pull/2982)

* :hammer: Remove the "baseBuildOverrides" flag from .ko.yaml (https://github.com/tektoncd/pipeline/pull/2972)

* :hammer: Enable the "misspell" linter, and fix some misspellings. (https://github.com/tektoncd/pipeline/pull/2964)

* :hammer: Enable the deadcode linter in golangci, and clean up dead code. (https://github.com/tektoncd/pipeline/pull/2960)

* :hammer: Remove an unused line of code from oci/resolver.go (https://github.com/tektoncd/pipeline/pull/2959)

* :hammer: Add pipeline artifact config to the shared config store (https://github.com/tektoncd/pipeline/pull/2947)

* :hammer: Add some missing json annotations. (https://github.com/tektoncd/pipeline/pull/2920)

* :hammer: [master] Auto-update dependencies (https://github.com/tektoncd/pipeline/pull/2910)

* :hammer: Use sets.NewString from apimachinery (https://github.com/tektoncd/pipeline/pull/2909)

* :hammer: Stop using PATCH to update labels/annotations (https://github.com/tektoncd/pipeline/pull/2907)

* :hammer: refactoring pipelinerun unit test (https://github.com/tektoncd/pipeline/pull/2876)

* :hammer: Pick up the latest knative/pkg and K8s 0.17.x (https://github.com/tektoncd/pipeline/pull/2846)

* :hammer: Remove legacy Cluster Resource behavior left in place for the 0.14.0 … (https://github.com/tektoncd/pipeline/pull/2808)

* :hammer: Use MarkStatus* helpers in pkg/pod/status (https://github.com/tektoncd/pipeline/pull/2804)

* :hammer: Add a test to ensure that labels are updated as a part of TaskRun (https://github.com/tektoncd/pipeline/pull/2785)

* :hammer: Add kodata for the nop image (https://github.com/tektoncd/pipeline/pull/3042)

* :hammer: [master] Auto-update dependencies (https://github.com/tektoncd/pipeline/pull/3037)

* :hammer: Add .status.extraFields to the RunStatus type (https://github.com/tektoncd/pipeline/pull/2991)

* :hammer: tekton/release-pipeline: run test after precheck (https://github.com/tektoncd/pipeline/pull/2955)

* :hammer: Add Priti as an owner tada (https://github.com/tektoncd/pipeline/pull/2948)

* :hammer: Makefile: bump golangci-lint to 1.28.0 anchor (https://github.com/tektoncd/pipeline/pull/2904)

* :hammer: Makefile: add a cross target cactus (https://github.com/tektoncd/pipeline/pull/2903)

* :hammer: Update the pull_request_template for release-note :book: (https://github.com/tektoncd/pipeline/pull/2882)

* :hammer: Use OWNER_ALIASES defined teams and add area/* labels (https://github.com/tektoncd/pipeline/pull/2839)

* :hammer: Google/ko 5.0+ requires images to be prefixed by ko:// . (https://github.com/tektoncd/pipeline/pull/2675)

## Docs

* :book: small typo fix (https://github.com/tektoncd/pipeline/pull/3040)

* :book: follow on from PR 3010, formatting fix and updating resource requirements for minikube (https://github.com/tektoncd/pipeline/pull/3034)

* :book: Remove mention of ssh-keygen from auth doc (https://github.com/tektoncd/pipeline/pull/3033)

* :book: Document using custom SSH port for git repos (https://github.com/tektoncd/pipeline/pull/3022)

* :book: Fixes https://github.com/tektoncd/pipeline/issues/2971, adding a section to the tutorial for using minikube when running locally (https://github.com/tektoncd/pipeline/pull/3010)

* :book: Rewrite the Knative Build migration guide for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2996)

* :book: Fix: host.docker.internal instead of host.docker.local (https://github.com/tektoncd/pipeline/pull/2993)

* :book: fixes 2978, missing command in monitoring steps (https://github.com/tektoncd/pipeline/pull/2990)

* :book: Rewrite the "Pod Templates" documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2983)

* :book: TUTORIAL: Fix docker registry credentials issue (https://github.com/tektoncd/pipeline/pull/2980)

* :book: README: fix typo with doc text (https://github.com/tektoncd/pipeline/pull/2976)

* :book: Fix minor format issues (https://github.com/tektoncd/pipeline/pull/2963)

* :book: README.md: add v0.14.1 and v0.14.2 release, docs links (https://github.com/tektoncd/pipeline/pull/2956)

* :book: Rewrites the "Labels" documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2946)

* :book: Flesh out the docs on using results in Pipelines (https://github.com/tektoncd/pipeline/pull/2945)

* :book: Document that Task Results dont get trimmed (https://github.com/tektoncd/pipeline/pull/2942)

* :book: Rewrite the "Logs" documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2939)

* :book: Document all locations that variable substitution is available (https://github.com/tektoncd/pipeline/pull/2927)

* :book: Fix a typo in development.md file (https://github.com/tektoncd/pipeline/pull/2923)

* :book: Rewrite the "Events" documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2919)

* :book: Rewrite the "Container Contract" documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2914)

* :book: Rewrite the "Metrics" documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2913)

* :book: Add extended documentation about PersistentVolumes within a PipelineRun (https://github.com/tektoncd/pipeline/pull/2912)

* :book: Fix documentation about cloudevents (https://github.com/tektoncd/pipeline/pull/2911)

* :book: Update README docs pointing to 0.14.0 release (https://github.com/tektoncd/pipeline/pull/2896)

* :book: Fix documentation about tasks (https://github.com/tektoncd/pipeline/pull/2893)

* :book: Improve workspace documentation (https://github.com/tektoncd/pipeline/pull/2890)

* :book: Rewrite the Condition documentation for clarity and flow. (https://github.com/tektoncd/pipeline/pull/2867)

<hr>
