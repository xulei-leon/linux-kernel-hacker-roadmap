# Orin Kernel Labs

Runnable labs are added one verified problem at a time. A lab is complete only
when it includes an explicit trigger, expected evidence, source localization,
minimal fix, negative verification, and cleanup.

## Project delivery contract

Every new lab must name the portfolio project and acceptance blocker it
supports. Its README records platform and safety metadata, versioned inputs,
exact bounded commands, expected stable signatures, and the output artifact
that the project will link as evidence.

A delivered lab follows this evidence loop:

1. Capture platform identity and a quiet baseline.
2. Run one explicit trigger or controlled workload within a stated bound.
3. Preserve raw evidence before diagnosis or repair.
4. Connect symptom, hypotheses, source path, root cause, and minimal fix or
   disposition.
5. Repeat the identical trigger or workload and verify both the expected result
   and absence of the original failure signature.
6. Run cleanup/recovery and report incomplete cleanup as failure.

The project acceptance criteria, not completion of every A–O entry, determine
delivery. A guide entry remains planning material until this contract and any
project-specific evidence requirements are met.

## Required module-based lesson layout

Every executable lesson that uses a demo kernel module must use this exact
structure:

```text
labs/orin-kernel/<lesson-id>-<topic>/
├── README.md
├── module/
│   ├── Makefile
│   ├── <topic>_demo.c
│   └── <topic>_fixed.c
├── scripts/
│   ├── build.sh
│   ├── load.sh
│   ├── trigger.sh
│   ├── collect.sh
│   ├── verify-fixed.sh
│   └── cleanup.sh
└── expected/
    ├── failure-patterns.txt
    └── fixed-result.txt
```

The directory is created only when every listed file has working lesson
content. Empty lesson scaffolds, placeholder modules, and no-op scripts are not
accepted.

The files have fixed responsibilities:

- `README.md` defines platform metadata, safety level, prerequisites, build and
  trigger steps, evidence analysis, root cause, fix, retest, and recovery.
- `<topic>_demo.c` contains one deliberate defect and is safe on module load;
  the defect requires an explicit trigger.
- `<topic>_fixed.c` contains the minimal corrected implementation used by the
  identical verification path.
- `build.sh` builds both variants against the declared kernel tree.
- `load.sh` checks platform, safety, module signatures, and required kernel
  configuration before loading the selected safe-default variant.
- `trigger.sh` performs the single explicit trigger and enforces S2/S3 Jetson
  refusal rules.
- `collect.sh` captures logs, symbols, trace data, configuration, and module
  state before any repair.
- `verify-fixed.sh` reruns the same trigger and checks both the expected fixed
  result and absence of the failure patterns.
- `cleanup.sh` unloads modules, disables probes, removes temporary state, and
  reports incomplete cleanup as failure.
- `expected/failure-patterns.txt` contains stable diagnostic patterns, never
  run-specific addresses, PIDs, timestamps, or CPU numbers.
- `expected/fixed-result.txt` contains the stable success evidence required for
  lesson completion.

QEMU-capable lessons do not create a lesson-local `qemu/` directory. Their
scripts reuse the shared environment below and document any lesson-specific
arguments or rootfs preparation in the lesson README.

Observation-only lessons such as A01 do not create a fake `module/` directory.
They provide the smallest real structure required by the skill—in A01, read-only
collection/validation scripts, fixture tests, and an expected evidence contract.

## Available shared environment

- [A01 Platform Evidence Lab](a01-identify-exact-orin-platform/README.md) —
  read-only Orin identity collection and evidence validation.
- [A02 Software Baseline Lab](a02-capture-software-baseline/README.md) —
  reproducible config, module, FDT, boot-artifact, and package fingerprints.
- [QEMU Auxiliary Environment](qemu-auxiliary/README.md) — reusable kernel
  build, boot, and smoke-test infrastructure for generic or destructive labs.

The A–O guides under
[`docs/orin-kernel/`](../../docs/orin-kernel/README.md) are an on-demand skill
library mapped to the three portfolio projects. Their identifiers and existing
lab paths remain stable, but a guide entry does not imply that its runnable lab
has been delivered.
