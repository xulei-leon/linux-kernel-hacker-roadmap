# Code Review — `labs/day-01-debug-ready-kernel-lab/`

- Reviewer: ark-code (latest)
- Date: 2026-07-08
- Scope: `README.md`, `qemu-kernel/build-kernel.sh`, `qemu-kernel/boot-qemu.sh`, `qemu-kernel/lab.env.example`
- Review type: code review
- Baseline for consistency: `labs/day-00-kernel-build-environment/README.md` (Linux `v6.12.95`, `~/src/linux-6.12.95`, BusyBox initramfs at `~/kernel-lab/initramfs.cpio.xz`, QEMU `-initrd` usage)

## Summary

The lab is small, consistent with the day-00 baseline on the key paths (`KERNEL_TREE`, `INITRAMFS_IMAGE`, append line, `-m 2G -smp 2 -nographic`), and the scripts follow safe bash practices (`set -euo pipefail`, parameterized env, existence checks in `boot-qemu.sh`). However, there is a real gap between the narrative in `README.md` and the shipped scripts: the README requires a manual baseline first and lists `make mrproper` as the first build step, while `build-kernel.sh` omits `mrproper` and is itself pre-built automation. The lab also ships no runnable check, no serial log capture, and no persistence of `git rev-parse HEAD`, all of which the README's own Evidence Check section requires. These are fixable, not blocking, but they should be fixed before later labs depend on this one.

## Findings

| Severity | Type | Location | Issue | Evidence | Recommendation |
|---|---|---|---|---|---|
| High | Test | lab directory (none present) | No runnable check exists to prove the scripts still work, even though `AGENTS.md` Verification section requires "the smallest runnable check that proves the lab or script still works." | `glob labs/day-01-debug-ready-kernel-lab/**` returns only `README.md` and three files under `qemu-kernel/`; no `test/`, `check.sh`, or smoke step. | Add a minimal smoke test (e.g., `tests/smoke.sh`) that builds `build-kernel.sh --dry-run`-style config validation or runs `boot-qemu.sh` under a timeout with a bogus kernel and asserts the expected "kernel image not found" exit code. |
| High | Correctness | `qemu-kernel/build-kernel.sh:24` vs `README.md:36` | `build-kernel.sh` does not run `make mrproper` before `make $CONFIG_TARGET`, but the README "Debug Path" lists `make mrproper` as the first step. A rerun over a dirty tree can inherit stale `.config`/artifacts and break reproducibility. | README:36 `make mrproper`; script:24 jumps straight to `make "$CONFIG_TARGET"`. | Either add an opt-in `MRPROPER` env var (default off to preserve incremental builds) or document explicitly in the README that the script intentionally skips `mrproper` and that the manual path is the reproducible one. Make the two agree. |
| Medium | Requirement | `qemu-kernel/build-kernel.sh:23` vs `README.md:88` | README "Evidence Check" requires the `git rev-parse HEAD` output in the lab note. `build-kernel.sh` only `echo`s `kernel_commit=...` to stdout; it does not persist it anywhere reusable. | `build-kernel.sh:23 echo "kernel_commit=$(git rev-parse HEAD)"` produces no file. | Write the commit (and a minimal environment snapshot) to a defined artifact file, e.g. `$KERNEL_TREE/build/lab.env.record` or `$script_dir/../run-record.txt`, so day-01 output is auditable. |
| Medium | Requirement | `qemu-kernel/boot-qemu.sh:36-42` vs `README.md:56-59,94` | README requires serial log capture (`script -fec ... qemu-serial.log`) and lists "Serial log path" as mandatory evidence. `boot-qemu.sh` runs QEMU directly with `exec` and captures nothing. | README:58 `script -fec 'qemu-system-x86_64 ... -nographic' qemu-serial.log`; script has no `script`/`tee`/log path. | Add an optional `LOG_DIR`/`SERIAL_LOG` env var; when set, wrap the `exec "$QEMU" ...` invocation with `script -fec` (or `tee`) writing to the named file so the script produces the evidence the README demands. |
| Medium | Requirement | `qemu-kernel/` dir + `README.md:80` | README states "Do not add automation until the manual baseline has been rerun once," but the lab ships finished automation (`build-kernel.sh`, `boot-qemu.sh`) from the start. This inverts the lab's own guidance. | README:80 "Do not add automation until the manual baseline has been rerun once." | Either (a) mark the scripts as `examples/` or `.wip/` pending the manual baseline, or (b) soften the README line to "Do not rely on automation until the manual baseline has been rerun once," and call the scripts reference implementations. |
| Medium | Documentation | `README.md` (whole) | README never references the scripts under `qemu-kernel/`. A reader following only the README will not know `build-kernel.sh`/`boot-qemu.sh`/`lab.env.example` exist, and a reader opening `qemu-kernel/` will not know how the scripts map to the README's manual "Debug Path." | `README.md` has no "Files" or "Automation" section; no mention of `qemu-kernel/`. | Add a short "Files" or "Automation reference" section listing the three files, their purpose, and how they map to the manual command set. |
| Medium | Documentation | `README.md` (no QEMU exit instructions) | day-00 README explains `Ctrl-a x` to exit `-nographic` QEMU; day-01 README omits it. Users following day-01 alone will be stuck in QEMU. | day-00:218-226 documents `Ctrl-a x`; day-01 has no equivalent. | Copy the one-paragraph `Ctrl-a x` exit note from day-00 into day-01, or link to the day-00 section. |
| Low | Clarity | `qemu-kernel/boot-qemu.sh:24` | `kernel_path="$KERNEL_TREE/$KERNEL_IMAGE"` breaks if a user sets `KERNEL_IMAGE` to an absolute path in `lab.env`. No validation distinguishes relative vs absolute. | `lab.env.example:6 KERNEL_IMAGE="arch/x86/boot/bzImage"` is relative, so the default is fine, but an absolute override silently produces `/<tree>/<abs>`. | If `KERNEL_IMAGE` starts with `/`, use it directly: `if [[ "$KERNEL_IMAGE" == /* ]]; then kernel_path="$KERNEL_IMAGE"; else kernel_path="$KERNEL_TREE/$KERNEL_IMAGE"; fi`. |
| Low | Clarity | `qemu-kernel/build-kernel.sh:21` | `cd "$KERNEL_TREE"` fails under `set -e` with a generic bash error if the path is missing; the script does not pre-check. No usage hint is printed. | `build-kernel.sh:21 cd "$KERNEL_TREE"` with no preceding existence test. | Add `[[ -d "$KERNEL_TREE" ]] || { echo "KERNEL_TREE not a directory: $KERNEL_TREE" >&2; exit 2; }` before the `cd`. |
| Low | Documentation | `README.md:58` | The serial-capture example is a placeholder, not a runnable command: `script -fec 'qemu-system-x86_64 ... -nographic' qemu-serial.log`. The `...` hides the real args and a user cannot copy-paste it. | README:58 uses literal `qemu-system-x86_64 ... -nographic` inside the `script` command. | Replace `...` with the full QEMU invocation from README:48-53 (or reference it), so the capture line is copy-pasteable. |
| Low | Maintainability | `qemu-kernel/build-kernel.sh:31` | `make -j"$MAKE_JOBS" $MAKE_TARGETS` intentionally word-splits `MAKE_TARGETS`. This works for the default `bzImage vmlinux` but breaks if a future target contains whitespace or if a user adds a quoted target. | `build-kernel.sh:31 make -j"$MAKE_JOBS" $MAKE_TARGETS` (unquoted). | Keep as-is but add a comment, or switch to an array: `read -ra _targets <<<"$MAKE_TARGETS"; make -j"$MAKE_JOBS" "${_targets[@]}"`. |
| Low | Maintainability | `qemu-kernel/build-kernel.sh:18` | `: "${MAKE_JOBS:=$(nproc)}"` performs command substitution inside the default-value expansion when `MAKE_JOBS` is unset, while `lab.env.example:12` also defines `MAKE_JOBS="$(nproc)"`. The double-evaluation path is subtle and rarely tested. | `build-kernel.sh:18` and `lab.env.example:12` both compute `$(nproc)`. | Prefer `MAKE_JOBS="${MAKE_JOBS:-$(nproc)}"` (no colon-assign) or precompute once at the top of the script for readability. Not a bug. |
| Low | Clarity | `qemu-kernel/build-kernel.sh`, `boot-qemu.sh` | Neither script exposes a `--help`/`-h` flag; the only usage hint is the error path when `lab.env` is missing. `QEMU_TIMEOUT`/`TRIGGER_COMMAND`/`BAD_PATTERN` in `lab.env.example` are documented as "Day 9 bisect helpers" but `boot-qemu.sh` neither consumes nor rejects them. | `lab.env.example:15-22` defines 6 bisect-helper vars; `boot-qemu.sh` uses none. | Add a tiny `--help` block to each script, and either let `boot-qemu.sh` warn on unused bisect vars or note in `lab.env.example` that they are reserved for `run-bisect-test.sh` (which exists under `labs/day-09-regression-bisect/`). |
| Info | Consistency | `README.md`, `lab.env.example`, day-00 README | `panic=-1` is used everywhere in day-00/day-01. Kernel `panic=` semantics: positive = reboot after N seconds, `0` = no reboot, negative treated as immediate reboot in some versions and as `0` in others. This is consistent with the day-00 baseline but not explained. | `README.md:52`, `lab.env.example:9`, `boot-qemu.sh:22` all use `panic=-1`. | Add a one-line footnote explaining the chosen `panic=-1` behavior so future labs do not "fix" it to `panic=0` without intent. |
| Info | Consistency | `lab.env.example:15` | "Day 9 bisect helpers" forward reference is valid — `labs/day-09-regression-bisect/` exists with `run-bisect-test.sh` and `boot-qemu-and-trigger.sh`. No action needed, but the coupling is undocumented. | `lab.env.example:15 # Day 9 bisect helpers use these when automating...`; confirmed via `glob labs/day-09*/**`. | Optionally add a pointer: "Consumed by `labs/day-09-regression-bisect/qemu-kernel/run-bisect-test.sh`." |
| Info | Security | `lab.env.example:18` | `LOGIN_PASSWORD=""` is an empty password template. Acceptable for a template, but if a user fills it in and commits `lab.env` (which is the natural workflow), the secret lands in git. | `lab.env.example:18 LOGIN_PASSWORD=""`. | Add a `.gitignore` entry for `lab.env` (not just `lab.env.example`) in `qemu-kernel/`, and note that `lab.env` must never be committed. Did not find a `.gitignore` in this lab. |
| Info | Clarity | `README.md:14` | "Evidence channel: serial console and persistent logs, because graphical output often loses early boot messages" is good, but the lab never explains why `-nographic` is used instead of `-display none -serial mon:stdio`. The day-00 README does explain the missing `-enable-kvm`; day-01 does not. | README:13-14 plus `boot-qemu.sh:42 -nographic`; no rationale text in day-01. | Reuse day-00's one-line note about `-nographic` (and the deliberate omission of `-enable-kvm` under WSL2) so day-01 is self-contained. |

## Consistency with `labs/day-00-kernel-build-environment/README.md`

| Item | Day-00 value | Day-01 value | Status |
|---|---|---|---|
| Kernel version | `v6.12.95` | `v6.12.95` (`README.md:16`) | OK |
| Kernel tree path | `~/src/linux-6.12.95` | `$HOME/src/linux-6.12.95` (`lab.env.example:2`) | OK |
| Initramfs path | `~/kernel-lab/initramfs.cpio.xz` | `$HOME/kernel-lab/initramfs.cpio.xz` (`lab.env.example:3`) | OK |
| Initrd mechanism | QEMU `-initrd` | QEMU `-initrd` (`boot-qemu.sh:38`) | OK |
| Append line | `console=ttyS0 rdinit=/init panic=-1` | same (`lab.env.example:9`, `boot-qemu.sh:22`) | OK |
| Memory / SMP | `-m 2G -smp 2` | `MEMORY="2G"`, `SMP="2"` (`lab.env.example:7-8`) | OK |
| QEMU binary | `qemu-system-x86_64` | `QEMU="qemu-system-x86_64"` (`lab.env.example:5`) | OK |
| Display | `-nographic` | `-nographic` (`boot-qemu.sh:42`) | OK |
| Kernel image | `arch/x86/boot/bzImage` | `KERNEL_IMAGE="arch/x86/boot/bzImage"` (`lab.env.example:6`) | OK |
| Debug config | `DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT`, `KALLSYMS`, `KALLSYMS_ALL` | same (`build-kernel.sh:26-28`) | OK |
| Build targets | `bzImage vmlinux` | `MAKE_TARGETS="bzImage vmlinux"` (`lab.env.example:13`) | OK |

Path/version consistency is solid. The inconsistencies are procedural, not path-related: missing `make mrproper`, no serial-log capture, no persisted `git rev-parse HEAD`, and the README-vs-scripts "do not add automation yet" tension.

## Verification performed

- `glob labs/day-01-debug-ready-kernel-lab/**` to confirm the full file set under review and absence of tests.
- `glob labs/day-09*/**` to check the "Day 9 bisect helpers" forward reference; `labs/day-09-regression-bisect/` exists with `run-bisect-test.sh` and `boot-qemu-and-trigger.sh`, so the reference is valid, not scaffolding.
- `git log --oneline -5` to confirm the lab's commit context (latest: `18c55d6 lab: finish day 0 README`).
- Cross-checked every path/value between day-00 and day-01 as listed in the consistency table above.
- `git diff --check` not run (no changes made in this review; this is a review-only change set).

## Suggested follow-ups (ordered)

1. Resolve the `make mrproper` omission in `build-kernel.sh` (either add it or document the intentional skip).
2. Add a minimal smoke test for the two scripts.
3. Make `boot-qemu.sh` capable of writing a serial log file via an env var.
4. Persist `kernel_commit` and the resolved env snapshot to an artifact file in `build-kernel.sh`.
5. Add a "Files" section to `README.md` linking the three `qemu-kernel/` files.
6. Add a `.gitignore` for `lab.env` in `qemu-kernel/`.