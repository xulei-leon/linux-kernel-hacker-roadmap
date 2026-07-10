# Day 27: How do packet drops become kernel debugging tasks?

## Platform

**Mode: Orin. Risk: low observation.** Use the real Jetson Ethernet or wireless
interface and a bounded traffic source. Record the interface driver, link
state, IRQ affinity, offloads, and thermal/frequency state.

## Problem

Packets are lost, but "network is flaky" does not identify the kernel layer. The symptom can come from driver RX/TX, NAPI, qdisc, socket buffers, or protocol drops.

## Kernel Mechanism

Packets move through device driver rings, NAPI polling, socket buffers, qdisc scheduling, protocol processing, and userspace consumption. Drops are often visible as counters, but each counter belongs to a layer.

## Problem Analysis

Map the drop:

- Driver ring or hardware: `ethtool -S`.
- NAPI/softirq pressure: `/proc/softirqs`, `ksoftirqd`, NAPI tracepoints.
- Qdisc: `tc -s qdisc`.
- Socket buffer: `ss -tin`, receive queue, retransmits.
- Protocol: SNMP counters under `/proc/net/snmp` and subsystem logs.

## Debug Path

Counters:

```sh
ip -s link show dev eth0
ethtool -S eth0
tc -s qdisc show dev eth0
ss -tin
cat /proc/net/snmp
```

Drop monitoring:

```sh
dropwatch -l kas
```

Tracepoint discovery:

```sh
trace-cmd list -e 'skb:*' 'net:*' 'napi:*'
```

Layer map:

```text
Symptom:
Interface:
Driver counter:
NAPI or softirq signal:
Qdisc counter:
Socket buffer signal:
Protocol counter:
Likely layer:
Next probe:
```

## Resolution

Fix direction follows the layer. Driver drops may need ring, interrupt, or firmware evidence. Qdisc drops need queue discipline and shaping review. Socket drops need application read rate or buffer sizing. Protocol drops need protocol-specific state.

## 1-Hour Output

Map one packet-loss symptom to driver, NAPI, qdisc, socket buffer, or protocol evidence.

## Evidence Check

The map must include counter source, kernel layer, and next probe.
