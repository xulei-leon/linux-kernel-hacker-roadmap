# FR-002 A01 Identify the Exact Orin Platform

- `FR-ID`: `FR-002`
- `Title`: A01 Identify the Exact Orin Platform
- `Phase`: Phase 2 - Track A executable lessons
- `Development order`: 2
- `Priority`: P0
- `Dependencies`: `docs/orin-kernel/track-a-baseline-recovery.md`
- `Affected areas`: `docs/orin-kernel/`, `labs/orin-kernel/`
- `Prototype phase`: No
- `Source type`: New requirement
- `Original SRS section`: Curriculum Track A, lesson A01

## Goal

Deliver a one-hour, read-only Orin lesson that produces and validates a portable
evidence bundle identifying the exact board and running software baseline.

## Requirements

- Publish `docs/orin-kernel/a01-identify-exact-orin-platform.md`.
- Create a real lab under
  `labs/orin-kernel/a01-identify-exact-orin-platform/` without a fake module
  directory because A01 is observation-only.
- Collect module/model, carrier-board identifiers when readable, RAM capacity,
  SoC revision when readable, compatible strings, device-tree serial/IDs,
  architecture, kernel release, command line, `/etc/nv_tegra_release`, OS
  release, installed NVIDIA package versions, and collection timestamp.
- Never fail the whole collection merely because an optional identifier is
  absent; record `unavailable` and explain why.
- Produce a manifest with SHA-256 hashes and validate all required files.
- Name the manifest `SHA256SUMS`, use standard `sha256sum` format, sort entries,
  and exclude the manifest itself.
- Support overridable proc/sys/etc roots so the scripts can be tested without
  Orin hardware.
- Cite the official Jetson Linux r39.2 Developer Guide and require the learner
  to compare collected data with the fixed baseline rather than silently
  rewriting mismatches.
- Perform no flashing, package installation, reboot, configuration change, or
  privileged write.
- Begin the lesson with `Primary platform: Jetson Orin Nano Super`, `QEMU
  alternative: Not applicable`, and `Safety level: S0`.

## Output

- A complete learner lesson
- Tested collection and validation scripts
- Stable expected-file contract
- A saved evidence directory suitable for later Track A lessons

## Failure and Degradation

- Missing required procfs/device-tree/kernel data makes validation fail with a
  named file/error.
- Missing optional Jetson serial, EEPROM-derived ID, config, or package tool is
  recorded as unavailable and does not erase other evidence.
- A non-Orin model is collected faithfully and validation reports the mismatch;
  scripts do not forge a passing Orin identity.

## Out of Scope

- Flashing or recovery mode
- Full A02 package/config baseline
- Hardware probing beyond read-only system interfaces
- A kernel module or destructive trigger

## Minimum Verification

- Test-first Bash fixture tests under the lesson-local `tests/` directory for complete, optional-missing, and
  non-Orin cases
- `bash -n` for all lesson scripts
- `git diff --check`
- `npm run docs:build`

## Acceptance Points

- One command produces the documented evidence bundle.
- Validation detects a missing required file and a non-Orin model.
- Optional missing identifiers are explicit, not silently omitted.
- The lesson explains every collected artifact and the next diagnostic decision.
- Lesson completion requires the learner to run on an Orin and retain the
  validated bundle; repository tests use fixtures and make no hardware claim.
- All tests and documentation checks pass.

## Notes

Official references verified on 2026-07-11 are:

- `https://developer.nvidia.com/embedded/jetpack` — JetPack 7.2/Linux 6.8 page
  that links the r39.2 Jetson Linux documentation.
- `https://docs.nvidia.com/jetson/archives/r39.2/ReleaseNotes/Jetson_Linux_Release_Notes_r39.2.pdf`
  — dated Jetson Linux r39.2 release notes.
