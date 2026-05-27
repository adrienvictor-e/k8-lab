# Knowledge Base

Simple but not always obvious things about this homelab stack.

---

## Kubernetes Resource Limits

The `resources` block in Helm values (e.g. `grafana-values.yaml`) sets **Kubernetes pod resource limits** — not the application's internal configuration.

```yaml
resources:
  requests:
    memory: 256Mi   # scheduler uses this to place the pod on a node
  limits:
    memory: 768Mi   # kernel OOMKills the container if it exceeds this
```

Exceed the limit → the kernel OOMKills the **container** (`exit code 137`) → Kubernetes restarts it. The pod stays; only the container inside it dies. The kernel operates at the cgroup level (per container) and has no concept of pods.

`requests` affect scheduling only. `limits` are enforced at runtime by the kubelet via cgroups. If a container is repeatedly OOMKilled, raise `limits.memory`. If a node is too full to schedule a pod, adjust `requests.memory`.
