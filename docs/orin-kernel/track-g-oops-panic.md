# Track G — Oops and Panic

## Outcome

Turn ARM64 exception and panic evidence into a source-level root cause while
separating the corruption trigger from the later exposure point.

## Prerequisites

Complete Track C and the symbol/instrumentation foundations in Track F; retain
the exact kernel config, `vmlinux`, module binaries, and source revision.

## Platform boundary

These S2 exercises are QEMU-first. Orin execution is unnecessary unless a
future hardware-specific crash cannot be reproduced generically and has a
separately reviewed recovery plan.

## Ordered lessons

| ID | Failure class |
|---|---|
| G01 | NULL pointer dereference |
| G02 | Invalid function pointer |
| G03 | Out-of-bounds exposure |
| G04 | WARN, BUG, oops, and panic differences |
| G05 | Explicit panic |
| G06 | Kernel stack overflow |
| G07 | Module-address decoding |
| G08 | Trigger point versus root cause |

## Concrete diagnostic decision

An oops at a list traversal does not prove the traversal is wrong. Decode the
faulting instruction and object address, then find who last initialized,
removed, freed, or overwrote the object. The reporting stack identifies the
exposure path; allocator or earlier trace evidence may identify the cause.

## Demo and evidence policy

Each lesson uses a distinct, explicit micro-module trigger. Required evidence
includes full console output, `vmlinux`, module section addresses, config,
source revision, `addr2line`/disassembly result, minimal fix, repeated trigger,
and absence of the original stable signature after repair.

## Completion criteria

You can explain the exception class, PC/LR and call chain, locate the exact
instruction, distinguish trigger/exposure/root cause, and verify a minimal fix.
