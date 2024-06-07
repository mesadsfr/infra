#!/bin/bash

set -e

for name in PGHOST PGPORT PGUSER PGPASSWORD PGDATABASE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY S3_PATH;
do
    if [ -z "${!name}" ]; then
        echo "$0 requires the environment variable $name to be set"
        exit 1
    fi
done


backup_file=/var/tmp/backup-$(date -Iseconds).sql.gz

pg_dump | gzip > "$backup_file"
aws s3 cp "$backup_file" "$S3_PATH$(basename $backup_file)"