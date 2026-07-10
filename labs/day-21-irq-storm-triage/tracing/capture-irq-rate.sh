#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" bash "$orin_check"

interval="${1:-5}"
out_dir="${OUT_DIR:-irq-rate-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

cat /proc/interrupts > "$out_dir/interrupts.before"
sleep "$interval"
cat /proc/interrupts > "$out_dir/interrupts.after"

if command -v trace-cmd >/dev/null 2>&1 &&
   [[ -e "$tracefs/events/irq/irq_handler_entry/enable" ]] &&
   [[ -e "$tracefs/events/irq/irq_handler_exit/enable" ]]; then
  trace-cmd record -o "$out_dir/irq.dat" \
    -e irq:irq_handler_entry \
    -e irq:irq_handler_exit \
    -- sleep "$interval" >/dev/null 2>&1 || true
elif command -v trace-cmd >/dev/null 2>&1; then
  echo "irq handler tracepoints are unavailable; kept procfs snapshots only" >&2
fi

echo "wrote $out_dir"
