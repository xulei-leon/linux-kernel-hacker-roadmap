# Project 2: Safe MMIO Diagnostic Platform Driver

**Status:** Blueprint. The safety contract is current; driver code and target
evidence remain planned.

## Goal and scope

Build a small Linux platform driver that binds only to explicitly declared
device-tree resources, reads a narrow allow-list of diagnostic registers, and
returns decoded observations. It demonstrates resource ownership, error paths,
test seams, and teardown without pretending to implement a private NVIDIA
interface.

The driver must not accept physical addresses, offsets, widths, or arbitrary
read requests from userspace. It must not expose `/dev/mem`-style access,
`mmap()` MMIO to userspace, write registers, or probe undeclared address
ranges. Unknown compatibles and resources outside the allow-list fail closed.

The trust boundary assumes boot-authenticated or owner-controlled firmware for
the MMIO resource base. Malicious or compromised firmware is out of scope: a
compiled profile can constrain compatible, resource name/span, offsets,
widths, and decoding, but it cannot prove that a hostile firmware-provided
physical base names the intended device.

## Design

- Each supported firmware `compatible` selects immutable `of_device_id` match
  data. That profile contains the required resource name, exact expected span,
  byte order, register descriptors, and a citation to the public specification
  or project-owned test device that defines the span and fields.
- Within that trust boundary, firmware supplies the resource base while
  `probe()` accepts only a compiled profile and its exact named
  `IORESOURCE_MEM`. Firmware cannot change the accepted name/span, register
  offsets, widths, byte order, or decoder.
- Before mapping, reject `end < start`, require
  `resource_size(resource) == expected_span`, and validate every descriptor.
  Require `IS_ALIGNED(resource->start, profile->base_alignment)`. Width must be
  1, 2, or 4 bytes; `check_add_overflow(resource->start, offset,
  &effective_address)` and
  `check_add_overflow(offset, width - 1, &last_byte)` must both be false;
  require `IS_ALIGNED(effective_address, width)`,
  `last_byte < expected_span`, and
  `last_byte < resource_size(resource)`.
- After validation, map only the profile's resource name with
  `devm_platform_ioremap_resource_byname()`. Hardware access and pure decoding
  remain separate.
- The profile selects little- or big-endian access. Reads dispatch by width to
  `ioread8()`, `ioread16()`/`ioread16be()`, or
  `ioread32()`/`ioread32be()`; no native pointer dereference or 64-bit access is
  allowed.
- The sole observation ABI is a mode `0400` debugfs `snapshot` file under a
  per-device directory. It is internal, diagnostic-only, and explicitly not a
  stable userspace ABI. It exposes decoded fields, never address selection.
  Create it with the normal `debugfs_create_file()`, not
  `debugfs_create_file_unsafe()`, so debugfs protects each proxied file
  operation against concurrent removal. Its `struct file_operations` sets
  `.owner = THIS_MODULE`; `.release` frees only the per-open snapshot buffer
  and context with `kvfree()` and must not dereference device-private data.

Opening `snapshot` runs inside the normal debugfs proxy protection, locks the
device mutex, and reads all allow-listed registers into a temporary buffer.
The open succeeds only after the entire decoded snapshot is complete; any
allocation or formatting error returns one errno and exposes zero snapshot
bytes. MMIO read accessors do not report bus errors, so the driver makes no
recoverable-error claim for a failed hardware transaction. A successful open
owns an immutable buffer, so a read performed before removal returns one
coherent software snapshot without touching the device. This does not claim
simultaneous hardware latching.

`remove()` first calls `debugfs_remove_recursive()` while the mapped MMIO and
device-private data are still valid. The normal debugfs proxy rejects new
opens and waits for open/read operations already executing through that proxy
to finish before removal returns. Only then may managed MMIO resources and
driver data be torn down. A file descriptor held open across removal is not a
lease on its buffered snapshot: any later `read()` or `llseek()` through that
descriptor fails with `-EIO`. Closing it remains valid and `.release` frees
only its per-open allocation. The driver relies on the normal proxy and does
not maintain a duplicate active-operation counter.

No descriptor should be based on a guessed Orin register. Target integration
uses only a publicly documented or project-owned test resource. If no suitable
Orin resource is available, retain Orin as unsupported and demonstrate generic
platform-driver mechanics with a clearly labeled test device.

## Inputs, outputs, and failure semantics

Inputs are the matched firmware node, its exactly named `reg` resource, the
compiled match-data profile, and MMIO values read only at allowed offsets.

The output is one bounded, read-only snapshot containing driver/schema version,
resource name, decoded field names and values, validity flags, and a timestamp.
Kernel logs contain lifecycle and error reason codes but no address-space dump.

`probe()` returns an appropriate error for a missing or wrongly named resource,
any span mismatch, mapping failure, unsupported match data, or an invalid
descriptor. A new snapshot open racing removal fails as rejected by debugfs;
after removal, a held descriptor's `read()` and `llseek()` return `-EIO`.
Allocation or formatting failures return their specific errno and never expose
stale or partial data. Reserved or unknown bit patterns are reported as
`unknown`, never silently normalized. No failure expands access beyond the
compiled profile.

## Test layers

1. KUnit tests exercise pure field decoding: normal values, boundaries,
   reserved encodings, masks, and invalid descriptor definitions.
2. KUnit tests validate exact-span, effective-address, and last-byte
   calculations and reject reversed resources, base/effective-address
   overflow, base/effective-address misalignment, wrong width, and both smaller
   and larger resource spans.
3. Platform integration tests cover bind, atomic snapshot open/read, removal
   blocked until an already executing open/read completes, rejection of a new
   open racing removal, `-EIO` from `read()` and `llseek()` on a descriptor
   held across completed removal, safe close/release of that descriptor,
   unbind, and repeated bind/unbind using a controlled test resource.
4. Negative tests prove that unknown compatibles, missing resources, and
   undeclared offsets are rejected and that no writable or arbitrary-address
   interface exists.
5. Target tests collect `dmesg`, interface output, kernel/config identity, and
   cleanup evidence; KASAN, lockdep, or equivalent debug builds are used where
   feasible and recorded truthfully.

## Required artifacts

- Driver source, Kconfig/Makefile integration, firmware binding or test-node
  documentation, and provenance for each compatible, span, and descriptor.
- KUnit suite and test results, plus bind/unbind and negative-test transcripts.
- Example decoded snapshot and lifecycle logs with platform identity.
- Threat/safety note listing prohibited access paths and how each is prevented.
- One failure investigation with symptom, trace, root cause, change, and retest.
- Five-minute demo that shows bind, bounded read, rejected invalid setup, and
  clean unbind.

## Milestones

1. Freeze match data, resource name/span, descriptor provenance, debugfs ABI,
   accessors, concurrency, and teardown contracts.
2. Implement pure decoders and range validation with KUnit tests first.
3. Implement platform probe/remove and the read-only observation interface.
4. Exercise lifecycle and negative paths under kernel debug facilities.
5. Collect labeled target evidence, review safety claims, and rehearse the demo.

## Acceptance criteria

- All decode and range-validation KUnit tests pass, including reserved and
  overflow cases.
- With authenticated or owner-controlled firmware, the driver binds only to
  compiled compatible match data and the exact named resource/span, and all
  base/effective-address, overflow, width, alignment, and last-byte tests pass.
- Every hardware read is generated from the immutable allow-list; code review
  finds no user-selected physical address or offset path, writable register
  path, or userspace MMIO mapping.
- Atomic snapshot, concurrent open/remove, post-removal held-descriptor
  failure, safe close/release, and repeated lifecycle tests complete without
  partial output, leaks, use-after-free, or lock errors in the chosen debug
  configuration.
- Evidence identifies whether the run is Orin/ARM64 or a generic test device;
  generic evidence is not presented as Tegra validation.
