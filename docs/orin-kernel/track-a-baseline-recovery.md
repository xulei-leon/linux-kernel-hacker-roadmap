# Track A — Orin Baseline and Recovery

## Outcome

Create a reproducible Orin identity record, capture complete serial evidence,
and prove recovery before changing boot-critical artifacts.

## Prerequisites

An Orin Nano Super that reaches a shell, administrator access, a serial adapter,
and a host capable of running the NVIDIA recovery tools.

## Platform boundary

The Jetson release, board identity, serial boot, backup, flashing, and recovery
lessons are Orin-only. QEMU is useful only when practicing the experiment
safety-classification method in A07.

## Ordered lessons

| ID | Focus | Evidence required |
|---|---|---|
| [A01](a01-identify-exact-orin-platform.md) | Identify the exact Orin platform | Module, carrier, RAM, SoC, JetPack, L4T, and kernel record |
| A02 | Capture a reproducible software baseline | Config, modules, command line, DTB identity, packages |
| A03 | Establish serial evidence collection | One timestamped UEFI-to-userspace capture |
| A04 | Enter Force Recovery Mode safely | Host-side USB enumeration and recovery-tool record |
| A05 | Back up boot-critical artifacts | Kernel, DTB, initramfs, modules, and boot-selection manifest |
| A06 | Recover from an unbootable kernel | Controlled failure and successful fallback evidence |
| A07 | Build an experiment safety matrix | S0–S3 classification with platform and recovery decision |

## Concrete diagnostic decision

If SSH is unavailable after a kernel change, do not label the kernel
“unbootable” until serial output shows whether UEFI selected the expected image,
the kernel reached `start_kernel()`, the root filesystem mounted, and userspace
started networking. Each boundary implies a different recovery action.

## Lab delivery policy

A01–A05 use read-only commands and captured artifacts. A06 must preserve a
known-good boot entry and show the exact rollback before introducing failure.
The first hardware lesson must add the dated official NVIDIA release mapping
required by the curriculum version policy.

## Completion criteria

You can identify the exact system from saved evidence, capture a failed boot
without relying on SSH, and restore a known-good boot without guessing which
artifact was active.
