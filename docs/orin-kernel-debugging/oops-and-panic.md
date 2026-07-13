# Oops and Panic

## Outcome

Turn ARM64 exception and panic evidence into a source-level root cause while
separating the corruption trigger from the later exposure point.

## Prerequisites

Complete the [QEMU Debug Environment](qemu-debug-environment.md) and
[Kernel Observability](kernel-observability.md) foundations; retain the exact
kernel config, `vmlinux`, module binaries, and source revision.

## Platform boundary

These S2 exercises are QEMU-first. Orin execution is unnecessary unless a
future hardware-specific crash cannot be reproduced generically and has a
separately reviewed recovery plan.

## Focus areas

- NULL pointer dereference
- Invalid function pointer
- Out-of-bounds exposure
- WARN, BUG, oops, and panic differences
- Explicit panic
- Kernel stack overflow
- Module-address decoding
- Trigger point versus root cause

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
