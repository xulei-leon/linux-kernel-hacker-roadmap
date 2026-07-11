# Jetson Orin Nano Super Kernel Course

This is the learner-facing entry point for an advanced, problem-driven Linux
kernel course built around the Jetson Orin Nano Super 8GB Developer Kit.

The course assumes that you can already modify and build a kernel driver. It
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

## Course tracks

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

## How to use the guides

The Track guides define sequencing and acceptance; they are not claims that all
156 executable labs already exist. A lesson becomes runnable only when its own
document and lab directory provide exact commands, demo or workload, expected
evidence, minimal fix, negative verification, and cleanup.

Module-based executable lessons use the fixed directory contract documented in
the [Labs index](../../labs/orin-kernel/README.md). The repository creates a
lesson directory only when the README, buggy and fixed modules, lifecycle
scripts, and stable expected-result files are implemented together.

Start with Track A and B if you own an Orin. Without a board, establish the
[QEMU auxiliary environment](../../labs/orin-kernel/qemu-auxiliary/README.md),
then follow the lessons marked for full or partial QEMU coverage in Tracks C–O.

Content authors maintain the normative authoring contract separately in
`docs/orin-nano-super-kernel-curriculum.md`; it is not required learner reading.
