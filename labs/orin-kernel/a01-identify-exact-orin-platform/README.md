# A01 Platform Evidence Lab

**Primary platform:** Jetson Orin Nano Super

**QEMU alternative:** Not applicable

**Safety level:** S0

This is an observation-only lesson. It intentionally has no `module/` directory
or trigger script; all operations are read-only evidence collection and
validation.

Follow the complete lesson:

- [A01 — How Do You Identify the Exact Orin Platform?](../../../docs/orin-kernel/a01-identify-exact-orin-platform.md)

Run from this directory on Orin:

```sh
output="$HOME/kernel-lab/a01-platform-$(date -u +%Y%m%dT%H%M%SZ)"
scripts/collect-platform.sh "$output"
scripts/validate-evidence.sh "$output" expected/required-files.txt
```

Repository fixture test:

```sh
tests/test-platform-evidence.sh
```

The fixture test proves script behavior but is not a substitute for the
learner-side Orin run required by the lesson completion checklist.
