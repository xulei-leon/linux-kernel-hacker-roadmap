# Sprint M1-01

## 1. Sprint Goal

Implement [FR-001](../../1-Requirement/Done/FR-001-rebuild-orin-kernel-course-docs.md)
by replacing the legacy Day-based curriculum with the approved Track-based
documentation system.

Core outcome:

- A buildable, navigable Orin-first course site with Track A–O guides and a
  relocated QEMU auxiliary environment.

## 2. Dependencies

- `docs/orin-nano-super-kernel-curriculum.md`
- Existing VitePress configuration
- Existing QEMU build/boot scripts

Coordination note:

- The untracked curriculum specification and its completed review changes are
  user-owned inputs to this Sprint and must be preserved.

## 3. Included Scope

- `FR-001` Rebuild the Orin Kernel Course Documentation
- `README.md`, `index.md`, `.vitepress/config.mts`
- `docs/orin-kernel/`
- `labs/orin-kernel/qemu-auxiliary/`
- `resources/orin-kernel/`
- `challenges/docs/1-Requirement/kernel-debugging-challenges-requirements.md`
- deletion of superseded course content

## 4. Excluded Scope

- Fully implementing all 156 lesson labs and demo modules
- Reusing old Day lessons as authoritative new lesson content
- Making new hardware claims without Orin verification

Reason:

- The curriculum requires each executable lesson to be an independently
  verified one-problem unit. Bulk placeholder lessons would violate the source
  specification and `AGENTS.md`.

## 5. Work Packages

### 5.1 Reset and migrate content

Goal:

- Remove conflicting legacy content while retaining the QEMU foundation.

Tasks:

- [x] Move the QEMU environment to its Track-based path.
- [x] Correct relative paths and remove Day terminology.
- [x] Remove Day 01–30 labs, `labs/common`, `docs/00-foundation/` through
      `docs/06-code-quality/`, `docs/04-debugging/README.md`,
      `docs/jetson-orin-nano-super-bsp-kernel-driver-diagnostic-lab.md`,
      `docs/kernel-debug-skill-training-plan.md`, and the superseded challenge
      requirement tied to Day labs.

Tests:

- [x] Check relocated shell scripts for syntax and missing local paths.
- [x] Scan for links to removed paths.
- [x] Record the tracked deletion inventory and verify every path is inside the
      repository and named in this Sprint before deletion.
- [x] Confirm no surviving file refers to `labs/common/` or the old QEMU path.

### 5.2 Publish the course-documentation system

Goal:

- Make the approved curriculum usable as the project course entry point.

Tasks:

- [x] Create `docs/orin-kernel/README.md`.
- [x] Create substantive Track A–O guides derived from Section 8.
- [x] Create only `resources/orin-kernel/README.md`, defining official resource
      categories, link-verification policy, and review-date requirements.

Tests:

- [x] Confirm all 15 Track guides exist and are linked.
- [x] Confirm every guide declares outcomes, platform boundaries, lesson order,
      lab approach, evidence, and completion criteria.
- [x] Confirm every guide contains at least one concrete diagnostic decision or
      trade-off, contains no copied legacy lesson prose, and is explicitly
      labeled as a Track guide rather than a completed executable lesson.
- [x] Run a mid-Sprint review checklist across all fifteen Track guides before
      changing navigation.

### 5.3 Rewrite project and site navigation

Goal:

- Expose only the new course and retained QEMU environment as current content.

Tasks:

- [x] Rewrite `README.md` and `index.md`.
- [x] Replace Day-aware navigation with Track-aware navigation.
- [x] Remove Day-specific title parsing and hard-coded Day navigation.
- [x] Preserve the review exclusion and extend source exclusion to
      `docs/1-Requirement/**` and `docs/3-Plan/**`.
- [x] Keep the curriculum specification out of learner navigation while leaving
      its direct built URL available to authors.
- [x] Create `labs/orin-kernel/README.md` as a real Labs index linking the nested
      QEMU auxiliary environment.
- [x] Disable global dead-link suppression.

Tests:

- [x] Run the production VitePress build.
- [x] Check generated navigation and internal Markdown links.
- [x] Confirm internal dead links fail the production build and no global
      suppression remains.
- [x] Confirm FR/Sprint/review artifacts are absent from generated learner
      navigation and the course index contains Orin/QEMU and S0–S3 policies.

## 6. Acceptance Criteria

- The repository has no active Day-based curriculum.
- Track A–O guides match the approved curriculum ordering and scope.
- The QEMU environment is preserved under a non-Day path.
- The project entry points describe Orin as primary and QEMU as conditional.
- No empty course directories or placeholder lessons are created.
- Documentation and QEMU checks pass.

## 7. Verification Requirements

Project- and package-declared commands:

- `git diff --check`
- `npm run docs:build`

Inferred commands:

- `bash -n` for relocated shell scripts — smallest syntax check for shell labs.
- targeted `rg` scans — detects stale Day paths and non-English course text.

Targeted review:

- Compare the Track/lesson lists against Section 8 of the curriculum spec.

## 8. Implementation Order

1. Review and confirm this FR/Sprint pair.
2. Move QEMU content before deleting old paths.
3. Remove superseded course documents and labs.
4. Add the new course index and Track guides.
5. Rewrite navigation and enforce dead-link checks.
6. Run verification, implementation review, and confirmation.

## 9. Risk Controls

- Preserve unrelated user changes and the reviewed curriculum specification.
- The dated official NVIDIA baseline citation is intentionally deferred to the
  first executable Track A hardware lesson, as required by curriculum Section
  14.
- Move retained files before deleting source directories.
- Use one shell end-to-end for filesystem operations and verify absolute paths.
- Do not turn Track guides into unverified executable tutorials.
- Treat any build or dead-link failure as blocking.

## 10. Delivery Conclusion

Completed on 2026-07-11.

- Document review and review-confirm gates passed; accepted changes were applied.
- The legacy curriculum was removed and the QEMU environment was relocated.
- The learner site now contains the course index and 15 Track guides covering
  all 156 approved lesson IDs.
- Implementation review and code-review-confirm gates passed; accepted changes
  were applied.
- `git diff --check`, `npm run docs:build`, Git Bash syntax checks, the QEMU
  smoke test, stale-path scans, language checks, page-count checks, and workflow
  exclusion checks passed.
