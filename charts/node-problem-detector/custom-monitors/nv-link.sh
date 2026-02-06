#!/bin/bash

readonly OK=0
readonly NONOK=1
readonly UNKNOWN=2

if ! [ -x "$(which nvidia-smi)" ]; then
    echo 'Error: nvidia-smi is not ready yet. Check if GPU operator daemonset is running correctly.'
    exit $UNKNOWN
fi

nvlink_status_result=$(nvidia-smi nvlink --status)
if [ "$(echo "$nvlink_status_result" | grep -c inactive)" -eq 0 ]; then
    echo "All NVLinks are up."
    exit $OK
else
    echo "One or more NVlinks inactive:"
    exit $NONOK
fi