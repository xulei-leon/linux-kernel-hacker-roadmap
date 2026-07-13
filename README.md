# NVIDIA CPU System Software Roadmap

A project-driven Linux and Tegra system software roadmap for two primary
targets: NVIDIA Senior System Software Engineer, CPU (JR2019268), and Senior
Software Engineer - Networking and Virtualization. The current three-project
delivery sequence remains the CPU-focused core; a networking-specific project
will be frozen separately before implementation.

## Start here

- [Role-aligned roadmap](docs/orin-system-software/README.md)
- [Role competency map](docs/orin-system-software/role-competency-map.md)
- [Extension-track decision analysis](docs/orin-system-software/extension-track-analysis.md)
- [Kernel skill library](docs/orin-kernel/README.md)
- [A01 platform evidence lab](labs/orin-kernel/a01-identify-exact-orin-platform/README.md)
- [A02 software baseline lab](labs/orin-kernel/a02-capture-software-baseline/README.md)
- [Runnable labs index](labs/orin-kernel/README.md)
- [QEMU auxiliary environment](labs/orin-kernel/qemu-auxiliary/README.md)

The target learner can already write and debug C/C++, work comfortably in a
Linux shell, read kernel code, and build or modify a kernel driver. The roadmap
does not replace those prerequisites with an introductory operating-systems
course.

The public role also calls for a BS or MS in Electrical Engineering or Computer
Science and 5+ years of relevant experience. This repository can help produce
technical portfolio evidence; it cannot create academic credentials or years
of professional experience.

## Portfolio objective

The primary sequence will deliver three reviewable projects:

1. a modular CPU/SoC diagnostic suite;
2. a safe MMIO diagnostic platform driver;
3. a repeatable DVFS, thermal, and performance validation workflow.

These projects are planned deliverables, not claims about current repository
contents. Today, the repository provides runnable A01 and A02 Orin evidence
labs, a verified QEMU bootstrap, and the A–O kernel skill library.

## Platform policy

- **Orin is authoritative** for NVIDIA BSP behavior, Tegra device trees,
  physical buses, DMA/SMMU, power, thermal behavior, and board performance.
- **QEMU is supporting evidence** for generic kernel builds, debugging,
  sanitizers, fault injection, regression automation, and destructive
  experiments.
- **Evidence stays platform-specific:** x86_64, virtio, or emulated results are
  never presented as ARM64 or Tegra hardware evidence.
- **Hardware access stays bounded:** future diagnostic drivers must use
  allow-listed platform resources; the roadmap does not teach arbitrary
  physical-memory access or claim access to NVIDIA-private interfaces.
- **Recovery precedes modification:** boot-critical Orin work starts only after
  serial capture, backup, and rollback are demonstrated.

## Local documentation build

```sh
npm install
npm run docs:dev
```

Production check:

```sh
npm run docs:build
```

## License

MIT
