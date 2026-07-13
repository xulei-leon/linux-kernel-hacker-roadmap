# DVFS, Thermal, and Performance Validation

**Status:** Blueprint. The method is current; measurements and regression
conclusions remain planned.

## Goal and scope

Build a repeatable validation harness that explains how controlled CPU loads,
frequency behavior, temperature, throttling indicators, and workload results
change together on an identified Orin system. It is a measurement project, not
a promise of a particular clock, temperature, or performance level.

Use documented Linux interfaces and existing tools. Do not guess hidden power
states, change undocumented controls, or compare different software, cooling,
or power configurations as if they were equivalent.

## Experiment design

- `capture-environment` records the platform and software baseline identifiers,
  kernel and BSP, CPU
  topology, active frequency driver/governor, online CPUs, power mode, cooling
  setup, ambient-temperature method, workload versions, and command lines.
- `run-trial` reserves the manifest's `sampler_cpu` for the harness and pins
  workloads to the disjoint `workload_cpus`. It launches each workload as a
  dedicated process group and enables `prctl(PR_SET_CHILD_SUBREAPER, 1)`. The
  throughput command is
  `taskset --cpu-list $workload_cpus stress-ng --cpu $workload_cpu_count
  --cpu-method matrixprod --timeout 300s --verify --metrics-brief`. The latency
  command is `taskset --cpu-list $latency_cpu cyclictest --duration=300s
  --mlockall --priority=80 --interval=1000 --histogram=10000 --quiet`, run with
  the recorded privilege needed for real-time scheduling. Any histogram
  overflow invalidates that latency trial.
- `sample`, pinned to `sampler_cpu`, timestamps with `CLOCK_MONOTONIC_RAW` every
  200 ms. It reads each `policy*/scaling_cur_freq`, `scaling_min_freq`,
  `scaling_max_freq`, `scaling_governor`, `scaling_driver`, and `related_cpus`
  under `/sys/devices/system/cpu/cpufreq/`; every
  `/sys/class/thermal/thermal_zone*/{type,temp}`; and every available
  `/sys/class/thermal/cooling_device*/{type,cur_state}`. Interface absence is
  recorded, not estimated. An independent thermometer writes `ambient.csv` at
  1 Hz; its model, accuracy, location, and actual collection command are part
  of the manifest.
- `analyze` uses `stress-ng` bogo operations/second as throughput and derives
  cyclictest p99.9 latency in microseconds from its histogram. Versions and
  parsers are fixed in the manifest. It preserves every trial and never drops
  an outlier except through a predeclared invalidation rule.
- `compare` evaluates a candidate against a named baseline using pre-registered
  thresholds and evidence-quality gates.

Signal requirements are fixed before the run:

| Signal | Requirement | Missing-signal decision |
|---|---|---|
| `policy*/scaling_cur_freq`, min/max, governor, driver, and CPU membership | Required for a DVFS claim | Overall DVFS/thermal result is `INCONCLUSIVE`; workload metrics remain descriptive only. |
| Thermal-zone `type` and `temp`, plus the 1 Hz ambient log | Required for a thermal claim and safety stop | Overall DVFS/thermal result is `INCONCLUSIVE`; do not claim thermal behavior. |
| Cooling-device `type` and `cur_state` | Optional supporting context | Report absence and omit cooling-state conclusions. |
| Supported `perf stat` counters | Optional explanatory evidence | Report only collected events; do not infer missing counters. |
| Public BSP-specific throttling or power signals | Optional platform evidence | Name the documented interface and narrow the claim to that signal. |

Preflight resolves the required paths before any scored workload starts. If a
required cpufreq, thermal, or ambient signal is unavailable, the run records
`INCONCLUSIVE` and does not start measured trials; optional-signal absence does
not block them.

Each command gets one unscored 60-second warm-up by changing only its
timeout/duration to 60 seconds, then at least five 300-second measured trials
per configuration. Before each trial, cool until every monitored zone stays
within 2 degrees C of its recorded pre-experiment idle median for 30 continuous
seconds, with a 10-minute timeout. Randomize order with a stored seed; if
randomization is unavailable, use the deterministic ten-trial sequence
`A B B A A B B A A B` for baseline A and candidate B.

The independent variable is exactly one kernel candidate artifact set. The
manifest enumerates and hashes every compared `Image`, module artifact, `DTB`,
and `DTBO`; only explicitly listed members may differ between baseline and
candidate, and at least one must differ. Each allowed module file is
content-hashed, and each symlink target, mode, owner, and destination under the
enumerated `/lib/modules/<release>/` roots is recorded.

Both configurations start from one verified, read-only base rootfs image or
snapshot. The manifest records its immutable identifier, byte size, SHA-256,
storage URI, filesystem type, and verification command. Every measured trial
gets a fresh disposable writable overlay; each member of an A/B pair gets its
own overlay from that same base. Setup installs only the enumerated module
artifacts for that configuration. Before boot, the harness inventories the
clean overlay and rejects it unless differences between baseline and candidate
are confined to those enumerated module destinations. Runtime-mutated files,
including logs, caches, temporary files, and harness state, live only in the
writable overlay and are not treated as candidate artifacts.

After each trial, the harness exports evidence to the external evidence store,
unmounts and discards the overlay, verifies that the base rootfs hash is
unchanged, and creates a new overlay before the next trial. A failed export,
unmount/discard, base-hash check, clean-overlay inventory check, or reuse of an
old overlay invalidates the trial and blocks further scored trials until reset
succeeds. The manifest fixes `rootfs_base_id`, `rootfs_base_uri`,
`rootfs_base_size_bytes`, `rootfs_base_sha256`, `rootfs_fstype`,
`rootfs_verify_command`, `overlay_backend`, `overlay_reset_scope: trial`, the
external `evidence_store`, and the baseline/candidate `module_artifacts` lists.
Per-trial metadata records the unique overlay ID, parent base ID, clean-overlay
inventory hash, creation/discard status, and post-trial base verification.

Board, boot firmware, user-space tools and libraries, workload binaries and
inputs, and every unlisted kernel artifact remain byte-identical. CPU online
mask, affinity, governor, frequency min/max, power mode, fan setting, cooling
setup, sampling, and privilege also remain identical. Start-temperature
tolerance is the 2 degrees C cooldown rule; ambient maximum minus minimum must
be at most 2 degrees C within a ten-trial block. Any controlled-field mismatch,
ambient drift greater than 2 degrees C, sample loss above 1%, or sample gap
above 1 second invalidates the affected block.

## Inputs, outputs, and failure semantics

Inputs are an experiment manifest, immutable workload assets, sampling
configuration, baseline identifier, candidate identifier, and the observed
system interfaces.

Outputs are the manifest, environment capture, per-trial raw time series,
workload stdout/stderr and exit status, derived metrics, plots/tables, and a
machine-readable comparison decision. Raw evidence is retained unchanged;
derived files name their source trial IDs.

A trial is invalid if setup drifts, the workload fails, timing exceeds its
bound, the histogram overflows, or the system reboots/suspends. Invalid trials
remain in the evidence set but do not enter statistics. The complete experiment
is `INCONCLUSIVE` when fewer than five valid trials per configuration remain,
a block-level control fails, a required signal is missing, or a required
baseline median is zero.

For valid per-trial values `xi`, dispersion is median absolute deviation in the
metric's units: `MAD = median(abs(xi - median(x)))`. Throughput degradation is
`100 * (baseline_median - candidate_median) / baseline_median`; latency
degradation is `100 * (candidate_median - baseline_median) / baseline_median`.
A metric is `REGRESSION` only when degradation is strictly greater than 5% and
the absolute median difference is strictly greater than
`max(baseline_MAD, candidate_MAD)`. Equality at either boundary is
`NO_REGRESSION`; MAD zero is valid, while fewer than five values or a zero
baseline median is `INCONCLUSIVE`. The overall result uses the highest-priority
outcome: `INCOMPLETE_CLEANUP`, `SAFETY_STOP`, `INCONCLUSIVE`, `REGRESSION`, then
`NO_REGRESSION`.

The manifest sets a per-zone thermal stop from a cited board limit or a lower
project safety limit. Reaching or exceeding any limit sends `SIGTERM` to the
dedicated workload process group with `kill(-pgid, SIGTERM)`, then
`kill(-pgid, SIGKILL)` after five seconds. A manifest field
`cleanup_deadline_ms` sets the monotonic hard deadline covering TERM, KILL, and
`waitpid(-pgid, ..., WNOHANG)` polling; manifest validation requires it to be
greater than 5000 ms so a post-`SIGKILL` reap window exists. If every child is
reaped by that deadline, the harness closes the trial, aborts the remaining
block, and records `SAFETY_STOP`. Otherwise it records surviving PIDs, PGID,
last observed process states, and signals, then returns
`INCOMPLETE_CLEANUP` with a nonzero process exit. `INCOMPLETE_CLEANUP` overrides
statistical outcomes; the report retains the thermal trigger as a secondary
reason. Thresholds may change only in a new manifest revision created before
another measurement.

## Test layers

1. Unit tests cover manifest validation, timestamp alignment, invalid-trial
   rules, rootfs/overlay manifest fields, statistics, and exact threshold
   boundaries using fixtures.
2. Harness tests use synthetic samplers and workloads to force timeout,
   required/optional missing-data, process-group thermal-stop/reap, and
   cleanup-deadline survivor reporting and nonzero-exit behavior.
3. Host smoke tests verify evidence layout and analysis without creating Orin
   performance claims.
4. Orin pilot tests validate the exact commands, interfaces, 200 ms sampler,
   1 Hz ambient log, affinity, sampling overhead, safety stop, and cooldown
   criteria before scored trials.
5. Repeated baseline/candidate runs verify order control, raw-data retention,
   fresh-overlay creation and disposal, clean-overlay difference checks,
   immutable-base hash checks, reproducible analysis, and regression decisions.

## Required artifacts

- Versioned experiment manifests, harness and analysis source, build/run
  instructions, and dependency versions.
- Baseline/candidate artifact inventories and hashes proving the enumerated
  kernel artifact set is the only pre-boot software difference, plus the base
  rootfs hash and per-trial overlay reset/check records.
- Unmodified raw evidence for every valid and invalid trial plus checksums.
- Environment-difference report and sampling-overhead measurement.
- Baseline/candidate summary with per-metric medians, MAD in native units,
  percentage degradation, thresholds, outcome precedence, and limits on
  interpretation.
- One injected harness failure and one real measurement anomaly investigation,
  each with diagnosis and retest or disposition.
- Five-minute demo that starts a bounded trial, shows live evidence, and
  reproduces the comparison from retained raw data.

## Milestones

1. Freeze manifest, evidence layout, invalidation rules, safety stop, and
   comparison policy.
2. Implement validated capture, trial control, and synthetic failure tests.
3. Implement reproducible analysis and threshold-boundary tests.
4. Pilot on Orin, measure harness overhead, and fix control drift.
5. Run repeated trials, investigate anomalies, publish the decision, and
   rehearse the demo.

## Acceptance criteria

- The same manifest and raw inputs reproduce the same derived metrics and
  decision.
- Each comparison has at least five valid trials per configuration and retains
  excluded trials with machine-readable reasons.
- Baseline and candidate controlled fields and tolerances pass exactly, or the
  result is `INCONCLUSIVE`; any thermal safety stop reports `SAFETY_STOP`
  regardless of available statistics unless incomplete cleanup takes
  precedence.
- Every scored trial starts from a newly created overlay of the verified base
  rootfs; clean-overlay differences are limited to enumerated module
  artifacts, and evidence export, overlay discard, and post-trial base-hash
  verification succeed.
- Required cpufreq and thermal/ambient signals are complete for DVFS/thermal
  conclusions; optional counter or BSP evidence is labeled and only supports
  claims about the interfaces actually collected.
- Timeout, workload failure, missing samples, and thermal-stop paths are tested
  and leave usable evidence.
- Cleanup never waits beyond `cleanup_deadline_ms`; unreaped children produce
  nonzero `INCOMPLETE_CLEANUP` with survivor evidence and override statistics.
- The final report states thresholds before results, shows dispersion and raw
  data links, and labels all platform-specific claims as Orin/ARM64 evidence.
