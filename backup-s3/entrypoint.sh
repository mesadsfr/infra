#!/bin/bash

set -e

for name in \
    SCW_ACCESS_KEY_ID \
    SCW_SECRET_ACCESS_KEY \
    CC_ACCESS_KEY_ID \
    CC_SECRET_ACCESS_KEY;
do
    if [ -z "${!name}" ]; then
        echo "$0 requires the environment variable $name to be set"
        exit 1
    fi
done

envsubst < /root/.config/rclone/rclone.conf.tpl > /root/.config/rclone/rclone.conf

exec "$@"