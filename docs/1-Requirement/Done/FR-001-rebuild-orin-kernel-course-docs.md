# FR-001 Rebuild the Orin Kernel Course Documentation

- `FR-ID`: `FR-001`
- `Title`: Rebuild the Orin Kernel Course Documentation
- `Phase`: Phase 1 - Curriculum reset
- `Development order`: 1
- `Priority`: P0
- `Dependencies`: `docs/orin-nano-super-kernel-curriculum.md`
- `Affected areas`: `README.md`, `index.md`, `.vitepress/`, `docs/`, `labs/`, `resources/`
- `Prototype phase`: No
- `Source type`: Requirement change
- `Original SRS section`: `docs/orin-nano-super-kernel-curriculum.md`

## Goal

Replace the legacy numbered course with an Orin-first course-documentation
system derived exclusively from the approved curriculum specification, while
retaining the useful QEMU environment under a non-Day path.

## Background and Problem

The repository currently exposes a legacy Day 00–30 learning sequence and
several broad debugging documents. The approved curriculum instead defines 15
Tracks and 156 atomic lessons, with explicit Orin/QEMU applicability and safety
levels. Keeping both systems would create conflicting entry points and stale
links.

## Impact

- Remove legacy course documents and Day-numbered labs.
- Retain and relocate the shared QEMU build/boot environment.
- Publish a new course index and one substantial Track guide per Track A–O.
- Rewrite the root and VitePress navigation.
- Preserve the normative curriculum specification and review artifacts.

## Requirements

- The curriculum specification remains the source of truth.
- Existing Day 01–30 labs and old broad course documents are removed.
- The former numbered QEMU environment is moved to
  `labs/orin-kernel/qemu-auxiliary/` and all internal paths are corrected.
- New documentation uses Track/lesson identifiers, never Day identifiers.
- `docs/orin-kernel/README.md` provides the course entry point, learning method,
  platform policy, safety policy, and Track navigation.
- Each Track A–O has a real guide that states its outcome, prerequisites,
  platform boundary, ordered lessons, lab strategy, evidence expectations, and
  completion criteria. Empty lesson scaffolds are forbidden.
- The site build must not hide internal dead links globally.
- Review/workflow documents remain excluded from the published site.

## High-Level Constraints

- Project content is English.
- Orin Nano Super is authoritative for Tegra-specific behavior.
- QEMU is used only where it provides a truthful generic substitute.
- Destructive work is QEMU-first and follows the S0–S3 safety policy.
- No unverified commands, links, hardware claims, or demo results are invented.
- Individual fully executable lessons and demo modules are delivered in later
  vertical slices, one verified problem unit at a time.

## Input

- `docs/orin-nano-super-kernel-curriculum.md`
- Current repository navigation and course paths
- Retained QEMU scripts under `labs/day-00-kernel-build-environment/`

## Output

- A coherent Track-based documentation site
- Fifteen Track guides plus the course index
- A relocated QEMU auxiliary environment
- Updated root entry points and navigation
- No legacy course path exposed as current curriculum

## Failure and Degradation

- If the retained QEMU scripts depend on removed paths, move the required helper
  into the QEMU environment or update the script before deletion.
- If VitePress reports a dead internal link, correct the link rather than
  enabling global suppression.
- If an old document contains useful material, do not silently copy it into a
  new lesson; the new guide may list the skill, while executable content must be
  re-authored and verified later.

## Out of Scope

- Producing 156 fully executable labs in one change
- Claiming Orin hardware results not reproduced on the fixed baseline
- Mapping the legacy Day sequence into the new curriculum
- Changing the approved Track or lesson identifiers

## Minimum Verification

- `git diff --check`
- `npm run docs:build`
- shell syntax/path checks for relocated QEMU scripts
- repository scan for current links to removed Day paths
- manual review that all published content is English

## Acceptance Points

- The site has one unambiguous Orin curriculum entry point.
- Track A–O are present and ordered consistently with the specification.
- Every Track guide is substantive and does not masquerade as a completed lab.
- The shared QEMU environment is reachable under its new path.
- Old course content and navigation are removed.
- The documentation build passes without global dead-link suppression.

## Notes

This FR establishes the documentation architecture. Each atomic lesson becomes
a later independently reviewed vertical slice containing detailed commands,
demo code, diagnosis, fix, and verification.
