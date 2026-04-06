#!/bin/bash

# This script prepares offline installation resources for Ansible on Rocky Linux
# by downloading all necessary RPM and Python Wheel packages.

set -e

# === 1. Configuration ===
# List of essential RPMs.
# dnf repoquery will find all dependencies recursively.
RPM_PACKAGES=(
  python3.11
  python3.11-pip
  sshpass
)
ANSIBLE_VER="9.8.0"
ANSIBLE_CORE_VER="2.16.9"
OUTPUT_DIR="offline_ansible_rocky"

# === 2. OS Detection and Path Definitions ===
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_VERSION_ID=$VERSION_ID
    if [ "$OS_ID" != "rocky" ]; then
        echo "⚠️  This script is intended for Rocky Linux, but the detected OS is $OS_ID."
    fi
    echo "ℹ️  Detected OS: $PRETTY_NAME"
else
    echo "❌ Cannot determine the OS version. Exiting."
    exit 1
fi

# Define output directories
OUT="$OUTPUT_DIR/rpms/rocky-$OS_VERSION_ID"
mkdir -p "$OUT"
mkdir -p "$OUTPUT_DIR/wheels"

# === 3. DNF and Repositories Preparation ===
echo "🔧 Ensuring dnf-utils is installed..."
sudo dnf install -y dnf-utils

echo "🔧 Installing EPEL repository to make newer packages available..."
sudo dnf install -y epel-release

echo "🔄 Refreshing repository metadata to ensure EPEL is recognized..."
sudo dnf clean all
sudo dnf makecache

# === 4. RPM Download ===
echo "🔎 Resolving all RPM dependencies recursively for x86_64 and noarch..."
# Use dnf repoquery to get a complete, recursive list of dependencies
# for the specified architectures. This is the most reliable way to build a complete offline set.
FULL_PACKAGE_LIST=$(dnf repoquery \
  --requires \
  --resolve \
  --recursive \
  --archlist=x86_64,noarch \
  "${RPM_PACKAGES[@]}")

if [ -z "$FULL_PACKAGE_LIST" ]; then
    echo "❌ Failed to resolve package dependencies. Exiting."
    exit 1
fi

echo "📦 Downloading the following RPMs:"
echo "$FULL_PACKAGE_LIST" | xargs -n 5

echo "📦 Starting RPM download..."
# Use the fully resolved list to download packages.
sudo dnf download --destdir="$OUT" $FULL_PACKAGE_LIST

echo "✅ RPM download complete. Packages are in: $OUT"

# === 5. Python Wheel Download ===
echo "🐍 Downloading pip wheels for ansible==$ANSIBLE_VER..."

# Temporarily install python3.11-pip on the host to run the pip download command.
if ! command -v pip3.11 &> /dev/null; then
    echo "🔧 pip3.11 not found. Installing it temporarily to download wheels..."
    sudo dnf install -y python3.11-pip
fi

pip3.11 download \
  "ansible==$ANSIBLE_VER" \
  "ansible-core==$ANSIBLE_CORE_VER" \
  -d "$OUTPUT_DIR/wheels"

# Save pip requirements for air-gapped install
cat <<EOF > "$OUTPUT_DIR/requirements.txt"
ansible==$ANSIBLE_VER
ansible-core==$ANSIBLE_CORE_VER
EOF

echo "✅ DONE! All offline packages for Rocky Linux are stored in: $OUTPUT_DIR"