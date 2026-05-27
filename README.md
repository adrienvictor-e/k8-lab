# Adrien's Homelab

Raspberry Pi 5 Kubernetes cluster with a full observability stack.

## Infrastructure

| Node | IP | Role |
|---|---|---|
| pi-brain | 10.0.0.1 | K3s control plane, Cloudflare Tunnel |
| pi-body | 10.0.0.2 | K3s worker |
| pi-3 | 10.0.0.3 | K3s worker |
| pi-control | 10.0.0.4 | Pi-hole DNS, Ansible control node |

### Why pi-control is separate

pi-control runs Pi-hole and Ansible outside the K3s cluster:

- **Pi-hole needs to be stable and isolated** — if it ran inside K3s and the cluster had an issue, DNS would go down for the whole network. Keeping it outside means DNS survives cluster failures.
- **Ansible control node should not manage itself** — it's cleaner to run Ansible from a machine that isn't being managed by it.
- **Separation of concerns** — pi-control handles infrastructure (DNS, provisioning), the K3s cluster handles workloads.


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
