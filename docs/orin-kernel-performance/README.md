# Orin Kernel Performance Guides

Use these guides to turn a performance complaint into a controlled workload,
repeatable measurements, a localized bottleneck, and an explicit regression
decision on Jetson Orin.

> **Current status:** The guide set is available. Performance conclusions
> still require workload-specific Orin measurements; QEMU and host results are
> supporting evidence only.

## Recommended starting order

1. Record the exact [platform identity](../orin-kernel-debugging/identify-orin-platform.md)
   and [software baseline](../orin-kernel-debugging/capture-software-baseline.md).
2. Read [Performance Engineering](performance-engineering.md) to define the
   workload, variables, repetitions, and decision rule.
3. Use [Kernel Observability](../orin-kernel-debugging/kernel-observability.md)
   to select the least intrusive instrument for the current hypothesis.
4. Choose the subsystem guide that owns the dominant symptom.

## Expected outcome

A completed analysis should state:

- the workload, platform, power mode, cooling, affinity, and tool versions;
- the baseline distribution and invalid-trial policy;
- the bottleneck hypothesis and evidence that localizes it;
- instrumentation overhead and important measurement limits;
- the repeated comparison and explicit pass, fail, or inconclusive decision.

## Guide map

| Guide | Outcome |
|---|---|
| [Performance Engineering](performance-engineering.md) | Design benchmarks, quantify noise, profile bottlenecks, and compare changes |
| [IRQ and Scheduler Latency](irq-and-scheduler-latency.md) | Attribute delay to IRQ, deferred work, wakeup, affinity, or scheduling |
| [Storage and Filesystem Performance](storage-and-filesystem-performance.md) | Localize I/O errors and tail latency across VFS, cache, filesystem, block, and device layers |
| [Network Performance](network-performance.md) | Localize packet drops, queue imbalance, retransmissions, and throughput regressions |
| [Power, Thermal, and Frequency](power-thermal-and-frequency.md) | Separate PM defects, thermal behavior, and platform limits from regressions |

## Measurement policy

- Record the board, BSP, kernel, configuration, power mode, cooling, workload,
  affinity, tool versions, and exact commands.
- Change one declared independent variable at a time.
- Retain repeated-run data and invalid trials instead of hiding outliers.
- Measure instrumentation overhead on the platform being characterized.
- Keep QEMU, host, replay, and Orin/ARM64 results explicitly separated.

Use the [QEMU debug environment](../orin-kernel-debugging/qemu-debug-environment.md)
for generic failure injection, but do not present emulated measurements as
Tegra hardware results.
