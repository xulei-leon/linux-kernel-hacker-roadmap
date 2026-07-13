# Orin System Foundations

This is the entry point for project-based Linux and Tegra system engineering
on Jetson Orin. It connects platform identity, bounded diagnostics, driver
lifecycle work, and controlled performance validation without relying on
private NVIDIA interfaces.

## Objective

Produce reproducible technical evidence that demonstrates how a system
software problem is designed, implemented, debugged, tested, and explained.
Completion requires runnable artifacts and failure evidence, not only design
documents or reading progress.

Use the [system capability map](capability-map.md) to distinguish current
assets from planned integrated-project evidence.

## Foundation areas

- exact board, BSP, kernel, boot, and device-tree identity;
- recovery and rollback before boot-critical modification;
- ARM64 kernel and module build provenance;
- device-tree, driver lifecycle, MMIO, IRQ, DMA/SMMU, and power boundaries;
- evidence capture, failure classification, cleanup, and retesting.

Detailed procedures live in the [kernel debugging guides](../orin-kernel-debugging/README.md)
and [kernel performance guides](../orin-kernel-performance/README.md).

## Integrated projects

- [CPU/SoC health diagnostics](cpu-soc-diagnostics.md): a modular C++17
  diagnostic stack with bounded checks, structured results, and Orin evidence.
- [Safe MMIO diagnostic driver](mmio-diagnostic-driver.md): a Linux platform
  driver that reads allow-listed resources and separates decoding from
  hardware access.
- [DVFS and thermal validation](dvfs-thermal-validation.md): controlled
  workloads, repeated trials, raw evidence, and explicit regression decisions.

The blueprints and [integrated project roadmap](integrated-project-roadmap.md)
are planning assets, not implementation evidence. The
[future project directions](future-project-directions.md) document records
entry gates for optional networking, platform reliability, and robotics work.

## Shared project outcomes

Each completed project provides:

- source and build instructions tied to a recorded environment;
- success, unsupported, and failure-path results;
- automated checks at the smallest practical boundary;
- raw evidence plus a concise root-cause or validation report;
- cleanup or recovery behavior;
- a short technical demonstration that explains design trade-offs.

## Runnable starting points

- [Identify the Exact Orin Platform](../../labs/orin-kernel/a01-identify-exact-orin-platform/README.md)
  captures and validates board identity.
- [Capture a Reproducible Software Baseline](../../labs/orin-kernel/a02-capture-software-baseline/README.md)
  records kernel, device-tree, boot-artifact, and package evidence.
- [QEMU auxiliary environment](../../labs/orin-kernel/qemu-auxiliary/README.md)
  provides a verified x86_64 kernel build, boot, and smoke-test bootstrap.

These are current assets. They do not constitute any completed integrated
project.

## Truthful platform policy

Use Orin evidence for NVIDIA BSP, Tegra device tree, physical MMIO and buses,
DMA/SMMU, power, thermal behavior, and board performance. Use QEMU for generic
kernel mechanisms and experiments whose failures should be isolated. Label the
architecture and platform on every result.

Do not infer Tegra behavior from x86_64 or virtio results. Do not claim private
diagnostic interfaces. Drivers bind declared, allow-listed resources and do
not provide arbitrary physical-address access.
