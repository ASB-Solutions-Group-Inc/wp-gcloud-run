#!/usr/bin/env bash
set -eo pipefail

# Create mount directory for service
mkdir -p $MNT_DIR

export DISK_BUCKET=stateless-wordpress-gcloud-run-wp-demo

echo "Mounting GCS Fuse."
# gcsfuse --debug_gcs --debug_fuse $BUCKET $MNT_DIR
gcsfuse -o rw,allow_other -file-mode=777 -dir-mode=777 --foreground --debug_http --debug_gcs --debug_fuse --implicit-dirs $DISK_BUCKET $MNT_DIR
echo "Mounting completed."