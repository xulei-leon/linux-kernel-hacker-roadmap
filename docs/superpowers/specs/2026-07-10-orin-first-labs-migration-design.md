# Orin-First Labs Migration Design

## Objective

Align the hands-on labs with the repository's primary target: the NVIDIA Jetson
Orin Nano Super 8GB Developer Kit. Pin the primary environment to NVIDIA's
latest official release available on 2026-07-10:

- NVIDIA JetPack 7.2
- Jetson Linux 39.2, released 2026-06-02
- Linux kernel 6.8
- L4T Ubuntu 24.04

Day 00 remains the QEMU introduction and disposable fault-injection
environment. Day 01 through Day 30 become Orin-first unless an experiment
requires QEMU for safety, virtual-machine introspection, or repeatable
automation.

## Official Release Basis

The fixed release information comes from NVIDIA's official resources:

- [JetPack SDK Downloads and Notes](https://developer.nvidia.com/embedded/jetpack/downloads)
- [Jetson Linux 39.2 Developer Guide](https://docs.nvidia.com/jetson/archives/r39.2/DeveloperGuide/)
- [Jetson Linux 39.2 Release Notes](https://docs.nvidia.com/jetson/archives/r39.2/ReleaseNotes/Jetson_Linux_Release_Notes_r39.2.pdf)
- [Jetson Orin Nano Developer Kit User Guide](https://docs.nvidia.com/jetson/orin-nano-devkit/user-guide/latest/index.html)

NVIDIA identifies Jetson Linux 39.2 as the Jetson Linux release for JetPack 7.2,
lists the Jetson Orin family as supported hardware, and provides a Jetson Orin
Nano image. JetPack 7 no longer provides an SD card image for the Jetson Orin
Nano Developer Kit; the lab must direct learners to the unified ISO and USB
installation path.

## Platform Model

Every Day 01–30 README will state one of three execution modes near the top:

1. **Orin**: Run the complete experiment on the Jetson board.
2. **Orin analysis, QEMU trigger**: Use Orin for observation or fix
   verification, but generate the destructive condition in QEMU.
3. **QEMU**: The lab depends on the QEMU GDB stub, disposable boots, or
   automated boot classification.

The platform statement will include the reason for the choice, the risk to the
board, and the evidence required before the experiment starts. A README must
not leave the learner to infer whether a fault-injection module is safe on
Orin.

### Orin-default work

Use Orin for normal logging, symbol inspection, ftrace, perf, bpftrace, memory
state inspection, wait/wake analysis, IRQ and NAPI observation, workqueue and
timer observation, filesystem and NVMe latency, network-drop analysis, driver
lifecycle work, power-management diagnosis, and root-cause reporting.

Safe demonstration modules remain architecture-independent and build against
the running Jetson kernel. The documentation must verify that the matching
headers or prepared kernel build tree exist before calling the module
Makefiles.

### Split-platform work

Use QEMU to trigger intentional panic, oops, NULL dereference, use-after-free,
memory corruption, lock-order failures that may hang, atomic-context warnings,
lockups, and RCU stalls. Orin may be used to analyze a saved report, inspect
the corresponding configuration or source, and verify a safe fix.

Kdump and vmcore exercises use a supplied or QEMU-generated dump by default.
They must not instruct the learner to crash the primary Orin installation as a
routine setup step.

### QEMU-dependent work

Keep QEMU for live GDB-stub debugging and automated kernel regression
bisection. These workflows depend on paused virtual CPUs, disposable root
filesystems, deterministic boot commands, and automated guest control.

## Lab Entry-Point Changes

### Day 00: QEMU introduction

Keep Day 00 as the x86_64 QEMU introduction. Reframe it as an optional but
required prerequisite for later destructive or virtualization-dependent labs,
not as the roadmap's primary target.

Move the generic QEMU build, boot, environment, and smoke-test assets currently
under Day 01 into Day 00. Day 00 will own the reusable QEMU contract consumed
by Day 08 and Day 09.

### Day 01: Orin debug-ready baseline

Replace the QEMU-focused Day 01 flow with a one-hour Orin baseline for JetPack
7.2 and Jetson Linux 39.2. It will:

- verify the board model, `aarch64`, Jetson Linux release, kernel 6.8, boot
  arguments, root storage, and installed NVIDIA L4T packages
- capture the exact running kernel configuration, symbol interfaces, module
  ABI, tracefs state, and tool availability
- verify a matching module build environment without replacing the kernel
- record SSH, serial-console, and recovery access before later BSP changes
- store machine-specific logs outside the repository

The existing Jetson baseline document remains the platform overview. Day 01 is
the canonical hands-on learning unit and links to the overview for official
release and recovery context.

## Shared Orin Environment Check

Add one reusable shell script under `labs/common/` to print and validate:

- `/proc/device-tree/model` identifies a Jetson Orin Nano target
- `uname -m` returns `aarch64`
- `/etc/nv_tegra_release` or installed `nvidia-l4t-*` packages identify
  release 39.2
- the running kernel begins with `6.8`
- tracefs, debugfs, `/proc/config.gz`, kernel headers, and common diagnostic
  tools are present when requested

The script will distinguish hard platform mismatches from optional missing
capabilities. A wrong board, architecture, or fixed release fails the check.
Missing optional tools or kernel features produce actionable warnings because
individual labs require different subsets.

Tracing scripts will call or mirror the relevant checks before changing
tracefs state. They will validate event availability instead of assuming that
every upstream tracepoint exists in the NVIDIA kernel configuration.

## QEMU Asset Dependencies

After the QEMU assets move to Day 00:

- Day 08 reads the Day 00 QEMU environment and adds `-s -S`.
- Day 09 reads the Day 00 QEMU environment for automated build, boot, trigger,
  and result classification.
- Default paths and documentation point only to Day 00.
- QEMU build scripts keep their x86_64 `bzImage` contract; they are not
  presented as Jetson BSP build scripts.

The QEMU smoke test will verify script syntax, missing-input failures, and the
shared environment contract. It is not evidence that a kernel booted.

## Safety and Failure Handling

Orin instructions must stop before a destructive action when the recovery
path, matching artifacts, or serial access is missing. Labs that load safe
modules must include an unload and log-capture path. Tracing scripts must
restore the tracing controls they changed when they exit.

Commands that depend on kernel configuration will first inspect
`/proc/config.gz`, `/boot/config-$(uname -r)`, or the recorded build tree.
Missing events, files, or tools will be reported as environment limitations,
not silently treated as proof that a kernel mechanism is absent.

The documentation will use fixed release values, while commands will still
record exact package versions and the full `uname -r` so local evidence
remains auditable.

## Documentation Scope

Update every `labs/day-*/README.md` whose platform, prerequisite, command,
expected output, or safety guidance changes. Keep each document focused on its
existing concrete problem and roughly one-hour scope.

Synchronize the repository README, site index, debugging index, and existing
Jetson baseline document where they describe the lab entry points or platform
matrix. Do not add generic Jetson administration material unrelated to kernel
development.

## Verification

Run the following checks after implementation:

- `bash -n` for every changed shell script
- the Day 00 QEMU smoke test
- focused tests for the shared Orin checker using fixture or override inputs,
  without requiring the Windows development host to impersonate a Jetson
- searches proving Day 01–30 no longer present QEMU as the default except for
  explicitly classified labs
- searches proving the fixed JetPack, Jetson Linux, kernel, and Ubuntu versions
  are consistent
- `npm run docs:build`
- `git diff --check`

Review rendered Markdown for heading order, valid tables, correct relative
links, and English-only project content.

## Out of Scope

- Flashing a real board during repository verification
- Shipping NVIDIA BSP binaries, root filesystems, or generated logs
- Converting QEMU experiments to emulate Tegra hardware
- Providing parallel instructions for older JetPack releases
- Rewriting the roadmap into a general Jetson user guide
