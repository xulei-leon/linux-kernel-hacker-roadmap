# linux-kernel-hacker-roadmap

An advanced, problem-driven Linux kernel development course for the NVIDIA
Jetson Orin Nano Super 8GB Developer Kit.

## Start here

- [Orin kernel course](docs/orin-kernel/README.md)
- [QEMU auxiliary environment](labs/orin-kernel/qemu-auxiliary/README.md)
- [Runnable labs index](labs/orin-kernel/README.md)

The course assumes that you can already modify and build a kernel driver. It
focuses on evidence-based debugging, performance analysis, subsystem reasoning,
safe board work, and reviewable kernel changes rather than introductory C or
operating-system theory.

## Platform strategy

- **Orin first:** NVIDIA BSP, Tegra device tree, buses, DMA/SMMU, power,
  thermal, storage, networking, and board performance are verified on Orin.
- **QEMU when truthful:** generic kernel mechanisms, destructive failures,
  sanitizers, GDB, fault injection, regression automation, and bisection can be
  practiced without a board.
- **No false equivalence:** virtio or virtual-machine results are not presented
  as Tegra hardware evidence.
- **Recovery before modification:** boot-critical Orin work starts only after
  serial capture, backup, and rollback are demonstrated.

The initial project baseline is JetPack 7.2, Jetson Linux 39.2, Linux 6.8, and
L4T Ubuntu 24.04. The first executable hardware lesson must cite the dated
official NVIDIA release mapping used for verification.

## Learning model

Tracks A–O organize 156 atomic lesson goals. A runnable lesson is delivered
only when it provides a concrete symptom, exact environment, demo or workload,
trigger, evidence, source-level diagnosis, minimal fix, retest, and cleanup.
The repository does not create empty lesson scaffolds.

For every problem, follow:

```text
symptom -> hypothesis -> evidence -> source path -> root cause -> fix -> verification
```

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
