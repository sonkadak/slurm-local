#!/bin/bash

set -e

UBUNTU_VERSIONS=("focal" "jammy" "noble")
BASE_PACKAGES=(
  nfs-kernel-server
  nfs-common
  rpcbind
  keyutils
)

for version in "${UBUNTU_VERSIONS[@]}"; do
  echo "🔽 Downloading for Ubuntu $version..."

  OUT_DIR="nfs-debs-${version}"
  mkdir -p "$OUT_DIR"

  docker run --rm -it \
    -v "$(pwd)/$OUT_DIR:/output" \
    ubuntu:$version bash -c "
      apt-get update &&
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils &&
      apt-get install -y --download-only ${BASE_PACKAGES[*]} &&
      cp /var/cache/apt/archives/*.deb /output/
    "

  echo "✅ Finished: $OUT_DIR"
done

echo "🎉 All .deb packages downloaded for: ${UBUNTU_VERSIONS[*]}"