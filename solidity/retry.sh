#!/bin/bash

function fail {
    echo $1 >&2
    exit 1
}

n=1
max=5
delay=2
while true; do
"$@" && break || {
    if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
    else
        fail "The command has failed after $n attempts."
    fi
}
done