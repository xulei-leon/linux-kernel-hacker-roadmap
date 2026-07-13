# Testing, Reporting, and Upstream Work

## Outcome

Convert a reproducer, root-cause analysis, and minimal fix into an automated
regression test and a reviewable kernel patch series.

## Prerequisites

Bring one completed diagnosis/fix pair from the debugging or performance
guides, including its original reproducer, evidence bundle, patch, and
before/after verification.

## Platform boundary

KUnit, kselftest, static analysis, reports, Git, and patch preparation work on a
host and QEMU. NVIDIA BSP ownership and hardware validation require Orin
evidence where applicable.

## Focus areas

- Turn a demo into KUnit
- Turn a reproducer into kselftest
- Test probe failure paths
- Repeat load and unload
- Use sparse on a driver
- Use Smatch on error paths
- Write a root-cause report
- Produce a minimal fix
- Write a regression test
- Determine BSP versus upstream ownership
- Prepare an upstream commit message
- Prepare a reviewable patch series

## Concrete diagnostic decision

A patch that removes the symptom but cannot explain the violated invariant is
not ready for upstream review. The report must connect evidence to root cause;
the test must fail before and pass after; the commit message must explain why
the change is correct rather than merely describing the diff.

## Lab and evidence policy

Each exercise preserves the original reproducer, failing/passing outputs,
config, platform, static-analysis output, patch revision, and test matrix.
Ownership decisions compare NVIDIA downstream code with stable, mainline, and
the responsible subsystem tree.

## Completion criteria

You can submit a small patch series whose problem, cause, fix, test, platform
scope, and remaining limitations are independently reviewable.
