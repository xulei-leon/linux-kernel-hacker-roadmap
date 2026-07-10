# Day 10: Given a NULL-pointer oops, how do you prove the bad access?

## Platform

**Mode: Orin analysis, QEMU trigger. Risk: destructive.** Build and load the
module with `trigger_null=1` only in Day 00 QEMU. Use Orin for saved-oops
decoding and safe fix verification.

Do not run the destructive trigger on the primary Orin installation.

## Problem

The log says the kernel hit a NULL pointer or invalid address, but the root cause might be earlier. The symptom is an oops with a fault address such as `0000000000000008`.

## Kernel Mechanism

On x86, a page fault reports the faulting address in `CR2`, the instruction in `RIP`, and an error code that helps classify read, write, user, supervisor, and instruction-fetch faults. Kernel code must distinguish kernel pointers from user pointers and use helpers such as `copy_to_user()`, `copy_from_user()`, and `access_ok()` where required.

## Problem Analysis

Classify the fault:

- Is the fault address near zero, a poison pattern, user range, or canonical kernel address?
- Does the instruction read, write, or execute memory?
- Was the current context process, interrupt, softirq, or worker?
- Is the pointer expected to be user memory?
- Did the trace enter through a syscall, ioctl, driver callback, or internal worker?

The bad access is proved by connecting the fault address, instruction, and pointer source.

## Debug Path

Collect the oops fields:

```text
RIP:
Code:
CR2:
PF error code:
Process:
Call Trace:
```

Decode source:

```sh
gdb vmlinux
(gdb) list *(faulting_function+0xoffset)
(gdb) disassemble /m faulting_function
```

For user-copy paths, inspect the boundary:

```text
Does the pointer come from userspace?
Was access checked with the right helper?
Is the code dereferencing before copy_from_user()?
Can the fault happen after the object was freed?
```

## Resolution

Page-fault triage note:

```text
Fault address:
Instruction:
Access type:
Pointer source:
Execution context:
User or kernel memory:
Likely bad assumption:
Evidence still missing:
```

Fix patterns include NULL checks at the ownership boundary, correct user-copy helpers, lifetime fixes, or rejecting invalid state earlier.

## 1-Hour Output

Analyze one invalid-address trace and fill the triage note.

## Evidence Check

The note must connect fault address, instruction, access type, and context before naming a fix direction.
