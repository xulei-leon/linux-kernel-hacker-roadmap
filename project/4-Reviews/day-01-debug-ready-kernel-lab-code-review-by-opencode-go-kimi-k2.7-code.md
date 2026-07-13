# Code Review Report: `labs/day-01-debug-ready-kernel-lab/`

- **Reviewer:** opencode-go / kimi-k2.7-code
- **Review date:** 2026-07-08
- **Files reviewed:**
  - `labs/day-01-debug-ready-kernel-lab/README.md`
  - `labs/day-01-debug-ready-kernel-lab/qemu-kernel/build-kernel.sh`
  - `labs/day-01-debug-ready-kernel-lab/qemu-kernel/boot-qemu.sh`
  - `labs/day-01-debug-ready-kernel-lab/qemu-kernel/lab.env.example`
- **Consistency reference:** `labs/day-00-kernel-build-environment/README.md`

## Scope

This review evaluates the day-01 debug-ready kernel lab for correctness, reproducibility, security, maintainability, and consistency with the day-00 baseline. The day-00 baseline fixes the kernel at Linux `v6.12.95` under `~/src/linux-6.12.95`, uses a BusyBox initramfs at `~/kernel-lab/initramfs.cpio.xz`, and boots QEMU with `-initrd` and a serial console.

## Executive Summary

The scripts are small, use `set -euo pipefail`, and correctly source an external env file, which is good practice. However, there are several correctness and consistency gaps:

- The README tells learners not to add automation, but the directory already ships automation scripts without explaining their role.
- `build-kernel.sh` skips `make mrproper`, which the README's own manual path includes, risking stale build artifacts.
- `build-kernel.sh` will crash for tarball-based kernel trees because `git rev-parse HEAD` is not error-suppressed.
- The scripts do not implement the persistent serial logging that the README calls an "evidence channel."
- `lab.env.example` contains Day 9 bisect variables that are not used by the day-01 scripts.

## Findings

| Severity | Type | Location | Issue | Evidence | Recommendation |
|----------|------|----------|-------|----------|----------------|
| High | Requirement / Consistency | `README.md` "Resolution" section vs. directory contents | README says, "Do not add automation until the manual baseline has been rerun once," but the lab already ships `build-kernel.sh`, `boot-qemu.sh`, and `lab.env.example`. Learners are not told when or how to use them. | `README.md` line 80; scripts exist in `qemu-kernel/` without any mention in the README. | Either remove the scripts from day-01 or add a section that explicitly states: manual steps first, then the scripts are a reusable wrapper. Cross-link each script to the manual commands it replaces. |
| High | Correctness / Risk | `qemu-kernel/build-kernel.sh` line 24 | Script does not run `make mrproper` before `make "$CONFIG_TARGET"`, but the README's manual debug path lists `make mrproper` first. Stale `.config` or build artifacts can make the resulting kernel non-reproducible. | `README.md` lines 35-36 show `make mrproper; make defconfig`; `build-kernel.sh` line 24 only runs `make "$CONFIG_TARGET"`. | Add an optional clean step (e.g., `CLEAN=1` env flag or default to `make mrproper`) and document it. If the intent is incremental builds, state that explicitly and warn the user. |
| High | Correctness / Risk | `qemu-kernel/build-kernel.sh` line 23 | `git rev-parse HEAD` is not error-suppressed. With `set -e`, the script aborts if `KERNEL_TREE` is a tarball source, even though day-00 explicitly supports the tarball method. | `build-kernel.sh` line 23: `echo "kernel_commit=$(git rev-parse HEAD)"`. Day-00 README lines 96-126 describe the tarball method, and line 236 shows `git rev-parse HEAD 2>/dev/null || echo tarball-source`. | Change the line to `kernel_commit=$(git rev-parse HEAD 2>/dev/null || echo "tarball-source")` and then echo it, matching the day-00 fallback. |
| Medium | Documentation / Clarity | `README.md` "Debug Path" section | README documents raw shell commands but never mentions the provided `build-kernel.sh`, `boot-qemu.sh`, or `lab.env.example`. A learner may miss the reusable wrappers entirely. | Entire README references no files under `qemu-kernel/`. | Add a subsection such as "Reusable scripts" that maps each script to the manual commands above and explains how to copy `lab.env.example` to `lab.env`. |
| Medium | Requirement / Consistency | `qemu-kernel/boot-qemu.sh` overall | The README calls the serial console an "evidence channel" and shows `script -fec ... qemu-serial.log`, but `boot-qemu.sh` has no log-capture support. | `README.md` lines 14 and 55-59 emphasize persistent logs; `boot-qemu.sh` only `exec`s QEMU. | Add an optional `SERIAL_LOG` env variable to wrap QEMU with `script -fec '...' "$SERIAL_LOG"`, or redirect the serial output. Document the log file in `lab.env.example`. |
| Medium | Consistency / Clarity | `qemu-kernel/lab.env.example` lines 16-22 | Variables named `LOGIN_PROMPT`, `LOGIN_USER`, `LOGIN_PASSWORD`, `SHELL_PROMPT`, `TRIGGER_COMMAND`, `BAD_PATTERN`, and `QEMU_TIMEOUT` are documented as "Day 9 bisect helpers" in a day-01 lab. They are unused by `build-kernel.sh` and `boot-qemu.sh`. | `lab.env.example` lines 15-22. | Move Day-9-specific variables to the day-09 lab directory, or remove them from day-01. If they must stay, add a comment that they are reserved for a later lab and not used here. |
| Medium | Risk | `qemu-kernel/build-kernel.sh` line 24 | `make "$CONFIG_TARGET"` unconditionally regenerates `.config` from the target, discarding any custom config changes the user saved. | `build-kernel.sh` line 24 runs `make "$CONFIG_TARGET"` every invocation. | Add a guard or env flag (e.g., `SKIP_DEFCONFIG=1`) for incremental/config-preserving builds, and warn the user when `.config` will be overwritten. |
| Low | Risk | `qemu-kernel/boot-qemu.sh` line 36 | QEMU is started without a timeout. A panic loop or hung kernel can leave the process running indefinitely in an automated or CI environment. | `boot-qemu.sh` uses `exec "$QEMU"` with no timeout wrapper. | Document the expected `Ctrl-a x` exit for interactive use. For automated use, wrap QEMU with `timeout` or add a `QEMU_TIMEOUT` variable consumed by the script. |
| Low | Test / Correctness | `qemu-kernel/build-kernel.sh` lines 30-31 | Script does not verify that `bzImage` and `vmlinux` were actually produced. A silent make failure or wrong `MAKE_TARGETS` leaves the user with stale or missing artifacts. | No post-build existence checks after `make -j"$MAKE_JOBS" $MAKE_TARGETS`. | Add explicit checks: `test -r "$KERNEL_TREE/$KERNEL_IMAGE"` and `test -r "$KERNEL_TREE/vmlinux"`, then print their paths. |
| Low | Documentation | `qemu-kernel/build-kernel.sh`, `qemu-kernel/boot-qemu.sh` | No executable permissions are mentioned in any README or script comment. Learners copying the files may not be able to run them directly. | Scripts are shell files with shebangs, but no documentation step says `chmod +x qemu-kernel/*.sh`. | Add a one-line instruction in `README.md` or a comment in each script to run `chmod +x` on the scripts, or use `bash scriptname` invocation. |
| Low | Maintainability | `qemu-kernel/build-kernel.sh` line 31 | `MAKE_TARGETS` is expanded unquoted, so values containing spaces or glob characters could be split or expanded unexpectedly. | Line 19: `: "${MAKE_TARGETS:=bzImage vmlinux}"`; line 31: `make -j"$MAKE_JOBS" $MAKE_TARGETS`. | Use a bash array: `MAKE_TARGETS=(bzImage vmlinux)` and expand as `"${MAKE_TARGETS[@]}"`. If plain string is preferred, document that targets are whitespace-separated. |
| Info | Clarity | `qemu-kernel/lab.env.example` line 9; `boot-qemu.sh` line 22; `README.md` line 51 | `panic=-1` is used consistently with day-00, but its semantics (halt vs. reboot) are not explained. | All files use `panic=-1` in the kernel append string. | Add a brief comment in `lab.env.example` or `README.md` explaining that `panic=-1` prevents an automatic reboot so the panic message stays on the serial console. |
| Info | Security / Clarity | `qemu-kernel/lab.env.example` line 18 | `LOGIN_PASSWORD=""` documents an empty root password for future bisect automation. This is acceptable inside a local QEMU lab, but the security assumption is implicit. | `lab.env.example` line 18. | Add a comment that this is intended only for local QEMU and must not be used for networked or production images. |
| Info | Clarity / Consistency | `qemu-kernel/boot-qemu.sh` line 36; `README.md` | QEMU command omits `-enable-kvm`. This matches day-00's WSL2 guidance, but day-01 does not repeat the rationale. | `boot-qemu.sh` runs `qemu-system-x86_64` without `-enable-kvm`; day-00 README line 25 explains WSL2 may lack KVM. | Add a one-sentence note in day-01 README or `lab.env.example` that KVM is intentionally not enabled for WSL2 compatibility, and how to add it if available. |

## Positive Observations

- Both shell scripts use `set -euo pipefail`, which catches unbound variables and early failures.
- Configuration is externalized to `lab.env`, making the scripts reusable across labs without editing the scripts themselves.
- The README template in the "Resolution" section is concrete and covers all the reproducibility fields a debug-ready lab needs.
- Paths, kernel version (`v6.12.95`), initramfs location, and QEMU `-initrd` usage are consistent with `labs/day-00-kernel-build-environment/README.md`.

## Recommended Next Steps

1. Resolve the three High-severity items before treating the lab as ready for learners: clarify the automation/scripts relationship, add `make mrproper` handling, and make `git rev-parse` tolerate tarball sources.
2. Add a short "Using the scripts" section to `README.md` that explains `lab.env.example`.
3. Remove or isolate the Day 9 bisect variables from `lab.env.example`.
4. Add optional serial-log capture to `boot-qemu.sh` so the lab actually implements the "evidence channel" it describes.
