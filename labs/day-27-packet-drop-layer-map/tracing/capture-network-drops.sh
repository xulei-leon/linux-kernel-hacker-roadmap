#!/usr/bin/env bash
set -euo pipefail

iface="${1:-}"
out_dir="${OUT_DIR:-network-drops-$(date +%Y%m%d-%H%M%S)}"

if [[ -z "$iface" ]]; then
  echo "usage: $0 <interface>" >&2
  exit 2
fi

mkdir -p "$out_dir"

ip -s link show dev "$iface" > "$out_dir/ip-link.txt"
ethtool -S "$iface" > "$out_dir/ethtool-stats.txt" 2>&1 || true
tc -s qdisc show dev "$iface" > "$out_dir/qdisc.txt" 2>&1 || true
ss -tin > "$out_dir/ss-tin.txt" 2>&1 || true
cat /proc/net/snmp > "$out_dir/snmp.txt"
cat /proc/softirqs > "$out_dir/softirqs.txt"

if command -v dropwatch >/dev/null 2>&1; then
  timeout 10 dropwatch -l kas > "$out_dir/dropwatch.txt" 2>&1 || true
fi

if command -v trace-cmd >/dev/null 2>&1; then
  trace-cmd record -o "$out_dir/network.dat" \
    -e 'skb:*' \
    -e 'net:*' \
    -e 'napi:*' \
    -- sleep 10 >/dev/null 2>&1 || true
fi

echo "wrote $out_dir"

