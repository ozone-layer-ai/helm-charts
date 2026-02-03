# node-problem-detector
This chart is a fork of https://github.com/deliveryhero/helm-charts/tree/master/stable/node-problem-detector with some tweaks.
This chart installs a [node-problem-detector](https://github.com/kubernetes/node-problem-detector) daemonset. This tool aims to make various node problems visible to the upstream layers in cluster management stack. It is a daemon which runs on each node, detects node problems and reports them to apiserver.

**Homepage:** <https://github.com/kubernetes/node-problem-detector>

## Source Code

* <https://github.com/kubernetes/node-problem-detector>
* <https://kubernetes.io/docs/concepts/architecture/nodes/#condition>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| dnsConfig | object | `{}` |  |
| dnsPolicy | string | `"ClusterFirst"` |  |
| env | string | `nil` |  |
| extraContainers | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| hostNetwork | bool | `false` | Run pod on host network Flag to run Node Problem Detector on the host's network. This is typically not recommended, but may be useful for certain use cases. |
| hostPID | bool | `false` |  |
| hostUsers | bool | `true` | Use host user namespace (true) or create pod user namespace (false) Set to false to enable user namespaces for enhanced security isolation Default is true (uses host user namespace). See [Use a User Namespace With a Pod](https://kubernetes.io/docs/tasks/configure-pod-container/user-namespaces/). |
| image.digest | string | `""` | the image digest. If given it takes precedence over a given tag. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.k8s.io/node-problem-detector/node-problem-detector"` |  |
| image.tag | string | `"v1.35.1"` |  |
| imagePullSecrets | list | `[]` |  |
| labels | object | `{}` |  |
| logDir.host | string | `"/var/log/"` | log directory on k8s host |
| logDir.pod | string | `""` | log directory in pod (volume mount), use logDir.host if empty |
| maxUnavailable | int | `1` | The max pods unavailable during an update |
| metrics.annotations | object | `{}` | Override all default annotations when `metrics.enabled=true` with specified values. |
| metrics.enabled | bool | `false` | Expose metrics in Prometheus format with default configuration. |
| metrics.prometheusRule.additionalLabels | object | `{}` |  |
| metrics.prometheusRule.additionalRules | list | `[]` |  |
| metrics.prometheusRule.defaultRules.create | bool | `true` |  |
| metrics.prometheusRule.defaultRules.disabled | list | `[]` |  |
| metrics.prometheusRule.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.additionalRelabelings | list | `[]` |  |
| metrics.serviceMonitor.attachMetadata.node | bool | `false` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.metricRelabelings | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| priorityClassName | string | `"system-node-critical"` |  |
| rbac.clusterRole.extraRules | list | `[]` |  |
| rbac.create | bool | `true` |  |
| rbac.pspEnabled | bool | `false` |  |
| resizePolicy | list | `[]` | Container resize policy for in-place vertical scaling See https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/ |
| resources | object | `{}` |  |
| securityContext.privileged | bool | `true` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.labels | object | `{}` |  |
| serviceAccount.name | string | `nil` |  |
| settings.custom_monitor_definitions | object | `{}` | Custom plugin monitor config files |
| settings.custom_plugin_monitors | list | `[]` |  |
| settings.extraArgs | list | `[]` |  |
| settings.heartBeatPeriod | string | `"5m0s"` | Syncing interval with API server |
| settings.log_monitors | list | `["/config/kernel-monitor.json","/config/docker-monitor.json","/config/readonly-monitor.json"]` | User-specified custom monitor definitions |
| settings.prometheus_address | string | `"0.0.0.0"` | Prometheus exporter address |
| settings.prometheus_port | int | `20257` | Prometheus exporter port |
| tolerations[0].effect | string | `"NoSchedule"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| updateStrategy | string | `"RollingUpdate"` | Manage the daemonset update strategy |
| volume.localtime.enabled | bool | `true` |  |
| volume.localtime.type | string | `"FileOrCreate"` |  |

## Custom Monitors Configuration

### Option 1: File-Based Monitors (Recommended)

This approach allows you to maintain custom monitor definitions as separate files in the `custom-monitors/` directory.

#### Step 1: Place Monitor Files

Create your monitor definition files in the `custom-monitors/` directory:

```bash
custom-monitors/
├── my-app-monitor.json
├── database-monitor.json
└── health-check.sh
```

#### Step 2: Enable and Reference Custom Monitors

In your `values.yaml`:

```yaml
customMonitors:
  enabled: true

node-problem-detector:
  settings:
    custom_plugin_monitors:
      - /config/kernel-monitor.json
      - /config/docker-monitor.json
      - /custom-config/my-app-monitor.json
      - /custom-config/database-monitor.json
```

The ConfigMap volume is automatically mounted at `/custom-config` - no manual volume configuration needed!

#### Step 3: Deploy

```bash
helm upgrade --install node-problem-detector . -f values.yaml
```

### Option 2: Inline Monitors (Subchart's Native Method)

You can also use the subchart's native `custom_monitor_definitions` (this is the original method):

```yaml
node-problem-detector:
  settings:
    custom_monitor_definitions:
      my-monitor.json: |
        {
          "plugin": "filelog",
          ...
        }
```

## File Exclusions

The following files are automatically excluded from the ConfigMap:
- `README.md`
- `.gitkeep`
- Files ending with `.example`

## Monitor Definition Examples

See `custom-monitors/example-docker-monitor.json.example` for a complete example.

## Configuration

All configuration options are documented in `values.yaml`. Key sections:

- `customMonitors.*`: File-based custom monitor configuration
- `node-problem-detector.*`: All standard NPD chart options

## Upstream Chart

This chart wraps the official Node Problem Detector chart:
- Repository: `oci://ghcr.io/deliveryhero/helm-charts`
- Chart: `node-problem-detector`
- Version: `2.4.0`

For full configuration options, see the [upstream chart documentation](https://artifacthub.io/packages/helm/deliveryhero/node-problem-detector).
