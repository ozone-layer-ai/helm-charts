#!/bin/bash

readonly OK=0
readonly NONOK=1
readonly UNKNOWN=2

# Ref: https://admin.pci-ids.ucw.cz/read/PC/15b3
readonly CX_PRODUCT_PREFIX=0x10
readonly BF_PRODUCT_PREFIX=0xa2

if [ $# -lt 3 ]; then
    echo "Usage: $0 <prefix> <num_transitions> <time_window_in_seconds> [fe|be]"
    exit $UNKNOWN
fi

file_prefix=$1
num_transitions=$2
time_window_in_seconds=$3
sticky_window_in_seconds=$4
interface_type=$5

readonly tmp_file_stickiness_holder="/tmp/${file_prefix}_found_error"
# error_output stores a collection of error messages to print at the end
error_output=()

check_carrier_changes() {
    local interface_name=$1
    local carrier_changes_file="/sys/class/net/$interface_name/carrier_changes"
    local tmp_file="/tmp/carrier_changes_${file_prefix}_$interface_name"

    if [ ! -f "$carrier_changes_file" ]; then
        echo "Interface $interface_name not found."
        return 1
    fi

    local current_value
    current_value=$(cat "$carrier_changes_file")
    local current_timestamp
    current_timestamp=$(date +%s)

    # Append the current entry to the temporary file
    echo "$current_timestamp $current_value" >> "$tmp_file"

    # Calculate the timestamp $time_window_in_seconds ago
    local time_window_start
    time_window_start=$(("$current_timestamp" - "$time_window_in_seconds"))

    local sticky_window_start
    sticky_window_start=$(("$current_timestamp" - "$sticky_window_in_seconds"))

    # Read the entries from the temporary file within the past hour
    local entries
    entries=$(awk -v timestamp="$time_window_start" '$1 > timestamp' "$tmp_file")

    # Extract the oldest and newest values within the past hour
    local oldest_value
    oldest_value=$(echo "$entries" | awk 'NR==1 {print $2}')
    local newest_value
    newest_value=$(echo "$entries" | awk 'END {print $2}')

    # Calculate the change in carrier_changes value within the past hour
    local value_change=$((newest_value - oldest_value))

    # Check if the value change is greater than 8
    # A value of 8 indicates 4 down/up events aka a flap
    if [ "$value_change" -gt "$num_transitions" ]; then
        echo "$interface_name flapped more than $num_transitions times in the past $time_window_in_seconds seconds."
        # mark the timestamp where we saw a breach into the stickiness holder file thing
        echo "$current_timestamp $interface_name" >> "$tmp_file_stickiness_holder"
    fi

    # Remove entries older than $time_window_in_seconds from the temporary files
    awk -v timestamp="$time_window_start" '$1 > timestamp' "$tmp_file" > "${tmp_file}.tmp"
    mv "${tmp_file}.tmp" "$tmp_file"

    awk -v timestamp="$sticky_window_start" '$1 > timestamp' "$tmp_file_stickiness_holder" > "${tmp_file_stickiness_holder}.tmp"
    mv "${tmp_file_stickiness_holder}.tmp" "$tmp_file_stickiness_holder"
}

# Array to store infiniband interfaces
infiniband_interfaces=()

# Loop through all interfaces in /sys/class/net/
for interface in /sys/class/net/*; do
    # Check if the interface is a physical infiniband interface
    if [[ -d "${interface}/device/infiniband" ]]; then
        # Extract the interface name from the path
        if_name=$(basename "$interface")

        # Extract the product id
        product_id=$(cat "${interface}/device/device")

        # Filter out FE or BE interfaces if specified
        if [[ "$interface_type" == "be" && ! "$product_id" =~ $CX_PRODUCT_PREFIX ]]; then
            continue
        elif [[ "$interface_type" == "fe" && ! "$product_id" =~ $BF_PRODUCT_PREFIX ]]; then
            continue
        fi

        # Append the interface name to the array
        infiniband_interfaces+=("$if_name")
    fi
done

# Loop through each infiniband interface and call check_carrier_changes
for network_interface_name in "${infiniband_interfaces[@]}"; do
    check_carrier_changes "$network_interface_name"
done

# Check if any NICs reported an error
current_timestamp=$(date +%s)
sticky_window_start=$(("$current_timestamp" - "$sticky_window_in_seconds"))
entries=$(awk -v timestamp="$sticky_window_start" '$1 > timestamp' "$tmp_file_stickiness_holder")

if [[ -n "$entries" ]]; then
  exit $NONOK
fi
exit $OK