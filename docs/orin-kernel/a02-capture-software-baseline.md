# A02 — How Do You Capture a Reproducible Software Baseline?

**Primary platform:** Jetson Orin Nano Super

**QEMU alternative:** Not applicable

**Safety level:** S0

## Problem and outcome

A board name and `uname -r` do not reproduce a kernel investigation. Two systems
can report the same release while using different configs, modules, runtime
FDTs, boot files, or packages. A02 consumes your validated A01 identity bundle
and records the software state that later build, driver, and regression lessons
must cite.

Completion produces a checksummed evidence directory and a short explanation
of which facts are proven, which are only candidate files, and which remain
unavailable.

## Prerequisites

- Complete A01 on the same running Orin and retain its validated bundle.
- Bash, GNU findutils, `gzip`, `awk`, `sort`, `sha256sum`, `uname`, `date`, and
  `dpkg-query`.
- Read access to `/proc`, `/sys/firmware/fdt`, `/boot`, `/lib/modules`, and the
  Debian package database.
- The dated NVIDIA baseline sources cited in [A01](a01-identify-exact-orin-platform.md).

The collector never loads `configs.ko`. It reads `/proc/config.gz` only if the
file is already available.

## Step 1 — Validate the A01 dependency

```sh
cd labs/orin-kernel/a02-capture-software-baseline
a01="$HOME/kernel-lab/a01-platform-<UTC timestamp>"
../a01-identify-exact-orin-platform/scripts/validate-evidence.sh \
  "$a01" ../a01-identify-exact-orin-platform/expected/required-files.txt
```

Do not continue if the A01 checksum, model, architecture, or compatible checks
fail. A02 calls this same validator again and records its output.

## Step 2 — Collect the software baseline

```sh
output="$HOME/kernel-lab/a02-software-$(date -u +%Y%m%dT%H%M%SZ)"
scripts/collect-software-baseline.sh "$a01" "$output"
scripts/validate-software-baseline.sh "$output" expected/required-files.txt
```

The destination must be missing or empty. Expected final messages are:

```text
software baseline collected: /home/<user>/kernel-lab/a02-software-<timestamp>
software baseline validated: /home/<user>/kernel-lab/a02-software-<timestamp>
```

## Step 3 — Check config provenance first

```sh
cat "$output/kernel-release.txt"
cat "$output/kernel-config-source.txt"
grep -E '^(CONFIG_LOCALVERSION|CONFIG_IKCONFIG|CONFIG_MODULES|CONFIG_OF)=' \
  "$output/kernel-config.txt"
```

The collector chooses exactly one config source:

1. an explicit `CONFIG_OVERRIDE` supplied by the operator;
2. an already-readable `/proc/config.gz`;
3. `/boot/config-$(uname -r)`.

`kernel-config-source.txt` records the chosen class, path, and fallback. A boot
config may be stale if someone replaced `Image` without replacing its config,
so source provenance matters as much as content.

## Step 4 — Interpret each evidence file

| Evidence | What it constrains | What it does not prove |
|---|---|---|
| `a01-reference.txt` | Exact A01 bundle and manifest used | That the board has not changed since A01 |
| `kernel-command-line.txt` | Arguments visible to this running kernel | Which boot entry supplied them |
| `loaded-modules.txt` | Modules loaded at collection time | All modules installed or previously loaded |
| `module-tree.txt` | Relative regular files under this release's module tree | That each file matches the running image |
| `runtime-fdt.sha256` | Raw FDT blob exposed by the running kernel | Which on-disk DTB filename firmware selected |
| `boot-artifacts.sha256` | Hashes of candidate images, initramfs, DTB/DTBO, extlinux config | That any candidate was actually loaded |
| `boot-selection.txt` | extlinux labels/default and supplied read-only UEFI state | Complete firmware decision history |
| package snapshots | Installed package/version database state | Which kernel or DTB booted |

Read the small files directly:

```sh
cat "$output/a01-reference.txt"
cat "$output/runtime-fdt.sha256"
cat "$output/boot-selection.txt"
cat "$output/boot-artifacts.sha256"
```

Use `none` and `unavailable` differently: `none` means a readable module source
was empty; `unavailable` means the source could not be read or no matching boot
artifact was found. Validation rejects `unavailable` because the baseline is
not yet sufficient for later deployment lessons.

## Step 5 — Compare candidate boot state with runtime state

Ask three separate questions:

1. Does `kernel-release.txt` match the module-tree directory and package names?
2. Does the selected extlinux/UEFI evidence point at one of the hashed image and
   DTB candidates?
3. Is there an operational record—serial log in A03 or later boot evidence—that
   connects the selected entry to the runtime kernel/FDT?

A02 answers the first two as far as read-only files allow. It deliberately does
not claim the third. File presence is not boot proof.

## Step 6 — Verify integrity and archive

```sh
(cd "$output" && sha256sum -c SHA256SUMS)
tar -C "$(dirname "$output")" -caf "${output}.tar.xz" "$(basename "$output")"
sha256sum "${output}.tar.xz" > "${output}.tar.xz.sha256"
```

Every manifest entry must report `OK`. Keep the A01 and A02 archives together;
the path and manifest hash in `a01-reference.txt` preserve their relationship.

## Failure decisions

- **A01 validation fails:** stop and repair provenance; never bypass it.
- **Kernel config unavailable:** obtain the correct config through a read-only
  source or explicit operator override; do not load a module in this S0 lesson.
- **Runtime FDT unavailable:** record the environment gap and stop; hashing an
  arbitrary on-disk DTB is not an equivalent substitute.
- **Boot artifacts unavailable:** identify the actual boot filesystem/mount
  before B09–B11; do not search and hash the entire root filesystem.
- **Package snapshot unavailable:** restore access to `dpkg-query`; do not copy
  package data from another machine.

## Independent exercise

Use the fixture test to change one boot image, package version, and runtime FDT
in separate runs. Identify the one evidence file that changes first, then show
how its change propagates into top-level `SHA256SUMS`.

## Completion checklist

- The A01 validator output is present and successful.
- Kernel config source and fallback are explicit.
- Loaded and installed modules are not confused.
- Runtime FDT and boot candidate hashes are interpreted separately.
- Package lists are sorted package/version pairs.
- `SHA256SUMS` verifies and the bundle is archived.
- No output in the repository claims to be a real Orin capture.
