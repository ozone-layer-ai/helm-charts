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
| **Loki** | Log aggregation — SingleBinary mode, filesystem storage, auto-provisioned as a Grafana datasource |
| **Grafana Alloy** | DaemonSet on every node — scrapes host metrics (kubelet, cAdvisor) to Prometheus, collects pod logs to Loki |
| **Dashboard ConfigMaps** | Two auto-provisioned Grafana dashboards: Cluster (metrics) and Cluster Logs (logs) |

## Cluster Dashboard

- **Summary stats**: Total Nodes, Running/Pending/Failed Pods, Cluster CPU & Memory gauges
- **Utilization**: CPU, Memory, Storage timeseries per node
- **Resource Right-Sizing**: CPU & Memory Requested vs Used
- **Saturation & Risk**: CPU Throttling, OOM Kills, PVC Usage
- **Workload Health**: Container Restarts (last 1h)
- **Top Resource Consumers**: Top 10 Pods by CPU, Top 10 Pods by Memory
- **Network**: Network I/O (receive/transmit)
- **Node Capacity**: CPU & Memory Allocatable vs Allocated, Pods per Node

All panels support per-node filtering via a dropdown variable.

## Cluster Logs Dashboard

- **Log Volume**: Stacked bar chart of log counts over time, grouped by level
- **Error Rate**: Timeseries of error/critical log counts
- **Top Logging Pods**: Table and pie chart of the noisiest pods
- **Logs Viewer**: Searchable log stream with level, namespace, and pod filters

## Configuration

| Value | Location | Description |
|-------|----------|-------------|
| **Tenant ID** | `alloy.alloy.extraEnv` → `TENANT_ID` | Identifies the cluster in log labels. Referenced in Alloy config via `env("TENANT_ID")`. |
