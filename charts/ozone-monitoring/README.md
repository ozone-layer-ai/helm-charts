# Ozone Monitoring — Build Summary

A single umbrella Helm chart (`Ozone-monitoring/`) that deploys a complete Kubernetes monitoring stack in one command:

```bash
helm dependency build Ozone-monitoring/
helm install monitoring Ozone-monitoring/ -n monitoring --create-namespace
```

## Components

| Component | Role |
|-----------|------|
| **kube-prometheus-stack** | Prometheus (time-series DB), Grafana (dashboards), kube-state-metrics (K8s object metrics) |
| **Grafana Alloy** | DaemonSet on every node — scrapes host metrics, kubelet, and cAdvisor, then remote-writes to Prometheus |
| **Dashboard ConfigMap** | 27-panel Grafana dashboard, auto-provisioned via the Grafana sidecar (no manual import) |

## Dashboard Panels

- **Summary stats**: Total Nodes, Running/Pending/Failed Pods, Cluster CPU & Memory gauges
- **Utilization**: CPU, Memory, Storage timeseries per node
- **Resource Right-Sizing**: CPU & Memory Requested vs Used
- **Saturation & Risk**: CPU Throttling, OOM Kills, PVC Usage
- **Workload Health**: Container Restarts (last 1h)
- **Top Resource Consumers**: Top 10 Pods by CPU, Top 10 Pods by Memory
- **Network**: Network I/O (receive/transmit)
- **Node Capacity**: CPU & Memory Allocatable vs Allocated, Pods per Node

All panels support per-node filtering via a dropdown variable.
