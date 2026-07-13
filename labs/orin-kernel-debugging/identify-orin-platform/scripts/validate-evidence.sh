#!/usr/bin/env bash
set -euo pipefail

evidence_dir="${1:-}"
required_file="${2:-}"

if [[ -z "$evidence_dir" || -z "$required_file" ]]; then
  echo "usage: $0 EVIDENCE_DIR REQUIRED_FILES" >&2
  exit 2
fi

if [[ ! -d "$evidence_dir" ]]; then
  echo "evidence directory not found: $evidence_dir" >&2
  exit 2
fi

if [[ ! -r "$required_file" ]]; then
  echo "required-file contract not found: $required_file" >&2
  exit 2
fi

failed=0
while IFS= read -r file || [[ -n "$file" ]]; do
  [[ -z "$file" ]] && continue
  if [[ ! -s "$evidence_dir/$file" ]]; then
    echo "missing required evidence: $file" >&2
    failed=1
    continue
  fi
  case "$file" in
    carrier-board.txt|device-tree-serial.txt|soc-revision.txt|nvidia-packages.txt)
      ;;
    *)
      value="$(tr -d '\r\n' < "$evidence_dir/$file")"
      if [[ "$value" == 'unavailable' ]]; then
        echo "required evidence unavailable: $file" >&2
        failed=1
      fi
      ;;
  esac
done < "$required_file"

if [[ ! -s "$evidence_dir/SHA256SUMS" ]]; then
  echo "missing required evidence: SHA256SUMS" >&2
  failed=1
elif ! (cd "$evidence_dir" && sha256sum -c SHA256SUMS); then
  echo "evidence checksum validation failed" >&2
  failed=1
fi

model="$(tr '\n' ' ' < "$evidence_dir/model.txt" 2>/dev/null || true)"
model_lower="${model,,}"
if [[ -n "$model" ]] && [[ "$model_lower" != *'jetson orin nano'* ]]; then
  echo "model is not Jetson Orin Nano: $model" >&2
  failed=1
fi

architecture="$(tr -d '\r\n' < "$evidence_dir/architecture.txt" 2>/dev/null || true)"
if [[ -n "$architecture" ]] && [[ "$architecture" != 'aarch64' ]]; then
  echo "architecture is not aarch64: $architecture" >&2
  failed=1
fi

compatible="$(tr '\n' ' ' < "$evidence_dir/compatible.txt" 2>/dev/null || true)"
compatible_lower="${compatible,,}"
if [[ -n "$compatible" ]] && [[ "$compatible_lower" != *'tegra234'* ]]; then
  echo "compatible data does not contain tegra234" >&2
  failed=1
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "evidence validated: $evidence_dir"
