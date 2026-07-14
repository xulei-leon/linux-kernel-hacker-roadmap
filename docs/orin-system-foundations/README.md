# Orin System Foundations

Use this section to establish trustworthy platform evidence before changing a
kernel, driver, device tree, or performance setting. It connects exact system
identity, recovery, bounded hardware access, and repeatable validation on
Jetson Orin.

> **Current status:** The foundation map and three starting environments are
> available. The integrated projects are reviewed blueprints, not completed
> implementations.

## Recommended starting order

1. Read the [system capability map](capability-map.md) to separate current
   assets from planned project evidence.
2. Run [Identify the Exact Orin Platform](../../labs/orin-kernel-debugging/identify-orin-platform/README.md).
3. Run [Capture a Reproducible Software Baseline](../../labs/orin-kernel-debugging/capture-software-baseline/README.md).
4. Establish recovery and rollback before any boot-critical modification.
5. Select a [debugging guide](../orin-kernel-debugging/README.md) or
   [performance guide](../orin-kernel-performance/README.md) for the active
   project blocker.

## Expected outcomes

After completing the relevant foundation work, you should be able to:

- identify the exact board, BSP, kernel, boot artifacts, and device tree;
- explain the recovery path before modifying boot-critical state;
- trace build provenance for a kernel, module, or device-tree artifact;
- keep MMIO, IRQ, DMA/SMMU, and power work inside declared resource bounds;
- label every result with its architecture, platform, inputs, and limits.

## Foundation areas

- exact board, BSP, kernel, boot, and device-tree identity;
- recovery and rollback before boot-critical modification;
- ARM64 kernel and module build provenance;
- device-tree, driver lifecycle, MMIO, IRQ, DMA/SMMU, and power boundaries;
- evidence capture, failure classification, cleanup, and retesting.

Detailed procedures live in the [kernel debugging guides](../orin-kernel-debugging/README.md)
and [kernel performance guides](../orin-kernel-performance/README.md).

## Integrated project blueprints

- [CPU/SoC health diagnostics](cpu-soc-diagnostics.md): a modular C++17
  diagnostic stack with bounded checks, structured results, and Orin evidence.
- [Safe MMIO diagnostic driver](mmio-diagnostic-driver.md): a Linux platform
  driver that reads allow-listed resources and separates decoding from
  hardware access.
- [DVFS and thermal validation](dvfs-thermal-validation.md): controlled
  workloads, repeated trials, raw evidence, and explicit regression decisions.

The blueprints and [integrated project roadmap](integrated-project-roadmap.md)
are planning assets. The [future project directions](future-project-directions.md)
document records entry gates for optional networking, platform reliability,
and robotics work.

## Evidence required from a completed project

Each completed project provides:

- source and build instructions tied to a recorded environment;
- success, unsupported, and failure-path results;
- automated checks at the smallest practical boundary;
- raw evidence plus a concise root-cause or validation report;
- cleanup or recovery behavior;
- a short technical demonstration that explains design trade-offs.

## Runnable evidence

- [Platform Evidence Lab](../../labs/orin-kernel-debugging/identify-orin-platform/README.md)
  captures and validates board identity.
- [Software Baseline Lab](../../labs/orin-kernel-debugging/capture-software-baseline/README.md)
  records kernel, device-tree, boot-artifact, and package evidence.
- [QEMU Auxiliary Environment](../../labs/orin-kernel-debugging/qemu-auxiliary/README.md)
  provides a verified x86_64 kernel build, boot, and smoke-test bootstrap.

These assets are runnable, but they do not constitute a completed integrated
project.

## Evidence boundary

Use Orin evidence for NVIDIA BSP behavior, Tegra device trees, physical MMIO
and buses, DMA/SMMU, power, thermal behavior, and board performance. Use QEMU
for generic kernel mechanisms and experiments whose failures should be
isolated. Label the architecture and platform on every result.

Do not infer Tegra behavior from x86_64 or virtio results. Drivers bind
declared, allow-listed resources and do not provide arbitrary physical-address
access.
