#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" "$orin_check"

iface="${1:-}"
out_dir="${OUT_DIR:-network-drops-$(date +%Y%m%d-%H%M%S)}"

if [[ -z "$iface" ]]; then
  echo "usage: $0 <interface>" >&2
  exit 2
fi

if ! ip link show dev "$iface" >/dev/null 2>&1; then
  echo "network interface not found: $iface" >&2
  exit 1
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
  trace_events=()
  for group in skb net napi; do
    if [[ -d "$tracefs/events/$group" ]]; then
      trace_events+=(-e "$group:*")
    else
      echo "optional tracepoint group unavailable: $group" >&2
    fi
  done
  if (( ${#trace_events[@]} )); then
    trace-cmd record -o "$out_dir/network.dat" \
      "${trace_events[@]}" -- sleep 10 >/dev/null 2>&1 || true
  fi
fi

echo "wrote $out_dir"
