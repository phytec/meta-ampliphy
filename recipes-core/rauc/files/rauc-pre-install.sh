#!/bin/sh

set -e
trap end EXIT
end() {
    result=$?
    if [ "$result" -ne 0 ]; then
        exit $result
    fi
}

if which rauc_downgrade_barrier.sh; then
    rauc_downgrade_barrier.sh
fi
/usr/lib/rauc/rauc-handle-secrets.sh -b
