#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" "$orin_check"

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

trace_events=()
if command -v trace-cmd >/dev/null 2>&1; then
  for event in block_bio_queue block_rq_insert block_rq_issue block_rq_complete; do
    if [[ -e "$tracefs/events/block/$event/enable" ]]; then
      trace_events+=(-e "block:$event")
    else
      echo "optional tracepoint unavailable: block:$event" >&2
    fi
  done
fi

if (( ${#trace_events[@]} >= 2 )); then
  trace-cmd record -o "$out_dir/block.dat" \
    "${trace_events[@]}" -- sleep "$duration"
elif [[ -n "$device" ]] && command -v blktrace >/dev/null 2>&1 && command -v blkparse >/dev/null 2>&1; then
  timeout "$duration" blktrace -d "/dev/$device" -o - | blkparse -i - > "$out_dir/blktrace.txt"
else
  echo "usable block tracepoints are unavailable; provide a device with blktrace installed" >&2
fi

if [[ -n "${iostat_pid:-}" ]]; then
  wait "$iostat_pid" || true
fi

if [[ -n "$device" && -r "/sys/block/$device/stat" ]]; then
  cat "/sys/block/$device/stat" > "$out_dir/${device}.stat.after"
fi

echo "wrote $out_dir"
