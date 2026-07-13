# Orin Kernel Debugging Guides

These guides support reproducible Linux kernel diagnosis on Jetson Orin and in
QEMU. They are selected by the current failure or project blocker rather than
completed as a fixed sequence.

The guides assume that you can already modify and build a kernel driver. They
do not repeat general C, operating-system, or Linux-user material. A runnable
exercise follows this loop:

> symptom → hypothesis → evidence → source path → root cause → minimal fix → verification

## Platform and safety policy

Orin is authoritative for NVIDIA BSP behavior, Tegra device trees, physical
buses, DMA/SMMU, power, thermal behavior, and hardware performance. QEMU is the
default for destructive generic-kernel experiments.

- **S0:** observation only; safe on Orin.
- **S1:** recoverable module or operation failure; require cleanup and serial
  access when used on Orin.
- **S2:** possible oops, panic, stall, or loss of control; use QEMU by default.
- **S3:** persistent-state risk; use a QEMU snapshot or disposable overlay.

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

## How to use the guides

Start with platform identification and the software baseline when target-board
evidence is required. Use the QEMU environment when a trigger may panic, stall,
or corrupt persistent state. Move to the
[performance guides](../orin-kernel-performance/README.md) when the question is
latency, throughput, power, thermal behavior, or regression analysis.

A guide becomes runnable only when its linked lab provides exact commands,
expected evidence, failure behavior, verification, and cleanup. The
[Labs index](../../labs/orin-kernel/README.md) defines that contract.
