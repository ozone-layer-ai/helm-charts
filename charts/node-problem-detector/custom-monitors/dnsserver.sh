#!/bin/bash

readonly OK=0
readonly NONOK=1

nslookup -timeout=1 google.com "$VPC_DNS_SERVER"
if [ $? -eq 0 ]; then
exit $OK
fi

nslookup -timeout=1 amazon.com $VPC_DNS_SERVER
if [ $? -eq 0 ]; then
exit $OK
fi

nslookup -timeout=1 apple.com $VPC_DNS_SERVER
if [ $? -eq 0 ]; then
exit $OK
fi

echo "Could not reach common external DNS endpoints"
exit $NONOK