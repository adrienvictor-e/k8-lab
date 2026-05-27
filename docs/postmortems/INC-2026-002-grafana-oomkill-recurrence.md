# INC-2026-002 — Grafana OOMKill Recurrence (512Mi limit insufficient)

**Date:** 2026-05-27
**Duration:** Unknown — no detection timestamp (discovered during routine check)
**Severity:** High — Grafana iframes on lab.adrienesquerre.com showing "no available server"
**Status:** Resolved
**Visibility:** Public — no sensitive details exposed

---

## Summary

Grafana became intermittently unavailable due to repeated OOMKills, causing all iframe panels on the lab website to fail with "no available server". This is a recurrence of INC-2026-001: the 512Mi memory limit set in the previous fix proved insufficient as Grafana 13's actual steady-state usage grew to ~619Mi.

---

## Timeline

| Time (UTC) | Event |
|---|---|
| ~2026-05-25 | Grafana 13 memory usage begins climbing past 512Mi limit |
| 2026-05-27 19:35 | Grafana logs show 504 timeouts on dashboard API, pod OOMKilled repeatedly |
| 2026-05-27 19:38 | Issue detected during routine lab website check |
| 2026-05-27 21:38 | Memory limit raised to 768Mi, Helm upgrade applied (revision 9) |
| 2026-05-27 21:42 | Grafana rollout complete, pod stable at ~310Mi |

---

## Root Cause

> See KB: [Kubernetes Resource Limits](../kb.md#kubernetes-resource-limits)

The 512Mi memory limit set in INC-2026-001 was not sufficient for Grafana 13's actual steady-state footprint. At the time of that fix, usage stabilised at ~226Mi — well within the new limit. Over the following days, usage grew to ~619Mi, exceeding the cap and triggering OOMKills again.

INC-2026-001 included a low-priority action item to raise the limit to 768Mi after a week of observation. That action item was never completed, and the threshold was crossed before it was revisited.

---

## Impact

- `https://grafana.adrienesquerre.com` — intermittently unavailable
- All iframe panels on `https://lab.adrienesquerre.com` — "no available server" errors
- Prometheus, Loki, Alertmanager, Node Exporter — unaffected
- Duration undetected: unknown (no external probe in place)

---

## Detection

Detected manually during a routine check of the lab website. Same detection gap as INC-2026-001 — no alert exists for Grafana pod restarts or OOMKill events, and Grafana being down silences its own alerting.

---

## Resolution

Updated `~/homelab/k8s/monitoring/helm-values/grafana-values.yaml`:

```yaml
# Before
resources:
  requests:
    memory: 256Mi
  limits:
    memory: 512Mi

# After
resources:
  requests:
    memory: 256Mi
  limits:
    memory: 768Mi
```

Ran `helm upgrade monitoring kube-prometheus-stack --reuse-values --values grafana-values.yaml`.
Grafana came up cleanly; memory usage stabilised at ~310Mi with 458Mi headroom.

---

## Action Items

| # | Action | Priority |
|---|---|---|
| 1 | Add PrometheusRule alert for OOMKill events (`kube_pod_container_status_last_terminated_reason == "OOMKilled"`) — carried over from INC-2026-001, still not done | High |
| 2 | Add PrometheusRule alert for pod restart count > 3 in monitoring namespace | High |
| 3 | Add an external uptime probe (e.g. Cloudflare health check) on grafana.adrienesquerre.com so Grafana being down doesn't silence its own alerting | Medium |

---

## Lessons Learned

- **Low-priority action items get skipped.** The mitigation from INC-2026-001 explicitly flagged raising the limit to 768Mi — it was marked low priority and never done. This incident is a direct consequence.
- **The same detection gap fired twice.** Two incidents, same root cause for not catching it: no external probe, no OOMKill alert. These alerts should have been created after the first incident.
