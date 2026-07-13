# Network Performance

## Outcome

Trace packet receive/transmit, localize drops, explain NAPI/IRQ/queue placement,
and diagnose TCP throughput using layer-specific evidence.

## Prerequisites

Complete [Kernel Observability](../orin-kernel-debugging/kernel-observability.md)
and [IRQ and Scheduler Latency](irq-and-scheduler-latency.md), then prepare a
controlled peer, fixed topology, and repeatable traffic generator.

## Platform boundary

QEMU and virtio-net teach generic stack, NAPI, queue, and teardown mechanisms.
Tegra MAC/PHY, physical IRQ topology, and Orin throughput conclusions require
the board and a controlled peer.

## Focus areas

- Trace packet receive
- Trace packet transmit
- Locate a packet-drop layer
- Diagnose NAPI budget exhaustion
- Diagnose network IRQ imbalance
- Diagnose RX queue imbalance
- Diagnose TX queue congestion
- Diagnose network teardown races
- Diagnose TCP retransmissions
- Diagnose TCP throughput regression

## Concrete diagnostic decision

Before changing driver queues, identify the first layer whose drop/error counter
increases: NIC/driver, NAPI/backlog, protocol, qdisc, or socket/application.
Later-layer symptoms cannot establish an earlier-layer drop.

## Lab and evidence policy

Every experiment fixes topology, peer, MTU, offloads, queue count, CPU affinity,
duration, and offered load. A QEMU path explicitly labels virtio observations
as generic and lists the Tegra validation still required.

## Completion criteria

You can draw the tested receive/transmit path, name the first failing layer, and
verify a queue, affinity, driver, or protocol correction without changing
uncontrolled variables.
