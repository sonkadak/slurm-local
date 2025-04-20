#!/bin/bash

# Set repository paths
REPO_PATH="/data/apt-nfs-repo"
POOL_PATH="${REPO_PATH}/pool/main"
DISTS_PATH="${REPO_PATH}/dists/slurm-local"

# Create temporary download directory
TEMP_DIR="/tmp/nfs-pkg-download"
rm -rf ${TEMP_DIR}
mkdir -p ${TEMP_DIR}
cd ${TEMP_DIR}

# List of NFS packages to download
PACKAGES=(
    # NFS Server packages
    nfs-kernel-server
    nfs-common
    rpcbind
    keyutils

    # NFS Client packages
    nfs-common
    rpcbind
    keyutils

    # Additional required packages
    apt-transport-https
    ca-certificates
)

echo "Downloading NFS packages and their dependencies..."
apt-get update

# Create package list file
PKG_LIST_FILE="${TEMP_DIR}/pkg-list.txt"
touch ${PKG_LIST_FILE}

# Generate list of packages to download
for pkg in "${PACKAGES[@]}"; do
    echo "Processing $pkg..."
    apt-cache depends --recurse --no-recommends --no-suggests \
        --no-conflicts --no-breaks --no-replaces --no-enhances \
        $pkg | grep "^\w" | sort -u >> ${PKG_LIST_FILE}
done

# Remove duplicates and download packages
sort -u ${PKG_LIST_FILE} > ${PKG_LIST_FILE}.tmp
mv ${PKG_LIST_FILE}.tmp ${PKG_LIST_FILE}

# Download packages
while read pkg; do
    echo "Downloading $pkg..."
    apt-get download $pkg
done < ${PKG_LIST_FILE}

# Create repository structure
mkdir -p ${POOL_PATH}
mkdir -p ${DISTS_PATH}/main/binary-amd64

# Move packages to repository
mv ${TEMP_DIR}/*.deb ${POOL_PATH}/

# Generate repository metadata
cd ${REPO_PATH}

# Create Packages files
dpkg-scanpackages pool/main > ${DISTS_PATH}/main/binary-amd64/Packages
gzip -k ${DISTS_PATH}/main/binary-amd64/Packages

# Create Release file
cat > ${DISTS_PATH}/Release << EOF
Origin: Slurm Local Repository
Label: Slurm-Local
Suite: slurm-local
Codename: slurm-local
Version: 1.0
Architectures: amd64
Components: main
Description: Local repository for Slurm packages
Date: $(date -u)
EOF

# Clean up
rm -rf ${TEMP_DIR}

echo "NFS packages downloaded and repository updated!" 