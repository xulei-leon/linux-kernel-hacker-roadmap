#!/usr/bin/env bash
set -euo pipefail

evidence="${1:-}"
contract="${2:-}"
if [[ -z "$evidence" || -z "$contract" ]]; then
  echo "usage: $0 EVIDENCE_DIR REQUIRED_FILES" >&2
  exit 2
fi
if [[ ! -d "$evidence" || ! -r "$contract" ]]; then
  echo "evidence directory or required-file contract unavailable" >&2
  exit 2
fi

failed=0
while IFS= read -r file || [[ -n "$file" ]]; do
  [[ -z "$file" ]] && continue
  if [[ ! -s "$evidence/$file" ]]; then
    echo "missing required evidence: $file" >&2
    failed=1
    continue
  fi
  value="$(tr -d '\r\n' < "$evidence/$file")"
  if [[ "$value" == 'unavailable' ]]; then
    echo "required evidence unavailable: $file" >&2
    failed=1
  fi
done < "$contract"

if [[ ! -s "$evidence/SHA256SUMS" ]]; then
  echo "missing required evidence: SHA256SUMS" >&2
  failed=1
elif ! (cd "$evidence" && sha256sum -c SHA256SUMS); then
  echo "software baseline checksum validation failed" >&2
  failed=1
fi

[[ "$failed" -eq 0 ]] || exit 1
echo "software baseline validated: $evidence"
