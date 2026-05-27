# INC-2026-001 — Grafana CrashLoopBackOff (OOMKill)

**Date:** 2026-05-27  
**Duration:** ~2 days (detected 2026-05-27, started ~2026-05-25 after monitoring stack upgrade)  
**Severity:** High — Grafana completely unavailable, all dashboard iframes on lab.adrienesquerre.com broken  
**Status:** Resolved  

---

## Summary

Grafana entered a CrashLoopBackOff loop after being OOMKilled repeatedly. The container memory limit of 256Mi was insufficient for Grafana 13, which requires ~300Mi+ at steady state. The pod would start successfully, serve traffic for ~2 minutes, then get killed by the kernel OOM handler. Between kills it was briefly reachable, causing the "no available server" / intermittent loading behaviour observed on the lab website.

---

## Timeline

| Time (UTC) | Event |
|---|---|
| ~2026-05-25 16:27 | `kube-prometheus-stack` upgraded to chart 85.3.3 / Grafana 13.0.1 (Helm revision 6) |
| ~2026-05-25 16:30 | Grafana first OOMKilled; CrashLoopBackOff begins |
| 2026-05-27 15:28 | 10th OOMKill observed; pod last died at 15:28:42 UTC |
| 2026-05-27 17:25 | Issue detected during lab website health check |
| 2026-05-27 17:31 | Memory limit raised to 512Mi; Helm upgrade applied (revision 7) |
| 2026-05-27 17:32 | Grafana rollout complete; pod stable at 226Mi, 0 restarts |

---

## Root Cause

Grafana was upgraded from an earlier version to **Grafana 13.0.1** (`grafana/grafana:13.0.1-security-01`) as part of a `kube-prometheus-stack` Helm upgrade. Grafana 13 has a higher baseline memory footprint than the previous version. The existing resource limit of **256Mi** was no longer sufficient.

The pod's steady-state memory usage stabilised at **~296Mi** — approximately 40Mi over the limit — causing the kernel to OOM-kill the `grafana` container (exit code 137) shortly after startup each time. The crash cycle had a period of ~2 minutes (startup → serve → kill → backoff → restart).

**Contributing factor:** The memory limit was set conservatively at 256Mi in the initial Helm values without a headroom buffer, and was not revisited during the chart upgrade.

---

## Impact

- `https://grafana.adrienesquerre.com` — fully unavailable (intermittent brief windows between restarts)
- All 20 Grafana iframe panels on `https://lab.adrienesquerre.com` — "no available server" errors
- Alertmanager, Prometheus, Node Exporter, Loki — **unaffected**
- Duration undetected: ~2 days

---

## Detection

Detected manually during a routine check of the lab website UI. No alert fired because:
1. No alerting rule existed for Grafana pod restarts / CrashLoopBackOff
2. Grafana itself (the usual alerting UI) was the service that was down

---

## Resolution

Updated `~/homelab/k8s/monitoring/helm-values/grafana-values.yaml`:

```yaml
# Before
resources:
  requests:
    memory: 128Mi
  limits:
    memory: 256Mi

# After
resources:
  requests:
    memory: 256Mi
  limits:
    memory: 512Mi
```

Ran `helm upgrade monitoring kube-prometheus-stack --reuse-values --values grafana-values.yaml`.  
Grafana came up cleanly; memory usage stabilised at **226Mi** with 512Mi headroom.

---

## Action Items

| # | Action | Priority |
|---|---|---|
| 1 | Add a PrometheusRule alert for `kube_pod_container_status_restarts_total > 5` in the monitoring namespace | High |
| 2 | Add a PrometheusRule alert for OOMKill events (`kube_pod_container_status_last_terminated_reason == "OOMKilled"`) | High |
| 3 | Review all container memory limits after chart upgrades — add upgrade checklist note to CLAUDE.md | Medium |
| 4 | Consider setting Grafana memory limit to `768Mi` after observing usage over the next week | Low |

---

## Lessons Learned

- **Upgrading a Helm chart that bumps a major app version (Grafana 12→13) requires re-evaluating resource limits.** Major versions often carry meaningful memory footprint increases.
- **The monitoring stack being down silences its own alerts.** Always have a secondary signal (e.g. a Cloudflare health check or uptime monitor on grafana.adrienesquerre.com) that doesn't depend on Grafana being up.
- **Two days went undetected** because there was no external probe and the service was intermittently reachable (masking a total outage as "flakiness").
