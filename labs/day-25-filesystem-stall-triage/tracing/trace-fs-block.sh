#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" "$orin_check"

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
  trace_events=()
  [[ -d "$tracefs/events/writeback" ]] && trace_events+=(-e 'writeback:*') ||
    echo "optional tracepoint group unavailable: writeback" >&2
  for event in block_rq_issue block_rq_complete; do
    if [[ -e "$tracefs/events/block/$event/enable" ]]; then
      trace_events+=(-e "block:$event")
    else
      echo "optional tracepoint unavailable: block:$event" >&2
    fi
  done
  if (( ${#trace_events[@]} )); then
    trace-cmd record -o "$out_dir/fs-block.dat" \
      "${trace_events[@]}" -- sleep "$duration"
  fi
else
  echo "trace-cmd not found" >&2
fi

if [[ -n "${iostat_pid:-}" ]]; then
  wait "$iostat_pid" || true
fi

cat /proc/meminfo | grep -E 'Dirty|Writeback' > "$out_dir/dirty-writeback.txt" || true
dmesg -T > "$out_dir/dmesg.txt"

echo "wrote $out_dir"
