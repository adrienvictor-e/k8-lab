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
