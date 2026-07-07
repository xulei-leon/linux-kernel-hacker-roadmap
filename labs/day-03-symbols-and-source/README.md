# Day 3: Why do symbols decide whether a trace is useful?

## Problem

An oops with raw addresses is hard to act on. The symptom is a trace containing offsets such as `foo_bar+0x38/0x90`, but no source line or clear instruction.

## Kernel Mechanism

Useful symbolization depends on matching artifacts:

- `vmlinux` contains symbols and, when enabled, debug info.
- `System.map` maps addresses to symbols for a specific build.
- `/proc/kallsyms` exposes runtime symbol addresses when permitted.
- Modules need their matching `.ko` files and debug info.

Inlining, compiler optimization, KASLR, and loadable modules can make an address resolve to more than one useful location.

## Problem Analysis

Check artifact identity before decoding:

- Does `vmlinux` come from the same commit and config as the crashed kernel?
- Was KASLR enabled?
- Is the address in core kernel text or a module?
- Does the trace include a symbol offset that avoids needing the absolute runtime address?

If the build identity is wrong, symbolized output can be worse than no output.

## Debug Path

Decode a symbol offset:

```sh
gdb vmlinux
(gdb) list *(foo_bar+0x38)
(gdb) disassemble foo_bar
```

Decode an absolute address when it matches the build address space:

```sh
addr2line -e vmlinux -fip 0xffffffff81234567
```

Decode a copied stack trace:

```sh
scripts/decode_stacktrace.sh vmlinux . < oops.txt
```

For modules, keep the exact `.ko` and use the module load address from the oops or `/proc/modules`.

## Resolution

Record both the decoded line and the uncertainty. For example:

```text
Input: foo_bar+0x38/0x90
Command: gdb vmlinux, list *(foo_bar+0x38)
Resolved: drivers/example/foo.c:214 in foo_bar()
Uncertainty: inlined helper may be the real failing operation; inspect disassembly.
```

## 1-Hour Output

Map one address or symbol offset from an oops to source. Include the command, input address, output file/function, and any uncertainty from inlining, KASLR, or modules.

## Evidence Check

The note must prove that the `vmlinux` or module artifact matches the crashed kernel closely enough to trust the decoded line.

