# Track L — Networking

## Outcome

Trace packet receive/transmit, localize drops, explain NAPI/IRQ/queue placement,
and diagnose TCP throughput using layer-specific evidence.

## Prerequisites

Complete Tracks F and J, and prepare a controlled peer, fixed topology, and
repeatable traffic generator for performance lessons.

## Platform boundary

QEMU and virtio-net teach generic stack, NAPI, queue, and teardown mechanisms.
Tegra MAC/PHY, physical IRQ topology, and Orin throughput conclusions require
the board and a controlled peer.

## Ordered lessons

| ID | Focus |
|---|---|
| L01 | Trace packet receive |
| L02 | Trace packet transmit |
| L03 | Locate a packet-drop layer |
| L04 | Diagnose NAPI budget exhaustion |
| L05 | Diagnose network IRQ imbalance |
| L06 | Diagnose RX queue imbalance |
| L07 | Diagnose TX queue congestion |
| L08 | Diagnose network teardown races |
| L09 | Diagnose TCP retransmissions |
| L10 | Diagnose TCP throughput regression |

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
