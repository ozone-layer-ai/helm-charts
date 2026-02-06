#!/bin/bash

readonly OK=0
readonly NONOK=1

if curl -s google.com | grep -q 301; then
echo "Can reach google.com"
exit $OK
else
echo "Cannot reach google.com"
# check amazon.com incase of google outage
if curl -s amazon.com | grep -q 301; then
echo "Can reach amazon.com"
exit $OK
else
echo "Cannot reach amazon.com"
if curl -s apple.com | grep -q 301; then
echo "Can reach apple.com"
exit $OK
else
echo "Cannot reach amazon.com"
fi
fi

exit $NONOK
fi