#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-memory-snapshot-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

cat /proc/meminfo > "$out_dir/meminfo.txt"
cat /proc/slabinfo > "$out_dir/slabinfo.txt"
vmstat 1 10 > "$out_dir/vmstat.txt"
dmesg -T | grep -iE 'out of memory|oom|allocation failure' > "$out_dir/oom.log" || true

if [[ -r /sys/kernel/debug/kmemleak ]]; then
  echo scan > /sys/kernel/debug/kmemleak || true
  cat /sys/kernel/debug/kmemleak > "$out_dir/kmemleak.txt" || true
fi

echo "wrote $out_dir"

