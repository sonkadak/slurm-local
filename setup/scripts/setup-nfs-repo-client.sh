#!/bin/bash
set -e

NFS_SERVER_IP="192.168.0.176"
NFS_EXPORT_PATH="/data/slurm-local-repo/offline_repo"
LOCAL_MOUNT_PATH="/mnt/slurm-local-repo"
APT_LIST_FILE="/etc/apt/sources.list.d/slurm-local.list"

echo "📡 Mount: $NFS_SERVER_IP:$NFS_EXPORT_PATH → $LOCAL_MOUNT_PATH"
sudo mkdir -p "$LOCAL_MOUNT_PATH"
sudo mount -t nfs "$NFS_SERVER_IP:$NFS_EXPORT_PATH" "$LOCAL_MOUNT_PATH"

echo "📝 APT 소스 구성: $APT_LIST_FILE"
sudo tee "$APT_LIST_FILE" >/dev/null <<EOF
# common packages
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/common ./

# munge
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/munge ./

# openmpi
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/openmpi ./

# pmix
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/pmix ./

# slurm
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/slurm ./

# enroot
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/enroot ./

# pyxis
deb [trusted=yes] file://$LOCAL_MOUNT_PATH/pyxis ./
EOF

echo "🔄 apt update 실행 중..."
sudo apt update

echo "✅ Local apt repository setup completed"