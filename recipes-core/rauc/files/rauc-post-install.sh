#!/bin/sh

set -e
trap end EXIT
end() {
    result=$?
    if [ "$result" -ne 0 ]; then
        exit $result
    fi
}
