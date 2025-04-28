#!/bin/bash

set -e

# ==== CONFIG ====
OFFLINE_DIR="offline_ansible"
VENV_NAME="ansible"
DEB_ROOT="$OFFLINE_DIR/debs"
WHEEL_DIR="$OFFLINE_DIR/wheels"
REQUIREMENTS="$OFFLINE_DIR/requirements.txt"

# ==== 1. Detect Ubuntu codename ====
if ! command -v lsb_release >/dev/null; then
  echo "lsb_release not found. Installing..."
  sudo apt-get update && sudo apt-get install -y lsb-release
fi

UBUNTU_CODENAME=$(lsb_release -c -s)
if [[ "$UBUNTU_CODENAME" != "jammy" ]]; then
  echo "❌ This setup script is intended for Ubuntu 22.04 (jammy) only."
  exit 1
fi

echo "Detected Ubuntu codename: $UBUNTU_CODENAME"

DEB_DIR="$DEB_ROOT/ubuntu-$UBUNTU_CODENAME"

if [[ ! -d "$DEB_DIR" ]]; then
  echo "❌ Error: No debs found for Ubuntu codename '$UBUNTU_CODENAME' in $DEB_DIR"
  exit 1
fi

# ==== 2. Install python3-venv and python3-pip from local debs ====
echo "📦 Installing python3-venv and python3-pip from local .deb files..."
sudo dpkg -i "$DEB_DIR"/*.deb || true
sudo apt-get install -f -y  # Fix missing dependencies using local packages

# ==== 3. Create and activate venv ====
echo "🛠️  Creating Python venv: $VENV_NAME"
python3 -m venv "$VENV_NAME"
source "$VENV_NAME/bin/activate"

# ==== 4. Install Ansible from offline wheels ====
echo "🚀 Installing Ansible from offline wheels..."
pip install --upgrade pip
pip install --no-index --find-links="$WHEEL_DIR" -r "$REQUIREMENTS"

echo "✅ Ansible installed in venv '$VENV_NAME'."
ansible --version