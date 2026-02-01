# Node Problem Detector Wrapper Chart

A wrapper chart for the [Node Problem Detector](https://artifacthub.io/packages/helm/deliveryhero/node-problem-detector) that provides additional functionality for managing custom monitors.

## Features

- **File-based Custom Monitors**: Maintain custom monitor definitions as separate files instead of inline YAML
- Wraps the official Node Problem Detector Helm chart
- Supports both JSON monitor definitions and shell scripts

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
