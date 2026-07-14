# Orin Kernel Debugging Guides

Choose these guides by the current symptom or project blocker. Each guide is a
focused diagnostic unit for moving from an observed failure to source-level
evidence and repeatable verification on Jetson Orin or in QEMU.

> **Current status:** The guide set is available as practical diagnosis
> material. Only topics linked from the labs index have a delivered runnable
> exercise.

## Start with a trustworthy baseline

Before diagnosing target-board behavior:

1. [Identify the exact Orin platform](identify-orin-platform.md).
2. [Capture a reproducible software baseline](capture-software-baseline.md).
3. Confirm the [platform recovery](platform-recovery.md) path before an
   experiment can affect boot or control of the board.
4. Move destructive generic-kernel triggers to the
   [QEMU environment](qemu-debug-environment.md).

The guides assume that you can already modify and build a kernel driver. They
do not repeat general C, operating-system, or Linux-user material.

## Diagnostic outcome

Every investigation should preserve this chain:

> symptom → hypothesis → evidence → source path → root cause → minimal fix → verification

A completed diagnosis includes the original failure signature, bounded
collection steps, source localization, the smallest justified change, an
identical retest, negative verification, and cleanup or recovery evidence.

## Guide map

| Guide | Outcome |
|---|---|
| [Identify the Exact Orin Platform](identify-orin-platform.md) | Record the exact module, carrier, SoC, BSP, and running kernel |
| [Capture a Reproducible Software Baseline](capture-software-baseline.md) | Preserve config, modules, command line, device-tree, boot, and package evidence |
| [Orin Platform Recovery](platform-recovery.md) | Establish serial evidence, backup, rollback, and recovery behavior |
| [BSP Build and Deployment](bsp-build-and-deployment.md) | Reproduce and deploy BSP artifacts without losing the fallback path |
| [QEMU Debug Environment](qemu-debug-environment.md) | Isolate generic and destructive kernel experiments |
| [Device Tree and Driver Probe](device-tree-and-driver-probe.md) | Trace hardware description into driver matching and probe behavior |
| [Driver Lifecycle and Hardware I/O](driver-lifecycle-and-hardware-io.md) | Diagnose resource, teardown, IRQ, bus, DMA, and PM failures |
| [Kernel Observability](kernel-observability.md) | Select the least intrusive instrumentation for one hypothesis |
| [Oops and Panic](oops-and-panic.md) | Decode a crash into a source-level root cause |
| [Memory Failures](memory-failures.md) | Diagnose corruption, leaks, pressure, and allocation failure |
| [Concurrency and CPU Stalls](concurrency-and-cpu-stalls.md) | Reconstruct races, deadlocks, lifetime errors, and stalls |
| [Testing, Reporting, and Upstream Work](testing-reporting-and-upstream.md) | Convert a diagnosis and fix into reviewable regression evidence |

## Safety levels

Orin is authoritative for NVIDIA BSP behavior, Tegra device trees, physical
buses, DMA/SMMU, power, thermal behavior, and hardware performance. QEMU is the
default for destructive generic-kernel experiments.

- **S0:** observation only; safe on Orin.
- **S1:** recoverable module or operation failure; require cleanup and serial
  access when used on Orin.
- **S2:** possible oops, panic, stall, or loss of control; use QEMU by default.
- **S3:** persistent-state risk; use a QEMU snapshot or disposable overlay.

Move to the [performance guides](../orin-kernel-performance/README.md) when the
question is latency, throughput, power, thermal behavior, or regression
analysis. Use the [labs index](../../labs/orin-kernel-debugging/README.md) to
find delivered exercises with exact commands and expected evidence.
