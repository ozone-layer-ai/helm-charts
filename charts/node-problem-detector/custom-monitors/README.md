# Custom Monitors Directory

Place your custom Node Problem Detector monitor definition files in this directory.

## Supported File Types

- **JSON files** (`.json`): Monitor configuration files
- **Shell scripts** (`.sh`): Custom plugin scripts

## Usage

1. Enable custom monitors in your `values.yaml`:
   ```yaml
   customMonitors:
     enabled: true
     path: "custom-monitors"
   ```

2. Place your monitor files in this directory:
   ```
   custom-monitors/
   ├── my-custom-monitor.json
   ├── another-monitor.json
   └── check-script.sh
   ```

3. Reference the monitors in the NPD configuration:
   ```yaml
   node-problem-detector:
     settings:
        custom_plugin_monitors:
         - /config/kernel-monitor.json
         - /custom-config/my-custom-monitor.json
   ```

## Example Monitor Definition

See the commented examples in `values.yaml` for monitor definition structure.

All files in this directory will be automatically loaded into a ConfigMap and mounted at `/custom-config` in the NPD pods.
