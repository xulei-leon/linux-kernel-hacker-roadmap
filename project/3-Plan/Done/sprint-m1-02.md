# Sprint M1-02

## 1. Sprint Goal

Implement [FR-002](../../1-Requirement/Done/FR-002-a01-identify-orin-platform.md) as
the first executable Track A lesson.

## 2. Dependencies

- Completed Sprint M1-01 course architecture
- Curriculum A01 and Track A guide
- Git Bash for portable fixture tests

## 3. Included Scope

- `docs/orin-kernel/a01-identify-exact-orin-platform.md`
- `labs/orin-kernel/a01-identify-exact-orin-platform/README.md`
- collection, validation, fixtures, tests, and expected-file contract
- Track A and labs-index links to the delivered lesson

## 4. Excluded Scope

- A02–A07 implementation
- kernel module scaffolding
- writes to Orin boot, firmware, packages, or configuration

## 5. Work Packages

### 5.1 Define evidence behavior with tests

- [x] Write fixture-based tests before production scripts.
- [x] Verify complete fixture fails because scripts do not yet exist.
- [x] Test optional missing values and non-Orin validation failure.

### 5.2 Implement collection and validation

- [x] Implement read-only collection with overridable roots.
- [x] Collect carrier/RAM/SoC evidence and generate sorted `SHA256SUMS` after
      all evidence files.
- [x] Implement required-file and Orin identity validation.
- [x] Run tests green and refactor without changing behavior.

### 5.3 Write the one-hour lesson

- [x] Document metadata, safety, prerequisites, official source, commands,
      evidence interpretation, mismatch decisions, cleanup, and completion.
- [x] Link the lesson from Track A and the labs index.

## 6. Acceptance Criteria

- Tests demonstrate RED before scripts exist and GREEN after implementation.
- Collection is read-only and works against both fixtures and standard Linux
  roots.
- The lesson begins with the three mandatory platform/safety metadata fields.
- Required evidence, unavailable optional evidence, hashes, and model mismatch
  are deterministic.
- The lesson contains no unverified hardware result.

## 7. Verification Requirements

- `bash tests/test-platform-evidence.sh` (use
  `C:/Program Files/Git/bin/bash.exe` only as the Windows fallback)
- Git Bash `bash -n` on lesson scripts/tests
- `git diff --check`
- `npm run docs:build`
- scan lesson files for non-English text and Day terminology

## 8. Implementation Order

1. Complete document review and confirmation.
2. Write tests and observe the required RED failure.
3. Implement the smallest scripts that make tests pass.
4. Write lesson documentation from verified behavior.
5. Complete implementation review and confirmation.
6. Verify, close, and commit Sprint M1-02.

## 9. Risk Controls

- Default to read-only interfaces.
- Quote paths and support spaces.
- Do not require root for fixture tests.
- Treat board mismatch as evidence, not something to overwrite.

## 10. Delivery Conclusion

Completed on 2026-07-11. Document and implementation review gates passed. Fixture tests, Bash syntax, checksum/mismatch/error-path tests, documentation build, whitespace checks, and content scans passed. Real Orin execution remains the learner-side completion requirement and no hardware output was fabricated.
