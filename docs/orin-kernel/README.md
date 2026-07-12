# Orin Kernel On-Demand Skill Library

This library supports the three-project
[NVIDIA CPU System Software Roadmap](../orin-system-software/README.md). The
portfolio projects are the primary delivery sequence; Tracks A–O provide
focused kernel practice when a project exposes a blocker.

The library assumes that you can already modify and build a kernel driver. It
does not repeat general C, operating-system, or Linux-user material. Each future
executable lesson will address one concrete problem through the loop:

> symptom → hypothesis → evidence → source path → root cause → minimal fix → verification

## Platform policy

Orin is authoritative for NVIDIA BSP behavior, Tegra device trees, physical
buses, DMA/SMMU, power, thermal behavior, and hardware performance. QEMU is a
truthful alternative for generic kernel mechanisms such as oops analysis,
sanitizers, locking failures, fault injection, GDB, and automated bisection.
Virtio evidence must never be presented as Tegra hardware evidence.

## Safety policy

- **S0:** observation only; safe on Orin.
- **S1:** recoverable module or operation failure; require cleanup and serial
  access when used on Orin.
- **S2:** possible oops, panic, stall, or loss of control; use QEMU by default.
- **S3:** persistent-state risk; use a QEMU snapshot or disposable overlay.

Every executable lesson will state its primary platform, QEMU coverage, and
safety level before any command.

## Skill tracks

| Track | Guide | Outcome |
|---|---|---|
| A | [Orin Baseline and Recovery](track-a-baseline-recovery.md) | Establish evidence and a tested recovery path |
| B | [BSP Source and Build](track-b-bsp-build.md) | Reproduce, build, and deploy BSP artifacts safely |
| C | [QEMU Auxiliary Environment](track-c-qemu.md) | Run generic and destructive kernel experiments without the board |
| D | [Device Tree and Probe](track-d-device-tree.md) | Trace hardware description into driver probe behavior |
| E | [Driver Lifecycle and Hardware I/O](track-e-driver-lifecycle.md) | Diagnose resource, teardown, IRQ, bus, DMA, and PM failures |
| F | [Observability](track-f-observability.md) | Select and validate the smallest useful instrumentation |
| G | [Oops and Panic](track-g-oops-panic.md) | Decode a crash into a source-level root cause |
| H | [Memory Failures](track-h-memory.md) | Diagnose corruption, leaks, pressure, and allocation failure |
| I | [Concurrency and CPU Stalls](track-i-concurrency.md) | Reconstruct races, deadlocks, lifetime errors, and stalls |
| J | [IRQ, Deferred Work, and Latency](track-j-irq-latency.md) | Attribute latency to IRQ, softirq, workers, timers, or scheduling |
| K | [Storage and Filesystems](track-k-storage.md) | Follow I/O across VFS, cache, filesystem, and block layers |
| L | [Networking](track-l-networking.md) | Localize packet and throughput failures by layer |
| M | [Power, Thermal, and Frequency](track-m-power.md) | Separate PM defects and platform limits from code regressions |
| N | [Performance Engineering](track-n-performance.md) | Produce reproducible, statistically defensible optimizations |
| O | [Tests, Reports, and Upstream Work](track-o-upstream.md) | Turn a reproducer and fix into reviewable kernel work |

## How to use the library

The Track guides are a searchable skill catalog, not a required sequence or a
portfolio completion checklist. A lesson becomes runnable only when its own
document and lab directory provide exact commands, demo or workload, expected
evidence, minimal fix, negative verification, and cleanup.

The following are common, non-exhaustive blockers. The
[canonical track-to-project map](../orin-nano-super-kernel-curriculum.md#track-to-project-map)
governs authoring; select the smallest guide entry that resolves the current
project blocker:

- **Project 1, CPU/SoC diagnostics:** A and F establish platform evidence and
  observability; G–I support injected-failure diagnosis; O supplies testing and
  reporting practice. Use C for isolated generic-kernel experiments.
- **Project 2, safe MMIO driver:** B, D, and E cover build, device-tree,
  resource, and lifecycle work; F–J support diagnosis; O covers KUnit,
  lifecycle tests, and reviewable fixes.
- **Project 3, DVFS/thermal validation:** A and M establish controlled platform
  and power evidence; J and N cover latency, benchmark design, noise, and
  comparisons; O covers reproducible reports. K or L applies only when storage
  or network activity is part of the measured workload.

Return to the named project's acceptance criteria after the blocker is
resolved. Completion means satisfying all three project acceptance lists and
the [portfolio delivery gates](../orin-system-software/delivery-roadmap.md),
not exhausting this library.

Module-based executable lessons use the fixed directory contract documented in
the [Labs index](../../labs/orin-kernel/README.md). The repository creates a
lesson directory only when the README, buggy and fixed modules, lifecycle
scripts, and stable expected-result files are implemented together.

Start with A01 and A02 when a project needs Orin evidence. Without a board,
establish the
[QEMU auxiliary environment](../../labs/orin-kernel/qemu-auxiliary/README.md),
then use lessons marked for full or partial QEMU coverage while keeping target
acceptance items planned.

Content authors maintain the normative authoring and safety contract in
`docs/orin-nano-super-kernel-curriculum.md`; it is not required learner reading.
