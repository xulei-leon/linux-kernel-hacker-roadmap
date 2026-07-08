# Jetson Orin Nano Super BSP, Kernel, Driver, and Diagnostic Lab

## Goal

Use a Jetson Orin Nano Super Developer Kit as a practical NVIDIA SoC platform for
Linux kernel, driver, board-level diagnostic, and debugging practice.

This is not an AI demo path. The goal is to build evidence for system software
skills that are useful for roles such as NVIDIA Senior System Software Engineer,
CPU:

- Linux kernel and driver programming
- ARM SoC and board bring-up fundamentals
- BSP, boot, firmware, device tree, and kernel logs
- Diagnostic software for hardware-facing systems
- Root-cause debugging with real logs and reproducible experiments

## Official Starting Points

| Resource | Use |
|---|---|
| [Jetson Orin Nano Developer Kit User Guide](https://docs.nvidia.com/jetson/orin-nano-devkit/user-guide/latest/index.html) | Official developer kit guide |
| [Jetson Orin Nano Quick Start Guide](https://docs.nvidia.com/jetson/orin-nano-devkit/user-guide/latest/quick_start.html) | Installation and first boot path |
| [Jetson Orin Nano Super Developer Kit](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-orin/nano-super-developer-kit/) | Hardware positioning and platform capability |
| [JetPack SDK Downloads and Notes](https://developer.nvidia.com/embedded/jetpack/downloads) | JetPack and Jetson Linux versions |
| [Jetson Linux Developer Guide r39.2](https://docs.nvidia.com/jetson/archives/r39.2/DeveloperGuide/) | BSP, kernel, flashing, device tree, and driver material |

## Why This Board Is Useful

Jetson Orin Nano Super is valuable because it is a real NVIDIA Orin/Jetson
platform with a public BSP and Linux software stack. For kernel development
practice, its value is not the AI performance itself, but the access it gives to:

- Jetson Linux and NVIDIA BSP workflows
- UEFI, boot media, target storage, and firmware update paths
- ARM Linux kernel behavior on real hardware
- GPIO, I2C, SPI, Ethernet, NVMe, and other hardware-facing interfaces
- Kernel logs, serial console logs, driver probes, and platform diagnostics

If the work stops at running vision or LLM demos, the job-preparation value is
limited. If it is used as a BSP, kernel, driver, and diagnostic lab, the value is
high.

## Capability Mapping

| Role requirement | Lab evidence | Value |
|---|---|---|
| C/C++ system software | Kernel modules, small user-space diagnostic tools, ioctl tests | High |
| OS and kernel programming | Module lifecycle, driver model, logs, debugfs, ftrace | High |
| SoC architecture | ARM boot flow, device tree, MMIO model, GPIO/I2C/SPI paths | Medium-high |
| Close-to-hardware development | Serial console, board logs, external bus checks, storage and network tests | High |
| Driver development and tests | Platform driver skeleton, char device, cleanup and error-path tests | High |
| Diagnostic software stack | Self-test commands, interface checks, stress tests, JSON/text reports | High |
| Debugging and triage | dmesg, ftrace, perf, lockdep, KASAN-style root-cause reports | High |
| Tegra diagnostic software | Public Jetson practice is relevant, but not equivalent to NVIDIA internal stacks | Medium-high |
| Large modular codebase | Jetson kernel/BSP reading helps, but a personal lab remains smaller in scope | Medium |

## Phase 1: Board Bring-Up

Objective: create a repeatable hardware lab baseline.

Steps:

1. Check whether the board firmware supports the target JetPack version.
2. If required, update through the official JetPack 6.x firmware path first.
3. Install an NVMe SSD for build artifacts, logs, and source trees.
4. Prepare the JetPack 7.2 Jetson ISO on a USB flash drive.
5. Boot the board into the installer and install Jetson Linux to NVMe.
6. Complete the first boot setup and collect a baseline report.

Verification:

```bash
cat /etc/nv_tegra_release
uname -a
lsblk
df -h
sudo dmesg | tee boot-dmesg.log
```

Expected output artifact:

- `baseline-report.md`
- `boot-dmesg.log`
- firmware, kernel, storage, and network notes

## Phase 2: Remote and Serial Debugging

Objective: establish the same debug entry points used in hardware bring-up work.

Steps:

1. Configure SSH access.
2. Configure stable networking or mDNS.
3. Connect a USB-TTL serial cable.
4. Capture one complete boot log from reset to login.
5. Record kernel command line, device tree information, and firmware messages.

Verification:

```bash
hostnamectl
ip addr
cat /proc/cmdline
sudo dmesg | grep -i -E "tegra|nvidia|firmware|dtb|i2c|spi|gpio"
```

Expected output artifact:

- `serial-boot-log.txt`
- `boot-flow-notes.md`
- `debug-entrypoints.md`

## Phase 3: Kernel Module and Driver Skeleton

Objective: prove that the board is being used for Linux kernel development, not
only application-level experiments.

Start with a small module:

```c
#include <linux/init.h>
#include <linux/module.h>

static int __init orin_diag_hello_init(void)
{
	pr_info("orin_diag_hello: loaded\n");
	return 0;
}

static void __exit orin_diag_hello_exit(void)
{
	pr_info("orin_diag_hello: unloaded\n");
}

module_init(orin_diag_hello_init);
module_exit(orin_diag_hello_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Jetson Orin Nano diagnostic hello module");
```

Then extend it into:

- a char device with `open`, `read`, `write`, and `ioctl`
- a platform driver skeleton with `probe` and `remove`
- a `debugfs` or `procfs` status surface
- a user-space C test program

Verification:

```bash
make
sudo insmod orin_diag_hello.ko
dmesg | tail
lsmod | grep orin
sudo rmmod orin_diag_hello
```

Expected output artifact:

- module source
- Makefile
- user-space test program
- driver lifecycle notes covering ownership, cleanup, and error paths

## Phase 4: GPIO, I2C, SPI, and MMIO Diagnostics

Objective: move from generic module practice to hardware-facing diagnostic
software.

| Target | Practice | Output |
|---|---|---|
| GPIO | Read input, drive output, run a loopback check | GPIO self-test |
| I2C | Scan a bus, read a device ID, handle NACK and timeout | I2C diagnostic report |
| SPI | Run loopback or simple device transfer | SPI transfer report |
| MMIO model | Use bit masks, timeout flags, reset states, and error flags | Mock register diagnostic |

If external devices are not available, use a mock register model first. The key
practice is not the specific sensor. The key practice is designing diagnostics
with observable state, error handling, timeout handling, and reproducible logs.

## Phase 5: `orin-nano-diagnostic-lab`

Objective: build a small diagnostic stack that can be explained in an interview.

Suggested structure:

| Module | Responsibility |
|---|---|
| `orin_diag_core` | Shared error codes, state model, logging, report format |
| `orin_diag_gpio` | GPIO checks |
| `orin_diag_i2c` | I2C bus scan and simple read/write tests |
| `orin_diag_net` | Ethernet connectivity, throughput, packet drop counters |
| `orin_diag_storage` | NVMe or microSD latency and error checks |
| `orin_diag_report` | Text or JSON report output |

Example commands:

```bash
sudo orin-diag --all
sudo orin-diag --gpio
sudo orin-diag --i2c --bus 1
sudo orin-diag --net eth0 --target 192.168.1.10
sudo orin-diag --storage /mnt/test
```

Example report:

```text
Board: Jetson Orin Nano
JetPack: 7.2
Kernel: 6.8.x-tegra
Test: I2C bus scan
Result: PASS
Latency: 1.2 ms
Errors: 0
Evidence: dmesg excerpt and command output
```

Expected output artifact:

- `orin-nano-diagnostic-lab/README.md`
- `diagnostic-test-matrix.md`
- source code for at least one kernel-facing test
- one generated diagnostic report

## Phase 6: Kernel Debugging and Root-Cause Reports

Objective: connect the Jetson lab with the broader kernel debugging roadmap.

Recommended practice items:

| Topic | Jetson practice | Evidence |
|---|---|---|
| dmesg and oops | Trigger and explain a controlled module warning | Kernel triage notes |
| ftrace | Trace driver function paths | Call-path and latency notes |
| lockdep | Demonstrate one lock-ordering mistake in a controlled module | Concurrency report |
| KASAN or KMEMLEAK | Reproduce one memory bug in a lab module when available | Memory bug report |
| IRQ and softirq | Observe network load and softirq behavior | Networking/debugging notes |
| driver lifecycle | Validate `probe`, `remove`, workqueue, timer, and cleanup paths | Teardown checklist |
| root-cause report | Write a full problem, hypothesis, evidence, cause, fix, verification report | Interview-ready artifact |

Expected output artifact:

- `root-cause-report-01.md`
- `driver-lifecycle-checklist.md`
- `trace-notes.md`

## Four-Week Execution Plan

| Week | Focus | Deliverable |
|---|---|---|
| 1 | Board bring-up, Jetson Linux install, SSH, serial console, baseline logs | `baseline-report.md` |
| 2 | Kernel module, char device, platform driver skeleton, debugfs/procfs | module and driver skeleton |
| 3 | GPIO/I2C/network/storage diagnostic commands | `orin-nano-diagnostic-lab` |
| 4 | ftrace, perf, lifecycle teardown, one root-cause report | interview-ready debugging report |

## Minimum Viable Version

If time is limited, complete these five items first:

1. Install Jetson Linux and save boot, kernel, storage, and dmesg baselines.
2. Write one kernel module with a char device and ioctl path.
3. Write one platform driver skeleton with correct `probe`, `remove`, and cleanup.
4. Write one diagnostic command that reports GPIO, I2C, network, or storage state.
5. Write one root-cause report for a driver lifecycle, timeout, or memory bug.

This is enough to make the project useful evidence for system software interviews.

## Job-Preparation Value

Overall value: high, if the work remains focused on BSP, kernel, driver,
diagnostic, and debugging evidence.

| Area | Score | Reason |
|---|---:|---|
| Platform relevance | 8/10 | Orin/Jetson is close to NVIDIA Tegra and embedded SoC work |
| Linux kernel evidence | 8/10 | Modules, driver skeletons, debugfs, ftrace, and root-cause reports are directly relevant |
| Hardware-facing practice | 7/10 | GPIO, I2C, SPI, serial, storage, and network tests are useful, but not equal to internal chip bring-up |
| Diagnostic software evidence | 9/10 | A small diagnostic stack maps well to CPU/system software roles |
| C/C++ evidence | 7/10 | Stronger if the code is clean, tested, and not just shell scripts |
| NVIDIA ecosystem familiarity | 8/10 | JetPack, Jetson Linux, BSP, Nsight, CUDA, and TensorRT provide useful context |
| Interview story value | 9/10 | The lab turns RTOS, driver, network, and embedded product experience into visible NVIDIA-platform evidence |

Recommended framing:

> I used Jetson Orin Nano Super as a hands-on NVIDIA SoC platform to rebuild my
> Linux kernel and driver debugging workflow. Instead of focusing only on AI
> demos, I built a small diagnostic-oriented lab with kernel modules, a platform
> driver skeleton, debugfs state reporting, GPIO/I2C/network/storage checks, and
> root-cause reports. The goal was to map my RTOS, network-device, storage, and
> embedded product experience into Linux kernel, SoC, and diagnostic software
> practice.

## Boundary

This project does not replace experience with NVIDIA internal Tegra diagnostic
software or internal SoC bring-up workflows. It is public-platform evidence. Be
explicit about that boundary in interviews.

