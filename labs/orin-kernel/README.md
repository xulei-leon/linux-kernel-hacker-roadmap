# Orin Kernel Labs

Runnable labs are added one verified problem at a time. A lab is complete only
when it includes an explicit trigger, expected evidence, source localization,
minimal fix, negative verification, and cleanup.

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

## Available shared environment

- [QEMU Auxiliary Environment](qemu-auxiliary/README.md) — reusable kernel
  build, boot, and smoke-test infrastructure for generic or destructive labs.

The Track guides under [`docs/orin-kernel/`](../../docs/orin-kernel/README.md)
define the planned lesson order. A guide entry does not imply that its runnable
lab has already been delivered.
