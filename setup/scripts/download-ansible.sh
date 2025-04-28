#!/bin/bash

# This script prepares offline installation resources for Ansible
# 1. Downloads python3-venv and python3-pip deb packages for each Ubuntu version
# 2. Downloads ansible + ansible-core pip wheels
# Result:
#   offline_ansible/
#   ├── debs/ubuntu-{version}/          ← python3-venv, python3-pip .deb
#   └── wheels/                         ← ansible wheels

set -e

# === Configuration ===
UBUNTU_VERSIONS=("jammy")  # Only Ubuntu 22.04
DEB_PACKAGES=(python3.10-venv python3-pip)
ANSIBLE_VER="9.8.0"
ANSIBLE_CORE_VER="2.16.9"
OUTPUT_DIR="offline_ansible"

mkdir -p "$OUTPUT_DIR/debs"
mkdir -p "$OUTPUT_DIR/wheels"

# === Step 1: Download python3.10-venv and pip .deb files (Ubuntu 22.04 only) ===
echo "📦 Downloading .deb packages for Ubuntu 22.04..."

OUT="$OUTPUT_DIR/debs/ubuntu-jammy"
mkdir -p "$OUT"

for pkg in "${DEB_PACKAGES[@]}"; do
  echo "⬇️  Resolving and downloading $pkg with dependencies..."
  apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends "$pkg" |grep '^\w')
done

echo "📁 Moving downloaded .deb packages to $OUT"
mv ./*.deb "$OUT"/ || echo "⚠️ No .deb packages found to move."

# === Step 2: Download Ansible + core Python wheel packages ===
echo "📦 Downloading pip wheels for ansible==$ANSIBLE_VER and ansible-core==$ANSIBLE_CORE_VER..."

pip download \
  "ansible==$ANSIBLE_VER" \
  "ansible-core==$ANSIBLE_CORE_VER" \
  -d "$OUTPUT_DIR/wheels"

# Save pip requirements for air-gapped install
cat <<EOF > "$OUTPUT_DIR/requirements.txt"
ansible==$ANSIBLE_VER
ansible-core==$ANSIBLE_CORE_VER
EOF

echo "✅ DONE! Offline packages stored in: $OUTPUT_DIR"