#!/usr/bin/env bash
set -euo pipefail

duration="${1:-10}"
device="${2:-}"
out_dir="${OUT_DIR:-block-latency-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

if [[ -n "$device" && -r "/sys/block/$device/stat" ]]; then
  cat "/sys/block/$device/stat" > "$out_dir/${device}.stat.before"
fi

if command -v iostat >/dev/null 2>&1; then
  iostat -x 1 "$duration" > "$out_dir/iostat.txt" &
  iostat_pid=$!
else
  iostat_pid=""
fi

if command -v trace-cmd >/dev/null 2>&1; then
  trace-cmd record -o "$out_dir/block.dat" \
    -e block:block_bio_queue \
    -e block:block_rq_insert \
    -e block:block_rq_issue \
    -e block:block_rq_complete \
    -- sleep "$duration"
elif [[ -n "$device" ]] && command -v blktrace >/dev/null 2>&1 && command -v blkparse >/dev/null 2>&1; then
  timeout "$duration" blktrace -d "/dev/$device" -o - | blkparse -i - > "$out_dir/blktrace.txt"
else
  echo "trace-cmd not found; provide a device with blktrace installed for fallback" >&2
fi

if [[ -n "${iostat_pid:-}" ]]; then
  wait "$iostat_pid" || true
fi

if [[ -n "$device" && -r "/sys/block/$device/stat" ]]; then
  cat "/sys/block/$device/stat" > "$out_dir/${device}.stat.after"
fi

echo "wrote $out_dir"

