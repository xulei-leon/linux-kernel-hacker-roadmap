# Track C — QEMU Auxiliary Environment

## Outcome

Build a disposable kernel environment for generic debugging, destructive
failure reproduction, GDB, automated testing, and bisection.

## Prerequisites

A Linux or WSL2 host with sufficient storage, kernel-build dependencies, QEMU,
and permission to create disposable local images.

## Platform boundary

This Track is QEMU-only. It teaches generic kernel mechanisms and cannot prove
Tegra device-tree, bus, DMA/SMMU, power, thermal, or performance behavior.

## Ordered lessons

| ID | Focus | Evidence required |
|---|---|---|
| C01 | Build a kernel for QEMU | Source/config/toolchain and image/vmlinux paths |
| C02 | Boot a minimal root filesystem | Console, rootfs, modules, clean exit |
| C03 | Debug early boot with GDB | Breakpoint, registers, source, resume |
| C04 | Preserve evidence after panic | Console, QEMU arguments, config, trigger |
| C05 | Restore a disposable image | Snapshot/overlay discard and base integrity |
| C06 | Run an automated reproducer | Timeout, exit code, stable classifier |
| C07 | Drive `git bisect run` | Automated good/bad/skip result |

## Concrete diagnostic decision

Automation must distinguish “bug absent” from “guest never reached the test.” A
successful boot marker, a trigger marker, an expected fault signature, and a
host timeout are separate states; collapsing them into a single grep result can
identify the wrong bisect commit.

## Lab delivery policy

The retained environment lives at
[`labs/orin-kernel/qemu-auxiliary/`](../../labs/orin-kernel/qemu-auxiliary/README.md).
S3 lessons use `-snapshot` or a fresh qcow2 overlay. Each future lesson reuses
this environment rather than copying a kernel build system.

## Completion criteria

You can build, boot, debug, deliberately fail, reset, and automatically classify
a QEMU guest without changing the Orin installation.
