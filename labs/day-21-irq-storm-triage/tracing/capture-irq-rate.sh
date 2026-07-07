#!/usr/bin/env bash
set -euo pipefail

interval="${1:-5}"
out_dir="${OUT_DIR:-irq-rate-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

cat /proc/interrupts > "$out_dir/interrupts.before"
sleep "$interval"
cat /proc/interrupts > "$out_dir/interrupts.after"

if command -v trace-cmd >/dev/null 2>&1; then
  trace-cmd record -o "$out_dir/irq.dat" \
    -e irq:irq_handler_entry \
    -e irq:irq_handler_exit \
    -- sleep "$interval" >/dev/null 2>&1 || true
fi

echo "wrote $out_dir"

