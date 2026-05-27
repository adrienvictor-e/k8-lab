# Adrien's Homelab

Raspberry Pi 5 Kubernetes cluster with a full observability stack.

## Infrastructure

| Node | IP | Role |
|---|---|---|
| pi-brain | 10.0.0.1 | K3s control plane, Cloudflare Tunnel |
| pi-body | 10.0.0.2 | K3s worker |
| pi-3 | 10.0.0.3 | K3s worker |
| pi-control | 10.0.0.4 | Pi-hole DNS, Ansible control node |

## Network

- Ethernet backbone (10.0.0.0/24) — cluster traffic via dedicated switch
- Cloudflare Tunnel — exposes endpoints publicly over HTTPS without open ports

## Stack

- **K3s** v1.34.4 — lightweight Kubernetes, Flannel CNI, Traefik ingress
- **Prometheus + Grafana** — metrics and dashboards
- **Loki + OTel Collector** — log aggregation via DaemonSet
- **Pi-hole** — DNS on pi-control (systemd, not K3s)
- **Ansible** — node provisioning from pi-control

## Endpoints

- https://lab.adrienesquerre.com — public homelab dashboard
- https://grafana.adrienesquerre.com — Grafana

## Architecture Decisions

### Why pi-control is separate

pi-control runs Pi-hole and Ansible outside the K3s cluster:

- **Pi-hole needs to be stable and isolated** — if it ran inside K3s and the cluster had an issue, DNS would go down for the whole network. Keeping it outside means DNS survives cluster failures.
- **Ansible control node should not manage itself** — it's cleaner to run Ansible from a machine that isn't being managed by it.
- **Separation of concerns** — pi-control handles infrastructure (DNS, provisioning), the K3s cluster handles workloads.

### K3s over full Kubernetes

K3s is a single binary, runs as one process, and is designed for ARM and edge devices. Full Kubernetes would require running etcd, kube-apiserver, kube-controller-manager, and kube-scheduler separately — too much overhead for Raspberry Pi hardware and unnecessary for a 3-node cluster.

### Cloudflare Tunnel over VPN or port forwarding

No inbound ports need to be open on the home router. TLS is handled by Cloudflare. No dynamic DNS needed. The trade-off is a dependency on Cloudflare's infrastructure for external access.

### local-path-provisioner for storage

Simple, no external storage required — volumes are just directories on the node's disk. The trade-off is that data is tied to whichever node the pod lands on; there is no replication. Acceptable for a homelab, not for anything requiring durability guarantees.

### Flannel over Calico or Cilium

Flannel is the K3s default CNI and has the lowest overhead on ARM hardware. Calico and Cilium offer network policy and observability features not needed here. On Raspberry Pis, the simpler option wins.

## Docs

- [Knowledge Base](docs/kb.md) — simple but not always obvious things about the stack
- [Incident Postmortems](docs/postmortems/) — structured incident reports

## Repository Structure

```
homelab/
├── ansible/          # Pi provisioning playbooks
├── k8s/
│   ├── base/         # Core app manifests
│   ├── monitoring/   # Prometheus, Grafana
│   └── logging/      # Loki, OTel
├── cloudflare/       # Tunnel config
├── docs/
│   ├── kb.md         # Knowledge base
│   └── postmortems/  # Incident reports
└── scripts/          # Utility scripts
```
