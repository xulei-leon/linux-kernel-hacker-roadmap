# Orin Kernel Guide Authoring Contract

## Purpose

This document defines how the Orin kernel material supports the
[integrated system projects](../docs/orin-system-foundations/README.md). The
projects are the primary delivery sequence. Debugging and performance guides
are on-demand references: select the smallest relevant topic when a project
blocker appears, then return to the project acceptance criteria.

The library develops practical ability in high-quality kernel code, debugging,
performance analysis, and subsystem reasoning. It is not a general C course,
an operating-systems survey, a Linux user guide, or a fixed training plan.

## Project-first use

Deliver projects in this order:

1. [CPU/SoC health diagnostic suite](../docs/orin-system-foundations/cpu-soc-diagnostics.md)
2. [Safe MMIO diagnostic platform driver](../docs/orin-system-foundations/mmio-diagnostic-driver.md)
3. [DVFS, thermal, and performance validation](../docs/orin-system-foundations/dvfs-thermal-validation.md)

Use the [platform evidence lab](../labs/orin-kernel/a01-identify-exact-orin-platform/README.md)
and [software baseline lab](../labs/orin-kernel/a02-capture-software-baseline/README.md)
before making Orin-specific claims. Use the
[QEMU auxiliary environment](../labs/orin-kernel/qemu-auxiliary/README.md) for
generic kernel mechanisms and failures that should be isolated from hardware.

A guide entry is guidance, not a delivered lab. A lab is runnable only when its
document, implementation, scripts, expected evidence, verification, and
cleanup are present. Completion is determined by the three project acceptance
lists and the
[delivery gates](../docs/orin-system-foundations/integrated-project-roadmap.md),
not by completing every guide entry.

## Guide-to-project map

| Guide area | Typical project blocker |
|---|---|
| Platform identity and recovery | All projects: platform identity, software fingerprints, and recovery evidence |
| BSP build and deployment | Reproducible kernel artifacts, deployment, and BSP ownership |
| QEMU debugging | Host-safe kernel experiments, injected failures, and automation |
| Device tree and driver lifecycle | Compatible matching, resources, MMIO access, teardown, IRQ/DMA/PM boundaries |
| Kernel observability | Minimal instrumentation and bounded evidence collection |
| Crash, memory, and concurrency diagnosis | Corruption, leaks, locking, teardown, stalls, and kernel crashes |
| IRQ and scheduler latency | IRQ attribution and latency interference |
| Storage and network performance | Evidence I/O, queueing, tail latency, throughput, and packet-path bottlenecks |
| Power, thermal, and frequency | DVFS, thermal controls, PM failures, and wakeups |
| Performance engineering | Benchmark design, noise, profiling, and comparisons |
| Tests, reports, and upstream work | KUnit/kselftest, failure reports, patches, and review evidence |

Detailed guides live under
[kernel debugging](../docs/orin-kernel-debugging/README.md) and
[kernel performance](../docs/orin-kernel-performance/README.md). A project plan
cites only the selected guides and states the blocker each one resolves.

## Platform truth policy

Orin is authoritative for NVIDIA BSP behavior, Tegra device trees, physical
buses, MMIO, DMA/SMMU, power, thermal behavior, and hardware performance. QEMU
is suitable for generic mechanisms such as oops analysis, sanitizers, locking,
fault injection, GDB, and automated bisection. Virtio or x86_64 evidence must
never be presented as Tegra or ARM64 hardware evidence.

Every executable lab records:

- **Primary platform:** current lab metadata may name the concrete execution
  platform as `Jetson Orin Nano Super` or `QEMU`. Planning tables and compact
  catalogs use one of the normative classifications `Orin only`, `Orin
  primary`, `Orin + QEMU`, `QEMU only`, `QEMU preferred`, or `Either`.
- **QEMU alternative:** `full`, `partial`, or `not applicable`, including what
  QEMU cannot verify.
- **Safety:** `S0`, `S1`, `S2`, or `S3`.

Concrete metadata states where a delivered experiment ran; a classification
states the intended platform strategy. Neither form broadens the claims that
the recorded evidence can support.

Hardware evidence also records board and carrier identity, Jetson Linux and
kernel release, configuration, DTB identity, and relevant firmware/package
versions. Unsupported interfaces are reported as unsupported, never as success.

## Safety contract

- **S0 — observation only:** read-only collection with no expected service
  interruption.
- **S1 — recoverable failure:** module or operation failure with a bounded
  cleanup path; require serial access on Orin when loss of the tested service
  could prevent normal recovery.
- **S2 — volatile system failure:** possible oops, panic, stall, or loss of
  control; use QEMU by default. A hardware exception needs an explicit recovery
  rehearsal and documented justification.
- **S3 — persistent-state risk:** run only with a QEMU snapshot or disposable
  overlay unless a separately reviewed hardware recovery plan authorizes it.

S2/S3 trigger scripts inspect both `/proc/device-tree/model` and
`/proc/device-tree/compatible`, record both observed values, and refuse known
Jetson hardware by default. If either identity source cannot be read, the
script fails closed. A lesson-specific hardware override is permitted only for
a narrowly justified board experiment; it must be named, documented, tested,
and require an explicit acknowledgement token. The evidence bundle records the
observed identity, override token, and justification. S3 tests prove that the
snapshot or overlay was active and its backing image unchanged.

QEMU S3 labs use a fresh qcow2 overlay with its backing image opened
read-only. Cleanup discards the overlay, then verifies base-image integrity by
checksum or a read-only smoke test and records that post-cleanup evidence.

Loading a demo module must be safe. The defect activates only through an
explicit trigger. A trigger node uses mode `0600`, requires `CAP_SYS_ADMIN` or
a justified narrower capability, and validates a lesson-specific token. Module
parameters must not silently activate a defect. Cleanup restores trace state,
unloads artifacts, removes temporary state, and reports incomplete cleanup as
failure.

When a recoverable demo exposes debugfs controls, it provides `status` and
`reset` alongside `trigger`. `status` reports the current state and trigger
count; `reset` returns the demo to its safe state. Cleanup verifies reset and
successful unload rather than assuming either occurred.

Before a module lab, inspect `CONFIG_MODULE_SIG`, `CONFIG_MODULE_SIG_FORCE`,
and effective signature enforcement. Provide a valid signing path when
enforcement is active; do not recommend disabling Secure Boot as a shortcut.
Before changing `Image`, DTB, initramfs, modules, or boot arguments on Orin,
record the current and replacement artifacts, boot selection, expected serial
evidence, and a tested recovery command.

## Project-oriented lab delivery contract

A lab exists to unblock a named project acceptance criterion. Its README must:

1. Name the project, blocker, expected skill transfer, platform, and safety.
2. State the versioned inputs, exact build/run commands, runtime bound, and
   expected stable signatures.
3. Capture a baseline before the trigger or workload changes system state.
4. Preserve raw evidence and environment identity before diagnosis or repair.
5. Connect symptom, hypotheses, shortest source path, root cause, minimal fix
   or disposition, and retest.
6. Run the identical trigger or workload after the change and prove both the
   expected result and absence of the original failure signature.
7. Exercise cleanup/recovery and link the resulting artifact from the relevant
   project page or completion report.

Each delivered lab should fit one focused problem or roughly one hour of
practice. Do not create directories or files until they contain real,
verifiable content. Prefer a controlled workload, fixture, KUnit, kselftest,
fault injection, or real peripheral when a module would be less truthful.

## Module-based lab contract

When a demo module is the smallest truthful reproducer, retain this layout:

```text
labs/orin-kernel/<topic>/
├── README.md
├── module/
│   ├── Makefile
│   ├── <topic>_demo.c
│   └── <topic>_fixed.c
├── scripts/
│   ├── build.sh
│   ├── load.sh
│   ├── trigger.sh
│   ├── collect.sh
│   ├── verify-fixed.sh
│   └── cleanup.sh
└── expected/
    ├── failure-patterns.txt
    └── fixed-result.txt
```

QEMU-capable lessons reuse
`labs/orin-kernel/qemu-auxiliary/`; they do not add a lesson-local `qemu/`
directory. The lesson README documents any specific kernel selection,
arguments, rootfs preparation, and trigger behavior.

The demo is safe on load and requires one explicit trigger. The fixed variant
uses the same verification path. Expected patterns exclude run-specific
addresses, PIDs, timestamps, and CPU numbers. `load.sh` checks platform,
configuration, safety prerequisites, and module-signature enforcement.
`collect.sh` captures evidence before repair. `verify-fixed.sh` checks positive
and negative results. `cleanup.sh` fails if it cannot restore reusable state.

When lifecycle behavior is in scope, run at least 20 load/unload,
probe/remove, or asynchronous teardown cycles under an appropriate debug
configuration. Record KASAN, lockdep, or other debug coverage truthfully.

## Evidence and acceptance

A completed lab provides:

- exact source, dependency, kernel, configuration, and platform identity;
- success, unsupported/invalid-input, and failure-path evidence as applicable;
- bounded commands and stable, machine-checkable expected results;
- raw logs/traces plus the reasoning that localizes the defect;
- the minimal fix or explicit disposition and an identical retest;
- negative verification, cleanup/recovery evidence, and known limitations.

Project evidence must distinguish current runs from planned work and fixtures
from target results. A guide or design page is planning evidence only. Raw
evidence remains unchanged; derived reports name their source files and tools.

## Resource and provenance policy

Follow the [Orin kernel resource policy](../resources/orin-kernel/README.md).
Place citations near claims and record publisher, title, applicable version,
URL, and review date for changing sources. Register definitions and platform
limits require public, version-matched provenance; never build a descriptor or
safety claim from a guessed Orin register.

Benchmarks record tool and workload versions, inputs, command lines, warm-up,
repetitions, affinity, controls, raw results, exclusions, and analysis method.

## Version and compatibility policy

The initial teaching baseline is JetPack 7.2, Jetson Linux 39.2, Linux 6.8,
and L4T Ubuntu 24.04. Before the first hardware lesson relies on it, cite a
dated official NVIDIA source that explicitly establishes this mapping.

Do not silently update the baseline. A baseline change requires a recorded
release mapping, successful build and recovery rehearsal, revalidation of
shared environment checks, review of version-sensitive lessons, and a
compatibility note for readers remaining on the previous baseline.

## Repository verification

For every documentation change:

1. Run targeted searches for stale fixed-course, all-tracks-required, missing
   lab, and removed-path wording.
2. Run `npm run docs:build` so internal links and Markdown rendering are
   checked.
3. Run `git diff --check`.
4. Review heading order, tables, code fences, English-only project content,
   platform labels, and QEMU-versus-Orin claims.

One useful, verified project slice is preferred over several thin lessons.
