# NVIDIA CPU System Software Roadmap

This is the canonical entry point for project-based preparation for NVIDIA's
Senior System Software Engineer, CPU role, JR2019268. The public posting
describes work in the Tegra system software group on diagnostic software,
device drivers, SoC features, and full-lifecycle debugging and testing.

Source: [NVIDIA JR2019268](https://nvidia.wd5.myworkdayjobs.com/en-US/NVIDIAExternalCareerSite/job/China-Shenzhen/Senior-System-Software-Engineer--CPU_JR2019268),
posted 2026-06-05 and reviewed for this roadmap on 2026-07-13.

The role calls for a BS or MS in Electrical Engineering or Computer Science
and 5+ years of relevant experience. Those are hiring requirements, not
portfolio outcomes: this repository cannot create academic credentials or
years of professional experience.

## Objective

Produce a compact portfolio that demonstrates how you design, implement,
debug, test, and explain close-to-hardware system software. Completion means
presenting reproducible artifacts and failure evidence, not merely reading all
of the supporting kernel material.

Use the [role competency map](role-competency-map.md) to connect each public
job signal to current evidence and planned deliverables.

## Prerequisites

- Strong C and working C++ skills, including ownership and error handling.
- A Linux development environment and routine use of Git, build tools, and a
  debugger.
- Ability to read kernel code and build or modify a kernel driver.
- Working knowledge of CPU, memory, interrupts, buses, and concurrency.
- An Orin board for Tegra claims; the QEMU path remains useful without one.

## Project sequence

The public portfolio sequence is:

1. [**CPU/SoC diagnostics:**](project-1-cpu-soc-diagnostics.md) a modular C++17
   diagnostic stack with bounded tests, structured results, and Orin evidence.
2. [**Safe MMIO diagnostic driver:**](project-2-mmio-diagnostic-driver.md) a
   Linux platform driver that reads allow-listed registers, exposes decoded
   observations, and separates decoding from hardware access.
3. [**DVFS and thermal validation:**](project-3-dvfs-thermal-validation.md)
   controlled workloads, repeated trials, raw evidence, and explicit regression
   decisions.

The linked blueprints and [delivery roadmap](delivery-roadmap.md) are current
planning assets, not implementation evidence. The sequence starts with
user-space diagnostics, adds a narrow kernel boundary, then evaluates
whole-system performance and thermal behavior.

## Portfolio outcomes

Each completed project must provide:

- source and build instructions tied to a recorded environment;
- success, unsupported, and failure-path results;
- automated tests at the smallest practical boundary;
- raw evidence plus a concise root-cause or validation report;
- a cleanup or recovery path;
- a short interview demonstration that explains design trade-offs.

## What is usable now

- [A01: Identify the Exact Orin Platform](../../labs/orin-kernel/a01-identify-exact-orin-platform/README.md)
  captures and validates board identity.
- [A02: Capture a Reproducible Software Baseline](../../labs/orin-kernel/a02-capture-software-baseline/README.md)
  records kernel, device-tree, boot-artifact, and package evidence.
- [QEMU auxiliary environment](../../labs/orin-kernel/qemu-auxiliary/README.md)
  provides a verified x86_64 kernel build, boot, and smoke-test bootstrap.
- [Kernel skill library](../orin-kernel/README.md) retains the A–O guides for
  debugging, driver, subsystem, performance, test, and upstream-work blockers.

These are current assets. They do not constitute any of the three completed
portfolio projects.

## Truthful platform policy

Use Orin evidence for NVIDIA BSP, Tegra device tree, physical MMIO and buses,
DMA/SMMU, power, thermal behavior, and board performance. Use QEMU for generic
kernel mechanisms and experiments whose failures should be isolated. Label the
architecture and platform on every result.

Do not infer Tegra behavior from x86_64 or virtio results. Do not claim
NVIDIA-private diagnostic interfaces. A future driver must bind declared,
allow-listed platform resources and must not provide arbitrary physical-address
access.
