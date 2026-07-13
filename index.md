# Jetson Orin System Engineering Roadmap

Build demonstrable Linux, ARM64, Tegra, debugging, and performance engineering
capability through reproducible guides, labs, and integrated projects.

## Documentation areas

- [Orin system foundations](./docs/orin-system-foundations/README.html)
- [Kernel debugging guides](./docs/orin-kernel-debugging/README.html)
- [Kernel performance guides](./docs/orin-kernel-performance/README.html)

## Integrated projects

- Build a modular CPU/SoC diagnostic suite.
- Build a safe MMIO diagnostic platform driver.
- Validate DVFS, thermal behavior, and performance regressions.

The project blueprints remain planned. Current runnable evidence is available
in the [platform evidence lab](./labs/orin-kernel/a01-identify-exact-orin-platform/README.html),
the [software baseline lab](./labs/orin-kernel/a02-capture-software-baseline/README.html),
and the [QEMU auxiliary environment](./labs/orin-kernel/qemu-auxiliary/README.html).

Orin is authoritative for Tegra and physical-board claims. QEMU supports
generic kernel work and destructive experiments, but its results are not Tegra
hardware evidence.
