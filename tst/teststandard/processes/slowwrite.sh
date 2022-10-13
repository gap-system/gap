#!/usr/bin/env sh

# We use printf here to allow the arguments to contain '\n'
# so we can explicitly control where newlines appear.
printf "$2"
sleep 1
printf "$3"
