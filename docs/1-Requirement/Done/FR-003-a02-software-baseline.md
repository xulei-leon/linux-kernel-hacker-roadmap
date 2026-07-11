# FR-003 A02 Capture a Reproducible Software Baseline

- `FR-ID`: `FR-003`
- `Title`: A02 Capture a Reproducible Software Baseline
- `Phase`: Phase 2 - Track A executable lessons
- `Development order`: 3
- `Priority`: P0
- `Dependencies`: `FR-002` / validated A01 evidence bundle
- `Affected areas`: `docs/orin-kernel/`, `labs/orin-kernel/`
- `Prototype phase`: No
- `Source type`: New requirement
- `Original SRS section`: Curriculum Track A, lesson A02

## Goal

Deliver a one-hour S0 lesson that extends a validated A01 identity bundle with
the exact running kernel configuration, modules, command line, runtime FDT,
boot-artifact fingerprints, and package state needed to reproduce later work.

## Requirements

- Publish `docs/orin-kernel/a02-capture-software-baseline.md` and a real
  observation-only lab at `labs/orin-kernel/a02-capture-software-baseline/`.
- Require a validated A01 bundle as input; refuse a corrupted or non-Orin A01
  bundle rather than copying it into the baseline.
- Invoke the delivered A01 validator with its delivered required-file contract,
  save output in `a01-validation.txt`, and write the resolved A01 path plus the
  SHA-256 of its `SHA256SUMS` to `a01-reference.txt`.
- Capture kernel release, kernel command line, config plus config-source record,
  `/proc/modules`, relative module-tree file list, runtime flattened-device-tree
  hash, boot-critical artifact hashes, full Debian package snapshot, NVIDIA L4T
  package snapshot, and UTC collection time.
- Kernel config precedence is `CONFIG_OVERRIDE`, an already-readable
  `PROC_CONFIG_GZ` without loading `configs.ko`, then
  `$BOOT_ROOT/config-<release>`; no config produces a named failure.
- `kernel-config-source.txt` records source class, resolved path, and fallback.
- Hash boot artifacts without copying their contents. Include kernel images,
  initramfs files, DTB/DTBO files, and extlinux configuration when present.
- Record boot selection separately in `boot-selection.txt`: extlinux
  `DEFAULT`/`LABEL` lines plus optional read-only UEFI state. Neither candidate
  hashes nor configuration text alone proves firmware choice.
- Preserve relative paths in manifests and sort all outputs deterministically.
- Generate a standard, sorted top-level `SHA256SUMS` excluding itself.
- Support overridable proc/sys/boot/module roots and package snapshot files for
  fixture tests.
- Overrides are `PROC_ROOT`, `SYS_ROOT`, `BOOT_ROOT`, `MODULE_ROOT`,
  `CONFIG_OVERRIDE`, `PROC_CONFIG_GZ`, `DEBIAN_PACKAGES_FILE`,
  `NVIDIA_PACKAGES_FILE`, `UNAME_RELEASE`, `COLLECTED_AT`, and optional
  `UEFI_BOOT_STATE_FILE`.
- Debian and NVIDIA snapshots are independently recollected as sorted
  package/version pairs. The module tree is a sorted list of relative regular
  files under `$MODULE_ROOT/<release>`; `build`/`source` symlinks are not walked.
- Runtime FDT identity is `sha256sum $SYS_ROOT/firmware/fdt`; absence fails.
- Refuse an existing non-empty output directory.
- Perform no installation, reboot, module load/unload, mount, configuration
  change, or privileged write.
- Begin the lesson with Orin / QEMU-not-applicable / S0 metadata.

## Output

- A validated A02 evidence directory
- Tested collection and validation scripts
- Stable required-file contract and fixture tests
- A lesson explaining how each snapshot constrains later diagnosis

## Failure and Degradation

- Missing/corrupt A01 input, kernel config, cmdline, runtime FDT, package
  snapshot, or top-level checksum causes named validation failure.
- Empty loaded-module or module-tree state is recorded explicitly as `none` and
  is not confused with a collection failure.
- Missing boot artifacts are recorded as `unavailable` and make the baseline
  incomplete; the lesson explains how to identify the active boot location
  before proceeding to kernel deployment.

## Out of Scope

- Copying boot binaries, DTBs, modules, or package archives
- Serial-console capture (A03)
- Backup and rollback (A05)
- Kernel build/deployment changes

## Minimum Verification

- TDD fixture tests for config-source precedence, deterministic manifests,
  A01 corruption refusal, empty module state, missing boot artifacts, and
  changed package/FDT fingerprints
- Bash syntax, `git diff --check`, and `npm run docs:build`
- English and legacy-Day scans

## Acceptance Points

- One command consumes A01 evidence and creates the documented A02 bundle.
- Re-running on identical fixtures produces identical content except when the
  declared timestamp changes.
- A config, FDT, package, or boot-artifact change is visible in the intended
  evidence file and top-level checksum.
- The lesson explains why a package list or file name alone cannot prove which
  kernel/DTB actually booted.
- Stable output names are `a01-validation.txt`, `a01-reference.txt`,
  `kernel-release.txt`, `kernel-command-line.txt`, `kernel-config.txt`,
  `kernel-config-source.txt`, `loaded-modules.txt`, `module-tree.txt`,
  `runtime-fdt.sha256`, `boot-artifacts.sha256`, `boot-selection.txt`,
  `debian-packages.txt`, `nvidia-packages.txt`, `collected-at.txt`, and
  `SHA256SUMS`.

## Notes

Real Orin execution remains a learner-side completion requirement. Repository
tests use fixtures and make no hardware-state claim.
