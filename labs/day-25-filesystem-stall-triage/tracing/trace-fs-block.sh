#!/usr/bin/env bash
set -euo pipefail

duration="${1:-10}"
out_dir="${OUT_DIR:-fs-block-trace-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

if command -v iostat >/dev/null 2>&1; then
  iostat -x 1 "$duration" > "$out_dir/iostat.txt" &
  iostat_pid=$!
else
  iostat_pid=""
fi

if command -v trace-cmd >/dev/null 2>&1; then
  trace-cmd record -o "$out_dir/fs-block.dat" \
    -e 'writeback:*' \
    -e block:block_rq_issue \
    -e block:block_rq_complete \
    -- sleep "$duration"
else
  echo "trace-cmd not found" >&2
fi

if [[ -n "${iostat_pid:-}" ]]; then
  wait "$iostat_pid" || true
fi

cat /proc/meminfo | grep -E 'Dirty|Writeback' > "$out_dir/dirty-writeback.txt" || true
dmesg -T > "$out_dir/dmesg.txt"

echo "wrote $out_dir"
