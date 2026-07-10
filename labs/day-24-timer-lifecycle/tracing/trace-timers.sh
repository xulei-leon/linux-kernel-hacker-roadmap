#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" \
  "$orin_check" --require-tracefs --require-tool trace-cmd

duration="${1:-10}"
out_dir="${OUT_DIR:-timer-trace-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

trace_events=()
for event in timer_start timer_cancel timer_expire_entry \
             hrtimer_start hrtimer_cancel hrtimer_expire_entry; do
  if [[ -e "$tracefs/events/timer/$event/enable" ]]; then
    trace_events+=(-e "timer:$event")
  else
    echo "optional tracepoint unavailable: timer:$event" >&2
  fi
done

if (( ${#trace_events[@]} == 0 )); then
  echo "no requested timer tracepoints are available" >&2
  exit 1
fi

trace-cmd record -o "$out_dir/timers.dat" \
  "${trace_events[@]}" -- sleep "$duration"

echo "wrote $out_dir"
