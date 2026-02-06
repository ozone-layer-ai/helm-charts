#!/bin/bash

readonly OK=0
readonly NONOK=1

# error_output stores a collection of error messages to print at the end
error_output=()

check_error_stats() {
  local interface_name=$1

  # Get the current total RX and TX error count for this interface.
  local tx_errors_file="/sys/class/net/$interface_name/statistics/tx_errors"
  local rx_errors_file="/sys/class/net/$interface_name/statistics/rx_errors"

  # We keep track of changes to this value with a timestamp in a /tmp file
  local tmp_tx_file="/tmp/tx_errors_$interface_name"
  local tmp_rx_file="/tmp/rx_errors_$interface_name"

  if [ ! -f "$tx_errors_file" ] || [ ! -f "$rx_errors_file" ]; then
    echo "Interface $interface_name not found or missing error statistics."
    return $NONOK
  fi

  local current_tx_value
  current_tx_value=$(cat "$tx_errors_file")
  local current_rx_value
  current_rx_value=$(cat "$rx_errors_file")

  # Get the current time which marks the end of our window
  local current_timestamp
  current_timestamp=$(date +%s)

  # Append current time and current RX/TX error count to /tmp state file
  echo "$current_timestamp $current_tx_value" >> "$tmp_tx_file"
  echo "$current_timestamp $current_rx_value" >> "$tmp_rx_file"

  # Find the time exactly 1 hour ago
  local one_hour_ago=$((current_timestamp - 3600))

  # Read the entries from the temporary files within the past hour
  local tx_entries
  tx_entries=$(awk -v timestamp="$one_hour_ago" '$1 > timestamp' "$tmp_tx_file")
  local rx_entries
  rx_entries=$(awk -v timestamp="$one_hour_ago" '$1 > timestamp' "$tmp_rx_file")

  # Get first and last entries for RX and TX to compute error count
  local oldest_tx_value
  oldest_tx_value=$(echo "$tx_entries" | awk 'NR==1 {print $2}')
  local newest_tx_value
  newest_tx_value=$(echo "$tx_entries" | awk 'END {print $2}')
  local oldest_rx_value
  oldest_rx_value=$(echo "$rx_entries" | awk 'NR==1 {print $2}')
  local newest_rx_value
  newest_rx_value=$(echo "$rx_entries" | awk 'END {print $2}')

  # Calculate the delta in tx_errors and rx_errors values within the past hour
  local tx_value_change=$((newest_tx_value - oldest_tx_value))
  local rx_value_change=$((newest_rx_value - oldest_rx_value))

  # Check if the value change is greater than 100 for either tx_errors or rx_errors
  if [ "$tx_value_change" -gt 100 ] || [ "$rx_value_change" -gt 100 ]; then
    echo "$interface_name more than 100 errors in the past hour."
    error_output+=("$interface_name")
  fi

  # Remove entries older than 1 hour from the temporary files
  awk -v timestamp="$one_hour_ago" '$1 > timestamp' "$tmp_tx_file" > "${tmp_tx_file}.tmp"
  mv "${tmp_tx_file}.tmp" "$tmp_tx_file"
  awk -v timestamp="$one_hour_ago" '$1 > timestamp' "$tmp_rx_file" > "${tmp_rx_file}.tmp"
  mv "${tmp_rx_file}.tmp" "$tmp_rx_file"
}

infiniband_interfaces=()

for interface in /sys/class/net/*; do
  if [[ -d "${interface}/device/infiniband" ]]; then
    if_name=$(basename "$interface")
    infiniband_interfaces+=("$if_name")
  fi
done

for network_interface_name in "${infiniband_interfaces[@]}"; do
  check_error_stats "$network_interface_name"
done

# Check if any NICs reported an error
if [ "${#error_output[@]}" -gt 0 ]; then
  exit $NONOK
fi

exit $OK