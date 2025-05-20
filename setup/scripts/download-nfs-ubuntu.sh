#!/bin/bash

# This script prepares offline installation resources for NFS Server
# Downloads nfs server and client packages for each Ubuntu version
# Result:
#   offline_nfs/
#   └── debs/ubuntu-{version}/

set -e

# === Configuration ===
UBUNTU_VERSIONS=("jammy")  # Only Ubuntu 22.04
UBUNTU_CODENAME=$(lsb_release -c |awk -F' ' '{print $2}')
DEB_PACKAGES=(nfs-common nfs-kernel-server)
OUTPUT_DIR="offline_nfs"
OUT="$OUTPUT_DIR/debs/ubuntu-${UBUNTU_CODENAME}"

# === Download ===
echo "📦 Downloading .deb packages for NFS..."

for pkg in "${DEB_PACKAGES[@]}"; do
  echo "⬇️  Resolving and downloading $pkg with dependencies..."
  mkdir -p ${OUT}/${pkg}
  apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends "$pkg" |grep '^\w')
  echo "📁 Moving downloaded .deb packages to $OUT/$pkg"
  mv ./*.deb "$OUT"/"$pkg"/ || echo "⚠️ No .deb packages found to move."
done

echo "🎉 All .deb packages downloaded for: ${UBUNTU_VERSIONS[*]}"
