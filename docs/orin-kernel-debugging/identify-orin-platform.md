# How Do You Identify the Exact Orin Platform?

**Primary platform:** Jetson Orin Nano Super

**QEMU alternative:** Not applicable

**Safety level:** S0

## Problem and outcome

“Jetson Orin Nano” is not enough information for a kernel investigation. A
module, carrier board, BSP release, device tree, or kernel mismatch can make a
correct command produce irrelevant evidence. Before changing anything, create
an evidence bundle that answers:

- Which model and compatible strings did this running kernel expose?
- Which carrier/board identifiers and SoC revision were readable?
- How much RAM did the kernel detect?
- Which architecture, kernel, command line, Jetson release, Ubuntu release, and
  NVIDIA L4T packages were active?
- Can another developer verify that the bundle was not modified?

Completion means the validator accepts the bundle on an actual Orin Nano Super
and you can explain every mismatch instead of replacing it with an expected
value.

## Prerequisites

- An Orin Nano Super that reaches a shell.
- A normal user account with permission to read procfs, sysfs, device tree, and
  `/etc` release files. The scripts do not require `sudo`.
- A Linux shell with Bash, GNU `find`, `awk`, `sed`, `tr`, `sha256sum`, `uname`,
  `date`, and `dpkg-query` when NVIDIA package capture is available.
- A writable directory for evidence.

## Official baseline sources

These NVIDIA sources were checked on 2026-07-11:

- [JetPack SDK](https://developer.nvidia.com/embedded/jetpack) identifies the
  JetPack 7.2 generation, Linux 6.8/Ubuntu 24.04 foundation, and links the r39.2
  Jetson Linux documentation.
- [Jetson Linux r39.2 Release Notes](https://docs.nvidia.com/jetson/archives/r39.2/ReleaseNotes/Jetson_Linux_Release_Notes_r39.2.pdf)
  is the dated release record for Jetson Linux 39.2.
- [Jetson Linux r39.2 Developer Guide](https://docs.nvidia.com/jetson/archives/r39.2/DeveloperGuide/)
  documents the corresponding BSP interfaces and workflows.

The project baseline is JetPack 7.2, Jetson Linux 39.2, Linux 6.8, and L4T
Ubuntu 24.04. Your collected values remain authoritative for your board. A
mismatch is a result to investigate, not permission to edit the evidence.

## Step 1 — Inspect the collector before running it

From the repository root:

```sh
cd labs/orin-kernel-debugging/identify-orin-platform
sed -n '1,160p' scripts/collect-platform.sh
sed -n '1,120p' scripts/validate-evidence.sh
```

Verify that the collector only reads from `/proc`, `/sys`, `/etc`, `uname`, and
`dpkg-query`, then writes to the output directory you supply. It does not flash,
install, reboot, load a module, or modify system configuration.

## Step 2 — Collect one immutable baseline bundle

Choose a new directory. The collector creates a missing or empty destination
and refuses an existing, non-empty destination so old and new runs cannot be
mixed accidentally.

```sh
output="$HOME/kernel-lab/platform-identity-$(date -u +%Y%m%dT%H%M%SZ)"
scripts/collect-platform.sh "$output"
```

Expected final line:

```text
evidence collected: /home/<user>/kernel-lab/platform-identity-<UTC timestamp>
```

The personal path and timestamp will differ.

## Step 3 — Validate identity and integrity

```sh
scripts/validate-evidence.sh "$output" expected/required-files.txt
```

Expected result on a matching Orin Nano Super:

```text
evidence validated: /home/<user>/kernel-lab/platform-identity-<UTC timestamp>
```

The validator checks required files, every SHA-256 entry, model text containing
`Jetson Orin Nano`, architecture `aarch64`, and a `tegra234` compatible string.
It does not force the installed release to match the project baseline; release
differences must remain visible for diagnosis.

## Step 4 — Read the evidence in dependency order

Start with hardware identity:

```sh
sed -n '1,20p' "$output/model.txt"
sed -n '1,40p' "$output/compatible.txt"
cat "$output/carrier-board.txt"
cat "$output/device-tree-serial.txt"
cat "$output/soc-revision.txt"
cat "$output/memory.txt"
```

Then read the running software identity:

```sh
cat "$output/architecture.txt"
cat "$output/kernel-release.txt"
cat "$output/kernel-command-line.txt"
cat "$output/nv-tegra-release.txt"
cat "$output/os-release.txt"
cat "$output/nvidia-packages.txt"
cat "$output/collected-at.txt"
```

Finally verify the bundle independently:

```sh
(cd "$output" && sha256sum -c SHA256SUMS)
```

Every entry must report `OK`.

## Step 5 — Interpret missing and mismatched values

`unavailable` is accepted only for carrier/serial/SoC-revision identifiers and
the optional package query. Device-tree/carrier identifiers and
`/sys/devices/soc0/revision` vary by BSP and exposed firmware data. Record
which interface was absent and continue with the remaining identity evidence.

Use this decision order:

1. If model, architecture, or compatible validation fails, stop treating the
   system as the course target.
2. If `/etc/nv_tegra_release` is unavailable, confirm whether the installed
   image provides the file before inferring the Jetson Linux release from
   package names.
3. If Jetson Linux, kernel, or Ubuntu differs from the fixed baseline, save the
   bundle and decide whether to realign the board or author a version-specific
   variation. Do not merge outputs from two releases.
4. If only carrier, serial, or SoC revision is unavailable, preserve the result
   and obtain the missing identifier through the appropriate NVIDIA board or
   recovery tooling in a later lesson.

## Source path behind the evidence

The key control flow is not a driver call chain yet. It is the boot-time data
flow:

```text
firmware/board configuration
  -> selected DTB
  -> /proc/device-tree model and compatible
  -> platform-device creation and driver matching
```

A wrong active DTB can therefore make later probe debugging target the wrong
hardware description. This guide captures the runtime end of that chain before
the device-tree guide traces it back to source DTS files.

## Cleanup and preservation

This lesson makes no system change, so cleanup means protecting the evidence:

```sh
tar -C "$(dirname "$output")" -caf "${output}.tar.xz" "$(basename "$output")"
sha256sum "${output}.tar.xz" > "${output}.tar.xz.sha256"
```

Do not delete the original bundle until the software-baseline guide has
incorporated its identity into the broader baseline.

## Independent exercise

Copy the test fixture, change its model to a non-Orin value, and run the
collector with `PROC_ROOT`, `SYS_ROOT`, and `ETC_ROOT` pointed at the fixture.
Use `NVIDIA_PACKAGES_FILE`, `UNAME_MACHINE`, `UNAME_RELEASE`, and `COLLECTED_AT`
to make other inputs deterministic. Explain why collection succeeds but
validation fails. This distinction lets the tool preserve evidence from an
unexpected machine without falsely accepting it as the target.

## Completion checklist

- The bundle was collected on the real board without `sudo`.
- `validate-evidence.sh` passed.
- `SHA256SUMS` verifies independently.
- You recorded any `unavailable` values and their source paths.
- You compared release/kernel/Ubuntu values with the official baseline sources.
- You can state the exact model, compatible SoC, RAM, kernel, and Jetson Linux
  release without relying on memory.
