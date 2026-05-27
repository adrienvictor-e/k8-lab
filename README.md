# Adrien's Homelab

Raspberry Pi 5 Kubernetes cluster with observability stack.

## Infrastructure

- **pi-brain** (192.168.0.105 / 10.0.0.1) — K3s control plane
- **pi-body** (192.168.0.106 / 10.0.0.2) — K3s worker
- **pi-3** (planned) — K3s worker + Pi-hole

## Network

- WiFi (192.168.0.0/24) — Internet access via TP-Link router
- Ethernet backbone (10.0.0.0/24) — Direct cluster traffic via dedicated switch

## Stack

- **K3s** v1.34.4 on Raspberry Pi OS Lite (Debian 13)
- **Traefik** ingress controller
- **Prometheus + Grafana** monitoring
- **Cloudflare Tunnel** for remote access

## Endpoints

- https://lab.adrienesquerre.com — Homelab dashboard
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
├── cloudflare/       # Tunnel configs
├── docs/
│   ├── kb.md         # Knowledge base
│   └── postmortems/  # Incident reports
└── scripts/          # Utility scripts
```
