# Tegra Linux Kernel & System Engineering Roadmap

A project-driven roadmap for Linux, ARM64, and Tegra system engineering on
Jetson Orin. It focuses on reproducible system evidence, kernel debugging,
driver development, and performance analysis.

Browse the rendered documentation on
[GitHub Pages](https://xulei-leon.github.io/tegra-linux-kernel-roadmap/).

## Start here

- [Orin system foundations](docs/orin-system-foundations/README.md)
- [System capability map](docs/orin-system-foundations/capability-map.md)
- [Integrated project roadmap](docs/orin-system-foundations/integrated-project-roadmap.md)
- [Future project directions](docs/orin-system-foundations/future-project-directions.md)
- [Kernel debugging guides](docs/orin-kernel-debugging/README.md)
- [Kernel performance guides](docs/orin-kernel-performance/README.md)
- [Kernel debugging labs](labs/orin-kernel-debugging/README.md)
- [QEMU auxiliary environment](labs/orin-kernel-debugging/qemu-auxiliary/README.md)

The material assumes working C/C++ skills, routine Linux shell use, the ability
to read kernel code, and experience building or modifying a kernel driver. It
does not replace those prerequisites with a generic operating-systems course.

## Integrated projects

The current project set applies the foundations and guides to three concrete
system engineering problems:

- a modular CPU/SoC diagnostic suite;
- a safe MMIO diagnostic platform driver;
- a repeatable DVFS, thermal, and performance validation workflow.

The blueprints are planning assets until source, tests, raw evidence, failure
behavior, and target results are present. Current runnable evidence includes
the platform-identification and software-baseline labs plus the QEMU bootstrap.

## Platform policy

- **Orin is authoritative** for NVIDIA BSP behavior, Tegra device trees,
  physical buses, DMA/SMMU, power, thermal behavior, and board performance.
- **QEMU is supporting evidence** for generic kernel builds, debugging,
  sanitizers, fault injection, regression automation, and destructive
  experiments.
- **Evidence stays platform-specific:** x86_64, virtio, or emulated results are
  never presented as ARM64 or Tegra hardware evidence.
- **Hardware access stays bounded:** diagnostic drivers use declared,
  allow-listed platform resources rather than arbitrary physical-memory
  access or private interfaces.
- **Recovery precedes modification:** boot-critical work starts only after
  serial capture, backup, and rollback are demonstrated.

## Local documentation build

```sh
pnpm install
pnpm run docs:dev
```

Production check:

```sh
pnpm run docs:build
```

## License

MIT
