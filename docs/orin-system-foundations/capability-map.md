# Orin System Capability Map

This map separates repository assets that exist now from evidence that remains
planned. A guide is preparation; only runnable source, tests, raw evidence, and
documented failure behavior demonstrate execution.

Direct entry points are the
[platform evidence lab](../../labs/orin-kernel-debugging/identify-orin-platform/README.md),
[software baseline lab](../../labs/orin-kernel-debugging/capture-software-baseline/README.md),
[QEMU auxiliary environment](../../labs/orin-kernel-debugging/qemu-auxiliary/README.md),
[debugging guides](../orin-kernel-debugging/README.md), and
[performance guides](../orin-kernel-performance/README.md).

| Engineering capability | Current repository asset | Planned integrated-project evidence |
|---|---|---|
| Reproducible platform identification | Runnable board-identity and software-baseline labs | Every target result links the exact board, BSP, kernel, configuration, and source interfaces |
| Bounded CPU/SoC diagnostics | Platform probes and focused diagnostic guidance | Modular diagnostic suite with isolation, deadlines, structured results, and bounded evidence |
| Linux driver development | Device-tree, lifecycle, IRQ, DMA/SMMU, and power guides | Safe MMIO platform driver with KUnit-tested decoding, failure tests, and lifecycle evidence |
| Close-to-hardware ARM64 work | Orin identity and baseline evidence | Declared resources, ARM64 observations, and platform-specific results across the integrated projects |
| Kernel debugging | QEMU bootstrap plus observability, crash, memory, and concurrency guides | Reproducible failure, source-level diagnosis, minimal change or disposition, and retest |
| Performance analysis | Latency, storage, networking, power, thermal, and benchmark guides | Controlled DVFS/thermal trials with raw measurements and explicit regression decisions |
| C and C++ system software | Current labs exercise shell and kernel-facing workflows | Modular C++ diagnostics and a focused C platform driver |
| Testing and reviewability | Runnable lab fixture tests and verification contracts | Unit, KUnit, integration, negative-path, cleanup, and end-to-end evidence |
| Technical communication | Public design and procedure documents | Reviewed design decisions, failure reports, limitations, and reproducible demonstrations |

## How to use the map

Start with platform identity and the software baseline, then select the smallest
debugging or performance guide required by the active project. Mark planned
evidence as current only when its source, tests, raw outputs, failure behavior,
and target-platform identity are linked and reproducible.
