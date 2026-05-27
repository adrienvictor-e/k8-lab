# Homelab Context

## Infrastructure
- 4x Raspberry Pi 5 on Ethernet backbone (10.0.0.0/24)
- pi-brain (10.0.0.1) — K3s control plane, Cloudflare Tunnel
- pi-body (10.0.0.2) — K3s worker
- pi-3 (10.0.0.3) — K3s worker
- pi-control (10.0.0.4) — Pi-hole DNS, Ansible control node

## K3s Cluster
- K3s v1.34.4, Flannel CNI over eth0
- Kubeconfig: /etc/rancher/k3s/k3s.yaml
- Namespaces: default (apps), monitoring (Prometheus/Grafana/Loki), kube-system

## Key Paths
- Homelab repo: ~/homelab/
- K8s manifests: ~/homelab/k8s/
- Ansible playbooks: ~/homelab/ansible/playbooks/
- Ansible inventory: ~/homelab/ansible/inventory/hosts.yml
- Cloudflare tunnel config: /etc/cloudflared/config.yml
- Helm values: ~/homelab/k8s/monitoring/helm-values/

## Monitoring Stack
- Prometheus + Grafana via kube-prometheus-stack Helm chart
- Loki for logs via Helm
- OTel Collector DaemonSet shipping logs to Loki
- Grafana accessible at https://grafana.adrienesquerre.com

## Remote Access
- Cloudflare Tunnel: brain.adrienesquerre.com (SSH), lab.adrienesquerre.com (web), grafana.adrienesquerre.com (Grafana)
- Ansible runs from pi-control

## Common Commands
- kubectl get pods --all-namespaces
- ansible-playbook -i ~/homelab/ansible/inventory/hosts.yml ~/homelab/ansible/playbooks/all.yml
- helm list -n monitoring

## Portfolio Website (React)
The public portfolio at https://adrienvictor-e.github.io showcases the homelab as a project.
- Repo: https://github.com/adrienvictor-e/adrienvictor-e.github.io
- Cloned on pi-brain at: ~/adrienvictor-e.github.io/
- Deploy: push to `main` triggers GitHub Actions → GitHub Pages (automatic, no manual step)
- Build check before pushing: `cd ~/adrienvictor-e.github.io && CI=false npx react-scripts build`
- Push: `git push origin main` (HTTPS credentials cached on pi-brain)

### What to keep in sync with the homelab
Whenever the homelab cluster changes in a meaningful way, update these two files:

| File | What it contains |
|------|-----------------|
| `src/components/Cards.js` | Home page card — one-liner subtext for the homelab project |
| `src/components/pages/Infrastructure.js` | Detail page — bullet list describing the cluster setup |

### What triggers an update
- Node count changes (adding/removing Pis)
- Monitoring stack changes (new tools, new panel types)
- New public-facing URLs or features worth highlighting
- Major version upgrades that change the stack description

### Update workflow
1. `cd ~/adrienvictor-e.github.io`
2. Edit `src/components/Cards.js` (subtext on the homelab CardItemLink)
3. Edit `src/components/pages/Infrastructure.js` (bullet list under Kubernetes Homelab)
4. `CI=false npx react-scripts build` — confirm build passes
5. `git add src/components/Cards.js src/components/pages/Infrastructure.js`
6. `git commit -m "..."` then `git push origin main`
7. GitHub Actions deploys automatically — live in ~2 minutes at https://adrienvictor-e.github.io

## Working Practices
- Always document incidents and fixes in ~/homelab/docs/postmortems/ as INC-YYYY-NNN-short-description.md
- Always commit changes to git after making fixes
- Run kubectl commands with KUBECONFIG=/etc/rancher/k3s/k3s.yaml
- Test changes in --check mode before applying Ansible playbooks
- Use vim for file editing
- When updating the homelab, check if the portfolio website also needs updating (see Portfolio Website section above)
