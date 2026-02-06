#!/bin/bash

readonly OK=0
readonly NONOK=1
readonly UNKNOWN=2
readonly node_ip_counter=100
readonly threshold_percent=0.75

sleep $((RANDOM % 30))

# Find EndpointSlice with node-problem-detector in the name
endpointslice_name=$(kubectl get endpointslices -n monitoring -o jsonpath='{.items[?(@.metadata.name contains "node-problem-detector")].metadata.name}' | awk '{print $1}')

if [ -z "$endpointslice_name" ]; then
echo "error finding node-problem-detector EndpointSlice"
exit $NONOK
fi

# Get IPs from the EndpointSlice
endpoints_output=$(kubectl get endpointslices "$endpointslice_name" -n monitoring -o jsonpath='{.endpoints[*].addresses[0]}')

if [ -z "$endpoints_output" ]; then
echo "error getting node IPs to check connectivity"
exit $NONOK
fi

endpoints_count=$(echo "$endpoints_output" | wc -w)

if [ "$endpoints_count" -lt 2 ]; then
echo "Not enough nodes to check node to node connectivity"
exit $UNKNOWN
fi

count_connected=0
count_not_connected=0

# Convert endpoints_output to an array safely
IFS=' ' read -r -a node_ip_array <<< "$endpoints_output"
random_node_ip_indexes=$(shuf --input-range=0-$(( ${#node_ip_array[@]} - 1 )) -n $node_ip_counter)

for index in $random_node_ip_indexes; do
node_ip="${node_ip_array[index]}"
if [ "$node_ip" == "$HOST_IP" ]; then
continue
fi
if ping "$node_ip" -W 1 -c 1 >/dev/null 2>&1; then
count_connected=$((count_connected + 1))
else
echo "Failed to ping $node_ip" >> /tmp/nodes-connectivity-results.txt
count_not_connected=$((count_not_connected + 1))
fi
done

endpoints_threshold=$(echo "$endpoints_count * $threshold_percent" | bc)
if (( $(echo "$count_not_connected >= $endpoints_threshold" | bc -l) )); then
echo "Node cannot ping >= 75% other nodes in cluster, unable to ping $count_not_connected nodes"
exit $NONOK
fi
exit $OK