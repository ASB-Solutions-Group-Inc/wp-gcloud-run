#!/usr/bin/env bash
set -eo pipefail

# Create mount directory for service
mkdir -p $MNT_DIR

export DISK_BUCKET=stateless-wordpress-gcloud-run-wp-demo
# export FIRESTORE_IP_ADDRESS=

echo "Mounting GCS Fuse."
# mount -o nolock $FILESTORE_IP_ADDRESS:/$FILE_SHARE_NAME $MNT_DIR
# gcsfuse --debug_gcs --debug_fuse $DISK_BUCKET $MNT_DIR
gcsfuse --key-file /var/www/html/service_account_conf.json -o allow_other --file-mode 777 --dir-mode 777 --foreground --implict-dirs $DISK_BUCKET $MNT_DIR
# gcsfuse -o rw,allow_other -file-mode=777 -dir-mode=777 --foreground --debug_http --debug_gcs --debug_fuse --implicit-dirs $DISK_BUCKET $MNT_DIR
echo "Mounting completed."