# CPU/SoC Health Diagnostic Suite

**Status:** Blueprint. The design is current; an implemented suite and Orin
results remain planned.

## Goal and scope

Build a modular C++17 command-line suite that runs bounded CPU and SoC health
checks, preserves evidence, and makes unsupported checks explicit. This is a
diagnostic framework, not a claim to NVIDIA-private production diagnostics.

The first release supports Linux on ARM64 Orin and a host-only test path. It
may read documented kernel interfaces such as `sysfs`, `procfs`, and debugfs
when explicitly enabled. It does not write registers, change clocks, run
destructive memory tests, or infer Tegra behavior from x86_64 results.

## Design

Keep these components independently testable:

- `diag-core`: plugin interface, result schema, deadlines, cancellation, and
  process exit policy.
- `diag-runner`: plugin selection, worker-process lifecycle, per-plugin timeout,
  suite deadline, and bounded evidence capture.
- `diag-worker`: loads exactly one plugin in a child process and returns one
  length-bounded result over a private pipe. Plugin code never runs in the
  runner process.
- `diag-report`: deterministic JSON plus a concise console summary; JSON is
  written atomically by a separate bounded reporter process.
- `platform-probe`: records architecture, board identity, kernel, device-tree
  compatibility, permissions, and available kernel interfaces.
- Plugins: CPU topology/online state, frequency-policy consistency, thermal
  zone readability, machine-check or RAS evidence when a documented interface
  exists, and a synthetic self-test plugin for failure-path testing.

Each plugin returns one terminal result: `PASS`, `WARN`, `FAIL`, or `SKIP`.
It also returns a stable check ID, start/end timestamps, observations, bounded
evidence references, and a reason code. Each worker receives an immutable
platform snapshot and output budget; it does not format the suite report.

The runner starts one worker process group per invocation with bounded result,
stdout, and stderr pipes; the worker also requests parent-death `SIGKILL`. At a
plugin or suite deadline the runner sends a cancellation message, waits the
configured cooperative grace period, signals the process group with `SIGTERM`,
waits a second grace period, then sends `SIGKILL`. All waits use monotonic
deadlines and `waitpid(..., WNOHANG)`; the runner never makes an unbounded reap
wait. A worker still unreaped at the hard deadline is recorded by PID as
incomplete cleanup, but cannot delay report generation. Output beyond its byte
limit is drained and discarded with a truncation marker.

## Inputs, outputs, and failure semantics

Inputs are a versioned configuration file, CLI overrides, the recorded
platform baseline, and documented Linux interfaces. The versioned configuration
fixes enabled plugins, thresholds, per-plugin timeout, suite deadline, evidence
size limit, `cancel_grace_ms`, `term_grace_ms`, and
`report_write_allowance_ms`. The last value is the reporter process's total
hard deadline, including termination and nonblocking reap.

Outputs are:

- `report.json`, validated against a versioned schema;
- a console table with the same terminal states and reason codes;
- `environment.json` and bounded raw evidence files referenced by the report;
- a run log containing plugin start, deadline, cancellation, and completion.

State meanings are fixed:

- `PASS`: supported check ran to completion and met its criteria.
- `WARN`: check completed, but a non-fatal threshold or evidence-quality issue
  needs review.
- `FAIL`: supported check found a health violation or an internal execution
  error that invalidates the check.
- `SKIP`: the interface, permission, platform, or prerequisite is unsupported;
  absence of support is never reported as `PASS`.

A valid worker result maps directly to its terminal state. A plugin exception,
malformed result, abnormal exit, or signal before timeout is `FAIL` with a
specific worker reason. A plugin timeout is `FAIL` with `PLUGIN_TIMEOUT`.
Suite-deadline exhaustion sets an overall failure flag regardless of completed
plugin states: started checks become `FAIL` with
`SUITE_DEADLINE_EXCEEDED`, and checks not started become `FAIL` with
`SUITE_DEADLINE_NOT_STARTED`. Deadline exhaustion always exits nonzero.

After aggregation, the runner gives the reporter process exactly
`report_write_allowance_ms` to write a temporary JSON file, `fsync()` it, and
rename it over `report.json`. At timeout the runner sends `SIGKILL`, polls reap
without blocking, marks `REPORT_WRITE_TIMEOUT`, and exits nonzero. It makes one
best-effort nonblocking `write()` of a fixed, sub-512-byte error containing the
run ID and reason to stderr; `EAGAIN` cannot extend runtime. A `WARN`-only run
exits zero unless strict mode is selected. Malformed configuration or an
unwritable output directory fails before plugin execution.

## Test layers

1. Unit tests cover result transitions, schema serialization, threshold
   boundaries, deadline arithmetic, and evidence truncation.
2. Contract tests run fake worker plugins for pass, warning, exception,
   malformed IPC, cooperative cancellation, ignored `SIGTERM`, forced
   `SIGKILL`, never-started deadline failure, and unsupported-interface
   behavior.
3. Host integration tests use fixture trees instead of claiming host facts as
   Orin behavior.
4. Orin integration tests consume the platform and software baseline evidence
   and run read-only
   checks on the identified ARM64 target.
5. End-to-end tests compare console and JSON states and verify bounded runtime,
   output limits, deadline exit codes, reporter timeout/atomic rename, minimal
   stderr fallback, and interrupted-run evidence.

## Required artifacts

- C++17 source, build instructions, dependency versions, and configuration
  examples.
- Versioned JSON schema and sample `PASS`, `WARN`, `FAIL`, and `SKIP` reports.
- Unit/contract test output and an Orin run tied to the recorded baselines.
- One reproducible injected failure with hypothesis, diagnosis, fix or
  disposition, and retest.
- Design note covering plugin isolation, timeout policy, evidence bounds, and
  why unsupported observations are not success.
- Five-minute demo script and cleanup instructions.

## Milestones

1. Freeze result schema, reason codes, configuration, exit policy, and fake
   plugin contracts.
2. Implement core runner, deadlines, deterministic reporters, and unit tests.
3. Add platform probing and the first read-only plugins using fixtures.
4. Run on Orin, record unsupported paths honestly, and tune only documented
   thresholds.
5. Capture failure evidence, complete the design review, and rehearse the demo.

## Acceptance criteria

- A clean build runs with C++17 and all unit and contract tests pass.
- Every enabled plugin reaches exactly one terminal state. With `N` configured
  sequential plugins, suite runtime is bounded by the suite deadline plus the
  two configured termination grace periods and report-write allowance; a
  worker that ignores cancellation cannot extend that bound.
- Suite-deadline exhaustion and report-write timeout each produce a nonzero
  exit independently of plugin states; no deadline-blocked check is `SKIP`.
- JSON validates against the checked-in schema and agrees with console output.
- Evidence and logs remain within configured limits, including timeout cases.
- Orin results name the board, ARM64 architecture, kernel, configuration, and
  source interfaces; host fixtures are labeled non-Orin.
- The project evidence contains success, unsupported, warning, and injected-failure
  evidence plus a retest, without private-interface or hardware-health claims.
