# How do you establish an Orin Nano Super kernel lab baseline?

## Goal

Make the Jetson Orin Nano Super 8GB Developer Kit the primary hardware target
for this roadmap. In about one hour, capture enough evidence to identify the
board, software release, kernel, boot configuration, storage, network, and
driver state before changing the BSP.

The output is one directory containing:

```text
orin-baseline/
├── baseline.txt
├── boot-dmesg.log
└── platform-devices.txt
```

This unit does not flash a custom kernel, DTB, or bootloader.

Use [Day 01](../labs/day-01-debug-ready-kernel-lab/README.md) as the canonical
hands-on baseline. This document explains the platform choice, official
release, and safety boundary.

## Prerequisites

- Jetson Linux is installed and the board reaches a shell.
- The board has network access and enough free storage for logs.
- You have `sudo` access.

Use NVIDIA's current installation instructions rather than copying an old
flashing command from a blog:

| Resource | Use |
|---|---|
| [Jetson Orin Nano Developer Kit User Guide](https://docs.nvidia.com/jetson/orin-nano-devkit/user-guide/latest/index.html) | Board setup and recovery information |
| [JetPack SDK Downloads and Notes](https://developer.nvidia.com/embedded/jetpack/downloads) | Current releases and supported hardware |
| [Jetson Linux Developer Guide r39.2](https://docs.nvidia.com/jetson/archives/r39.2/DeveloperGuide/) | Current BSP, kernel, flashing, and driver reference |

This roadmap fixes the environment selected on 2026-07-10 to JetPack 7.2,
Jetson Linux 39.2, Linux kernel 6.8, and L4T Ubuntu 24.04. NVIDIA lists that
release as supporting the Jetson Orin family. Record the exact installed
package versions and reject a mismatched board rather than writing only
`latest` in a lab report.

## Why Orin is the primary platform

Orin exposes behavior that a generic virtual machine cannot reproduce:

- ARM64 boot, firmware, UEFI, and device-tree integration
- Tegra platform devices and real driver probe ordering
- GPIO, I2C, SPI, Ethernet, NVMe, interrupts, and DMA-facing paths
- thermal, frequency, power, suspend, and resume behavior
- hardware-specific performance and latency limits

QEMU remains useful when the experiment intentionally crashes or locks the
kernel, needs a GDB stub, or must repeatedly boot different commits. It is a
safety and automation tool, not the main target.

## Step 1: Create the evidence directory

Run these commands on Orin:

```sh
mkdir -p ~/kernel-lab/orin-baseline
cd ~/kernel-lab/orin-baseline
```

Keep generated logs outside this repository. They describe one local board and
can contain host names, addresses, serial numbers, or other machine-specific
data.

## Step 2: Record the exact platform and release

```sh
{
  printf 'captured_at=%s\n' "$(date --iso-8601=seconds)"
  printf 'model='
  tr -d '\0' < /proc/device-tree/model
  printf '\n'
  uname -a
  cat /etc/nv_tegra_release 2>/dev/null || true
  dpkg-query -W 'nvidia-l4t-*' 2>/dev/null || true
  printf 'cmdline='
  cat /proc/cmdline
} | tee baseline.txt
```

Check the evidence instead of assuming the marketing name identifies the
software stack:

```sh
grep -E 'captured_at=|model=|Linux |R[0-9]+|cmdline=' baseline.txt
```

## Step 3: Record storage and network state

Append the devices and active interfaces to the same report:

```sh
{
  printf '\n## Storage\n'
  lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINTS
  df -hT
  printf '\n## Network\n'
  ip -brief address
  ip route
} | tee -a baseline.txt
```

If the root filesystem is on microSD, record that constraint. Prefer NVMe for
kernel trees, build artifacts, traces, and repeated I/O experiments.

## Step 4: Capture boot and platform-driver evidence

```sh
sudo dmesg -T | tee boot-dmesg.log
find /sys/bus/platform/devices -mindepth 1 -maxdepth 1 -printf '%f\n' \
  | sort | tee platform-devices.txt
```

Review errors without treating every match as a defect:

```sh
grep -i -E 'tegra|nvidia|firmware|dtb|i2c|spi|gpio|nvme' boot-dmesg.log | head -100
grep -i -E 'error|failed|timeout|warn' boot-dmesg.log | head -100
```

For each suspicious line, record the complete surrounding log, the responsible
driver, and whether the related hardware is actually populated on the board.

## Step 5: Confirm remote recovery access

Before later driver experiments, confirm that SSH works from the development
host and record how the board can be power-cycled or recovered.

```sh
systemctl is-active ssh
hostname -I
```

A USB-TTL serial adapter is recommended before bootloader, kernel, DTB, or
early-boot work. SSH alone cannot capture failures that occur before networking
starts.

## Which platform should each lab use?

| Experiment type | Default platform | Reason |
|---|---|---|
| Logging, symbols, ftrace, perf, system triage | Orin | Observe the real ARM64 BSP and drivers |
| Network, IRQ/NAPI, block/NVMe, driver lifecycle, PM | Orin | Results depend on real devices and firmware |
| Generic module exercises with safe load/unload | Orin | Validate against the target kernel ABI |
| Controlled panic, oops, UAF, corruption, deadlock, lockup | QEMU | Fast recovery and no risk to the board installation |
| KGDB/GDB breakpoints and automated `git bisect` | QEMU first | QEMU supplies a reliable GDB stub and disposable boots |
| Custom Jetson kernel, DTB, or BSP changes | Orin with serial and recovery media | Hardware-specific result; recovery path is mandatory |

Do not run a destructive lab on Orin merely because its README contains generic
module commands. Reproduce it in QEMU first, then move only the safe observation
or verified fix to the board.

## Safety gate for BSP changes

Do not flash or replace boot components until all of these are true:

- the exact Jetson Linux release and board model are recorded
- the original boot log is saved off the board
- serial console wiring has been tested when early boot can be affected
- the official recovery or flashing path for that release is available
- the original kernel, DTB, and configuration can be restored

## Completion Check

The baseline is complete when you can answer without guessing:

- Which exact Orin model and Jetson Linux release are running?
- Which kernel and command line booted?
- Where are the root filesystem and kernel work area stored?
- Which network path provides remote access?
- Which platform devices and relevant boot warnings were observed?
- Which recovery path will be used before the first BSP change?
- Which upcoming experiments require QEMU instead of the board?
