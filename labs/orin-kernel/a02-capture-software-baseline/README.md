# Software Baseline Lab

**Primary platform:** Jetson Orin Nano Super

**QEMU alternative:** Not applicable

**Safety level:** S0

This observation-only lab has no module or trigger. Follow the complete
[software-baseline guide](../../../docs/orin-kernel-debugging/capture-software-baseline.md).

```sh
a01="$HOME/kernel-lab/a01-platform-<UTC timestamp>"
output="$HOME/kernel-lab/a02-software-$(date -u +%Y%m%dT%H%M%SZ)"
scripts/collect-software-baseline.sh "$a01" "$output"
scripts/validate-software-baseline.sh "$output" expected/required-files.txt
```

Fixture verification from the repository root:

```sh
labs/orin-kernel/a02-capture-software-baseline/tests/test-software-baseline.sh
```

Fixture success validates script behavior, not real Orin state.
