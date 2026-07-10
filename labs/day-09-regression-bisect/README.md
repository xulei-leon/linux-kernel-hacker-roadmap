# Day 9: How do you prove which commit introduced a regression?

## Platform

**Mode: QEMU. Risk: repeated disposable boots.** Use the Day 00 QEMU
environment for automated build, boot, trigger, and classification. Hardware
regressions that exist only on Orin require a separate recovery-gated manual
bisect after the automated test contract is stable.

Prerequisite: [Day 00 QEMU fallback](../day-00-kernel-build-environment/README.md).

## Problem

A kernel behavior works on one release and fails on another, but the suspected patch is a guess. The symptom is "it regressed between two kernels" without a deterministic test.

## Kernel Mechanism

`git bisect` searches commit history by repeatedly testing good and bad revisions. It only works when the test outcome is stable enough to classify each revision as good, bad, or skipped.

Kernel bisection also depends on stable config, build steps, boot command, and trigger.

## Problem Analysis

A bisectable test needs:

- Known good commit.
- Known bad commit.
- Same config policy at every step.
- One build command.
- One boot or trigger script.
- Exit code `0` for good, `1` for bad, and `125` for untestable.

Manual judgment breaks bisection. The pass/fail rule must be observable in output.

## Debug Path

Bisect skeleton:

```sh
git bisect start
git bisect bad <bad-commit>
git bisect good <good-commit>
git bisect run ./tools/repro/run-bisect-test.sh
```

Example test contract:

```sh
#!/bin/sh
set -eu

make olddefconfig
make -j"$(nproc)" bzImage
./boot-qemu-and-trigger.sh > run.log 2>&1 || exit 125

if grep -q 'BUG: unable to handle page fault' run.log; then
  exit 1
fi

exit 0
```

## Resolution

Regression plan:

```text
Good commit:
Bad commit:
Config source:
Build command:
Boot command:
Trigger:
Pass rule:
Fail rule:
Skip rule:
Expected log artifact:
```

If the bug is flaky, first loop the trigger until the failure rate is measurable. Do not start bisection while one run is random.

## 1-Hour Output

Write a bisect plan for one symptom with deterministic pass/fail output.

## Evidence Check

The plan must avoid manual judgment and define a `git bisect run` compatible exit code for each outcome.
