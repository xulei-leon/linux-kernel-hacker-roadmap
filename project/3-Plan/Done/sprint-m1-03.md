# Sprint M1-03

## 1. Sprint Goal

Implement [FR-003](../../1-Requirement/Done/FR-003-a02-software-baseline.md) as the
second executable Track A lesson.

## 2. Dependencies

- Completed A01 scripts and evidence contract
- Track A guide and curriculum A02
- Git Bash for fixture tests

## 3. Included Scope

- A02 learner document and lab README
- fixture-tested collection and validation scripts
- required evidence contract
- links from Track A and Labs index

## 4. Excluded Scope

- A03–A07
- kernel modules or destructive triggers
- real-board output committed as sample evidence

## 5. Work Packages

### 5.1 Define evidence behavior with tests

- [x] Write tests before A02 production scripts.
- [x] Observe RED because A02 collector is missing.
- [x] Cover A01 validation, config precedence, module states, FDT/boot/package
      fingerprints, boot mutation, checksum tampering, deterministic reruns,
      `none`/`unavailable`, and non-empty destination refusal.

### 5.2 Implement read-only A02 scripts

- [x] Invoke the delivered A01 validator and contract; record its output,
      resolved input path, and A01 manifest hash.
- [x] Implement override → readable proc config → boot config precedence without
      loading a module, and record the selected source.
- [x] Collect loaded modules, relative module files, raw runtime-FDT hash,
      boot image/initramfs/DTB/DTBO/extlinux hashes, boot selection, Debian
      package/version list, and NVIDIA L4T package/version list.
- [x] Implement all named root/file overrides from FR-003.
- [x] Validate required content, `unavailable` rules, and `SHA256SUMS`.
- [x] Generate a sorted standard `SHA256SUMS` excluding itself.
- [x] Run tests GREEN and refactor without broadening scope.

### 5.3 Write and link the lesson

- [x] Document metadata, prerequisites, official references, exact commands,
      evidence interpretation, mismatch decisions, cleanup, and completion.
- [x] Link A02 from Track A and Labs index.

## 6. Acceptance Criteria

- All fixture and error paths pass.
- Scripts are read-only outside the chosen output directory.
- Manifests use relative sorted paths and stable hashes.
- Documentation distinguishes file presence from active boot proof.
- No real Orin output is fabricated.

## 7. Verification Requirements

- `bash labs/orin-kernel/a02-capture-software-baseline/tests/test-software-baseline.sh`
  with Git Bash fallback on Windows
- `bash -n` for all A02 shell files
- `git diff --check`
- `npm run docs:build`
- English and legacy-Day scans
- read-only forbidden-token scan over A02 production scripts

## 8. Implementation Order

1. Document review and confirmation.
2. TDD RED test.
3. Minimal script implementation and GREEN test.
4. Lesson documentation and links.
5. Implementation review and confirmation.
6. Final verification, workflow closeout, and commit.

## 9. Risk Controls

- Refuse invalid A01 provenance.
- Never copy potentially large or sensitive system artifacts.
- Quote all paths and keep manifests relative to their declared roots.
- Treat `none` as a readable empty set and `unavailable` as a missing source;
  never use an empty file for either state.

## 10. Delivery Conclusion

Completed on 2026-07-12. Document and implementation review gates passed. TDD fixture tests, Bash syntax, read-only token scan, deterministic and mutation manifests, checksum/error paths, documentation build, whitespace checks, and content scans passed. Real Orin execution remains the learner-side completion requirement; no hardware output was fabricated.
