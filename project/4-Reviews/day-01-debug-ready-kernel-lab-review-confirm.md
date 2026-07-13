# Day 01 Debug Ready Kernel Lab Review Confirm

**Reviewed Inputs**
- `docs/4-Reviews/day-01-debug-ready-kernel-lab-code-review-by-opencode-go-kimi-k2.7-code.md`
- `docs/4-Reviews/day-01-debug-ready-kernel-lab-code-review-by-ark-code-latest.md`
- `labs/day-01-debug-ready-kernel-lab/README.md`
- `labs/day-01-debug-ready-kernel-lab/qemu-kernel/build-kernel.sh`
- `labs/day-01-debug-ready-kernel-lab/qemu-kernel/boot-qemu.sh`
- `labs/day-01-debug-ready-kernel-lab/qemu-kernel/lab.env.example`

**Review Date**
- 2026-07-08

## Overall Conclusion

The reviews are directionally sound. The day-01 files are now path-consistent with day-00, but the README and scripts still need small fixes so the shipped wrappers match the documented evidence requirements.

The target is acceptable after applying the accepted and partial items below: script usage must be documented, tarball sources must not break `build-kernel.sh`, optional serial logging must exist, and day-01 should not carry unrelated day-09 variables.

## Decision Table

| No. | Severity | Type | Review Source | Original Comment Summary | Decision | Evidence | Follow-up Plan / Rejection Reason |
|---|---|---|---|---|---|---|---|
| 1 | High | Consistency | Kimi C1 / Ark C4 | README says not to add automation, but scripts are shipped. | Partial | `README.md` says not to add automation while `qemu-kernel/*.sh` exists. | Soften the wording to "do not rely on automation" and add a reusable scripts section that says manual baseline comes first. |
| 2 | High | Correctness | Kimi C2 / Ark C2 | `build-kernel.sh` skips `make mrproper` while README manual path includes it. | Partial | `README.md` manual path includes `make mrproper`; script currently starts at `make "$CONFIG_TARGET"`. | Add optional `CLEAN_TREE=1` support and document that the script defaults to preserving incremental builds. |
| 3 | High | Correctness | Kimi C3 | `git rev-parse HEAD` aborts on tarball sources. | Accept | Day-00 supports tarball source and uses `git rev-parse HEAD 2>/dev/null || echo tarball-source`. | Mirror the day-00 fallback in `build-kernel.sh`. |
| 4 | Medium | Documentation | Kimi C4 / Ark C5 | README never explains `qemu-kernel/` scripts. | Accept | README has no mention of `build-kernel.sh`, `boot-qemu.sh`, or `lab.env.example`. | Add a short reusable scripts subsection. |
| 5 | Medium | Requirement | Kimi C5 / Ark C3 | `boot-qemu.sh` does not produce the serial log required by README. | Accept | README requires `qemu-serial.log`; script currently `exec`s QEMU directly. | Add optional `SERIAL_LOG` env support using `script`. |
| 6 | Medium | Consistency | Kimi C6 / Ark C14 | Day-9 helper variables are in day-01 `lab.env.example`. | Accept | Day-09 has separate scripts; day-01 scripts do not consume these variables. | Remove the unused day-09 variables from day-01 example. |
| 7 | Medium | Test | Ark C1 | No runnable check exists for the scripts. | Accept | Directory has no smoke check. | Add one minimal smoke script that syntax-checks both scripts and verifies the missing-kernel error path. |
| 8 | Low | Correctness | Kimi C9 | `build-kernel.sh` does not check produced artifacts. | Accept | Script runs `make` and stops without checking `bzImage` or `vmlinux`. | Add readable-file checks and success echoes after build. |
| 9 | Low | Clarity | Ark C8 | `build-kernel.sh` fails with a generic `cd` error for missing `KERNEL_TREE`. | Accept | Script calls `cd "$KERNEL_TREE"` directly. | Add an explicit directory check before `cd`. |
| 10 | Low | Documentation | Kimi C10 / Ark C6 | README lacks script invocation and QEMU exit guidance. | Accept | Day-00 explains `Ctrl-a x`; day-01 does not. | Add `bash qemu-kernel/*.sh` examples and the `Ctrl-a`, then `x` note. |
| 11 | Info | Security | Ark C15 | Local `lab.env` can be accidentally committed. | Accept | `lab.env.example` asks users to copy to `lab.env`; no local ignore exists. | Add `qemu-kernel/.gitignore` containing `lab.env`. |
| 12 | Low | Maintainability | Kimi C11 / Ark C11 | `MAKE_TARGETS` uses intentional shell word splitting. | Reject | `MAKE_TARGETS` is deliberately a whitespace-separated make target list in a tiny bash script. | Keep the current simple expansion; add complexity only if targets with spaces ever become real. |
| 13 | Low | Risk | Kimi C8 | QEMU has no timeout. | Reject | Day-01 is an interactive serial-console lab; day-09 has automation-oriented timeout scripts. | Keep timeout out of day-01; add only when the lab becomes automated. |
| 14 | Low | Clarity | Ark C7 | Absolute `KERNEL_IMAGE` override would be joined to `KERNEL_TREE`. | Reject | `lab.env.example` defines `KERNEL_IMAGE` as a relative path and the lab does not document absolute overrides. | Keep the script narrow; support absolute overrides only when documented as a feature. |

## Needs Immediate Action

- Apply accepted and partial fixes for rows 1-11.

## Can Be Deferred

- Timeout automation, absolute `KERNEL_IMAGE` overrides, and target-array parsing can wait until there is a real use case.

## Final Status

Accept after the accepted and partial fixes are applied and `git diff --check`, `bash -n`, and the new smoke check pass.
