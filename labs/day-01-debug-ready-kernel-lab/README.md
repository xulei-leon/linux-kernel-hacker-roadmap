# Day 1: How do you prepare an Orin debug-ready kernel lab?

## Goal

Capture a reproducible debugging baseline for the NVIDIA Jetson Orin Nano
Super 8GB Developer Kit without replacing its kernel, device tree, or
bootloader. Later labs should be able to name the exact board, release, kernel,
configuration, symbol interfaces, module build tree, evidence paths, and
recovery method.

Keep the generated evidence under `~/kernel-lab/orin-day01/`, outside this
repository. It may contain host names, network addresses, serial numbers, and
other machine-specific data.

## Fixed Environment

This roadmap fixes its primary hands-on environment to the latest official
NVIDIA release selected on 2026-07-10:

| Component | Fixed value |
|---|---|
| Developer kit | NVIDIA Jetson Orin Nano Super 8GB |
| JetPack | 7.2 |
| Jetson Linux | 39.2, released 2026-06-02 |
| Kernel | 6.8 |
| Distribution | L4T Ubuntu 24.04 |

Use NVIDIA's official material for installation and recovery:

- [JetPack SDK Downloads and Notes](https://developer.nvidia.com/embedded/jetpack/downloads)
- [Jetson Linux 39.2 Developer Guide](https://docs.nvidia.com/jetson/archives/r39.2/DeveloperGuide/)
- [Jetson Linux 39.2 Release Notes](https://docs.nvidia.com/jetson/archives/r39.2/ReleaseNotes/Jetson_Linux_Release_Notes_r39.2.pdf)
- [Jetson Orin Nano Developer Kit User Guide](https://docs.nvidia.com/jetson/orin-nano-devkit/user-guide/latest/index.html)

JetPack 7 does not provide an SD card image for this developer kit. Use the
unified JetPack ISO and USB installation path documented by NVIDIA. Do not
reuse an older flashing command merely because it mentions Orin Nano.

For the shorter platform overview, see the
[Orin baseline lab](../../docs/jetson-orin-nano-super-bsp-kernel-driver-diagnostic-lab.md).

## Prerequisites

- The board boots JetPack 7.2 and reaches a local or SSH shell.
- The repository is available on the board or its commands can be copied
  exactly.
- You have `sudo` access.
- SSH is configured for normal work.
- A tested serial-console and recovery path are known before any later BSP,
  kernel, DTB, or early-boot modification.

This lab records evidence only. It does not flash or replace boot components.

## Step 1: Verify the fixed Orin release

From the repository root on Orin, run:

```sh
bash labs/common/check-orin-env.sh --require-headers
```

The check fails if the model is not Jetson Orin Nano, the architecture is not
`aarch64`, Jetson Linux is not 39.2, the kernel does not begin with 6.8, or
the running kernel lacks a matching build directory.

Create the evidence directory:

```sh
mkdir -p ~/kernel-lab/orin-day01
cd ~/kernel-lab/orin-day01
```

## Step 2: Capture the boot and storage baseline

```sh
{
  printf 'captured_at=%s\n' "$(date --iso-8601=seconds)"
  printf 'model='
  tr -d '\0' < /proc/device-tree/model
  printf '\n'
  uname -a
  cat /etc/nv_tegra_release
  dpkg-query -W 'nvidia-l4t-*'
  printf 'cmdline='
  cat /proc/cmdline
  printf '\n## Storage\n'
  lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINTS
  df -hT
} | tee platform-baseline.txt

sudo dmesg -T | tee boot-dmesg.log
```

Record whether the root filesystem and kernel work area use microSD, USB
storage, or NVMe. Prefer NVMe for source trees, build artifacts, traces, and
repeated I/O experiments.

## Step 3: Check symbols and kernel configuration

```sh
if test -r /proc/config.gz; then
  zcat /proc/config.gz > running-kernel.config
elif test -r "/boot/config-$(uname -r)"; then
  cp "/boot/config-$(uname -r)" running-kernel.config
else
  echo "running kernel config is not exposed" >&2
  exit 1
fi

grep -E 'CONFIG_(KALLSYMS|DEBUG_INFO|FTRACE|FUNCTION_TRACER|BPF|BPF_SYSCALL)=' \
  running-kernel.config | tee debug-config.txt

test -r /proc/kallsyms
head -5 /proc/kallsyms | tee kallsyms-sample.txt
test -r /sys/kernel/btf/vmlinux && echo 'BTF is available' | tee btf-status.txt
```

Zeroed addresses in `/proc/kallsyms` can reflect `kptr_restrict`; they do
not prove that symbols are absent. Record the setting with:

```sh
sysctl kernel.kptr_restrict | tee kptr-restrict.txt
```

## Step 4: Verify the module build interface

```sh
kernel_release="$(uname -r)"
build_dir="/lib/modules/$kernel_release/build"
test -d "$build_dir"
test -r "$build_dir/Makefile"
printf 'kernel_release=%s\nbuild_dir=%s\n' \
  "$kernel_release" "$(readlink -f "$build_dir")" | tee module-build.txt
```

The directory must match the running Jetson kernel ABI. Do not install generic
Ubuntu headers merely because their version number looks similar. Later module
labs use:

```sh
make -C "/lib/modules/$(uname -r)/build" M="$PWD" modules
```

## Step 5: Check tracing and performance tools

```sh
tracefs=/sys/kernel/tracing
mountpoint -q "$tracefs" || sudo mount -t tracefs tracefs "$tracefs"
test -r "$tracefs/available_events"

for tool in perf trace-cmd bpftool bpftrace; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%s=%s\n' "$tool" "$(command -v "$tool")"
  else
    printf '%s=missing\n' "$tool"
  fi
done | tee tool-status.txt
```

A missing optional tool is a recorded limitation, not proof that the kernel
mechanism is unavailable. Each later lab states which tool or tracepoint it
actually requires.

## Step 6: Record serial and recovery access

```sh
{
  systemctl is-active ssh
  hostname -I
  printf 'serial_console=%s\n' 'record the tested adapter and host command'
  printf 'recovery_method=%s\n' 'record the tested power-cycle or recovery path'
} | tee access-and-recovery.txt
```

Replace the two descriptive values with the local setup. SSH cannot capture a
failure before networking starts. A serial console is mandatory before later
kernel, DTB, bootloader, or suspend/resume experiments that may prevent SSH
from returning.

## Step 7: Write the reproducible lab note

Create `lab-note.md` beside the captured evidence:

```markdown
# Orin Day 01 Baseline

- Board model:
- JetPack: 7.2
- Jetson Linux: 39.2
- Kernel release:
- Root storage:
- Kernel config source:
- Module build directory:
- Available tracing tools:
- SSH path:
- Serial-console command:
- Recovery method:
- Evidence directory:
```

Fill every field from observed output. Do not write only `latest`, `default
kernel`, or `the Jetson`.

## Completion Check

The lab is complete when all of these are true:

- The fixed-release checker passes on the Orin Nano Super.
- The exact board, JetPack, Jetson Linux, kernel, command line, and storage are
  recorded.
- The running kernel configuration and symbol interfaces are identified.
- The matching module build directory is readable.
- tracefs and installed diagnostic tools are recorded.
- SSH, serial-console, and recovery methods are documented.
- Machine-specific evidence is stored outside this repository.
