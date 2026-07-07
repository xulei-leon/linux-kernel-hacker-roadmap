#!/usr/bin/env bash
set -euo pipefail

interval="${1:-5}"
out_dir="${OUT_DIR:-softirq-rate-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

cat /proc/softirqs > "$out_dir/softirqs.before"
ps -eo pid,comm,psr,stat,pcpu | grep ksoftirqd > "$out_dir/ksoftirqd.before" || true
sleep "$interval"
cat /proc/softirqs > "$out_dir/softirqs.after"
ps -eo pid,comm,psr,stat,pcpu | grep ksoftirqd > "$out_dir/ksoftirqd.after" || true

if command -v trace-cmd >/dev/null 2>&1; then
  trace-cmd record -o "$out_dir/softirq.dat" \
    -e irq:softirq_entry \
    -e irq:softirq_exit \
    -e 'napi:*' \
    -- sleep "$interval" >/dev/null 2>&1 || true
fi

echo "wrote $out_dir"

