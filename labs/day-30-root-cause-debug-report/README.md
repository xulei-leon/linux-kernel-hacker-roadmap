# Day 30: How do you write a senior-level root-cause debug report?

## Problem

Debug notes often end as tool dumps. The symptom is a report full of logs that never proves mechanism, root cause, fix direction, or verification.

## Kernel Mechanism

A useful kernel debug report is an evidence chain. It connects:

- User-visible symptom.
- Kernel mechanism that explains the symptom.
- Raw evidence.
- Reasoning that eliminates alternatives.
- Root cause.
- Fix direction.
- Before/after verification.

## Problem Analysis

A senior-level report answers:

- What failed?
- Where did the kernel observe failure?
- What mechanism makes that observation meaningful?
- Which evidence proves the root cause instead of a nearby symptom?
- What change should fix it?
- How will the fix be verified?

If the report cannot be rerun, it is not done.

## Debug Path

Report template:

```text
Title:
Kernel version and commit:
Config and boot arguments:
Hardware or QEMU environment:
Symptom:
Reproducer:
Raw evidence:
Mechanism:
Analysis:
Root cause:
Fix direction:
Verification before fix:
Verification after fix:
Remaining risk:
```

Use one earlier day as source material. For example, convert a Day 17 lockdep annotation into a report with the two lock chains, the ordering mechanism, the offending path, and the validation stress loop.

## Resolution

Keep raw evidence short and targeted. Include enough log lines to support the claim, not every line the tool emitted. Use commands as reproducibility anchors:

```text
Evidence command:
Expected bad output:
Expected fixed output:
Pass/fail rule:
```

## 1-Hour Output

Draft one root-cause report from an earlier day. It may be a realistic hypothetical report if no local kernel bug is available, but the evidence chain must be internally consistent.

## Evidence Check

The report must include raw evidence, mechanism reasoning, and a reproducible verification step.

