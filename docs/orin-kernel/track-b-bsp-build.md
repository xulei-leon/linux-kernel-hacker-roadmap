# Track B — BSP Source and Build

## Outcome

Reproduce the NVIDIA BSP source/config relationship, build one artifact at a
time, and deploy kernel, modules, or DTB with independent rollback.

## Prerequisites

Complete Track A or provide equivalent board identity, serial capture, artifact
backup, and tested recovery evidence; prepare a Linux build host.

## Platform boundary

Generic ARM64 compilation is available on a Linux host and in QEMU-oriented
workflows. Source matching, NVIDIA modules, active DTB selection, and final
deployment evidence require Orin.

## Ordered lessons

| ID | Focus | Principal check |
|---|---|---|
| B01 | Map Jetson Linux BSP components | Ownership map for kernel, NVIDIA modules, DT, bootloader, rootfs, tools |
| B02 | Match source to the running release | L4T, tag, kernel release, and vermagic agree |
| B03 | Prepare ARM64 cross-compilation | Reusable toolchain/output environment |
| B04 | Reproduce the vendor config | Saved origin and reviewed `olddefconfig` delta |
| B05 | Build only the kernel image | Architecture, release string, symbols, output |
| B06 | Build only modules | Staging tree, dependency data, vermagic |
| B07 | Build device trees separately | Exact board DTB/DTBO outputs |
| B08 | Use incremental builds correctly | Observed target rebuild matrix |
| B09 | Deploy a kernel without full reflash | New image plus tested fallback |
| B10 | Deploy modules without mismatch | Successful `depmod` and load evidence |
| B11 | Deploy a DTB with rollback | Proof of active DTB and recovery route |
| B12 | Diagnose a build failure | First actionable error and minimal correction |

## Concrete diagnostic decision

Treat `invalid module format` as a release/config evidence problem before
editing driver code: compare `uname -r`, `modinfo -F vermagic`, the build
`.config`, compiler identity, and installed module path. A code rewrite cannot
repair a module built for the wrong kernel.

## Lab delivery policy

Build lessons must record exact source, commit/tag, config provenance, toolchain,
commands, and artifact hashes. Module lessons must preflight signature
enforcement and provide signing rather than globally weakening Secure Boot.

## Completion criteria

You can rebuild and deploy a single BSP artifact, prove the running system uses
it, and return to the previous artifact without a full reinstall.
