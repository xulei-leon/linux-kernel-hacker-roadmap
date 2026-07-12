# NVIDIA CPU System Software Roadmap

Build demonstrable Linux, ARM, and Tegra system software capability through
three evidence-driven portfolio projects aligned with NVIDIA role JR2019268.

## Start with the role

- [Roadmap overview](./docs/orin-system-software/README.html)
- [Role competency map](./docs/orin-system-software/role-competency-map.html)
- [Kernel skill library](./docs/orin-kernel/README.html)

## Portfolio sequence

1. Build a modular CPU/SoC diagnostic suite.
2. Build a safe MMIO diagnostic platform driver.
3. Validate DVFS, thermal behavior, and performance regressions.

The three projects are planned. Current runnable evidence is available in the
[A01 platform evidence lab](./labs/orin-kernel/a01-identify-exact-orin-platform/README.html),
the [A02 software baseline lab](./labs/orin-kernel/a02-capture-software-baseline/README.html),
and the [QEMU auxiliary environment](./labs/orin-kernel/qemu-auxiliary/README.html).

Orin is the authority for Tegra and physical-board claims. QEMU supports
generic kernel work and destructive experiments, but its results are not Tegra
hardware evidence.
