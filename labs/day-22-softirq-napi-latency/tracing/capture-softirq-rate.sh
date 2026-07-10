#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" "$orin_check"

interval="${1:-5}"
out_dir="${OUT_DIR:-softirq-rate-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

cat /proc/softirqs > "$out_dir/softirqs.before"
ps -eo pid,comm,psr,stat,pcpu | grep ksoftirqd > "$out_dir/ksoftirqd.before" || true
sleep "$interval"
cat /proc/softirqs > "$out_dir/softirqs.after"
ps -eo pid,comm,psr,stat,pcpu | grep ksoftirqd > "$out_dir/ksoftirqd.after" || true

if command -v trace-cmd >/dev/null 2>&1; then
  trace_events=()
  for event in softirq_entry softirq_exit; do
    if [[ -e "$tracefs/events/irq/$event/enable" ]]; then
      trace_events+=(-e "irq:$event")
    else
      echo "optional tracepoint unavailable: irq:$event" >&2
    fi
  done
  if [[ -d "$tracefs/events/napi" ]]; then
    trace_events+=(-e 'napi:*')
  else
    echo "optional tracepoint group unavailable: napi" >&2
  fi
  if (( ${#trace_events[@]} )); then
    trace-cmd record -o "$out_dir/softirq.dat" \
      "${trace_events[@]}" -- sleep "$interval" >/dev/null 2>&1 || true
  fi
fi

echo "wrote $out_dir"
