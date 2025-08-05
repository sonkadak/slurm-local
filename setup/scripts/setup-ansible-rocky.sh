#!/bin/bash

set -e

# ==== CONFIG ====
OFFLINE_DIR="offline_ansible_rocky"
VENV_NAME="ansible"
RPM_ROOT="$OFFLINE_DIR/rpms"
WHEEL_DIR="$OFFLINE_DIR/wheels"
REQUIREMENTS="$OFFLINE_DIR/requirements.txt"

# ==== 1. Detect OS codename ====
if [ ! -f /etc/os-release ]; then
    echo "❌ /etc/os-release not found. This script requires it to detect the OS version."
    exit 1
fi
source /etc/os-release
CODENAME=$ID-$VERSION_ID

echo "ℹ️ Detected OS codename: $CODENAME"

RPM_DIR="$RPM_ROOT/$CODENAME"

if [[ ! -d "$RPM_DIR" ]]; then
  echo "❌ Error: No debs found for OS codename '$CODENAME' in $RPM_DIR"
  exit 1
fi

# ==== 2. Install rpm packages from local files ====
echo "📦 Installing rpm packages from local .rpm files..."
# Use 'localinstall' with '--disablerepo' and '--nogpgcheck' for a true air-gapped installation.
sudo dnf localinstall -y --allowerasing --disablerepo=* --nogpgcheck "$RPM_DIR"/*.rpm

# ==== 3. Verify Python 3.11 installation and create venv ====
echo "🛠️  Verifying Python 3.11 installation..."
if ! command -v python3.11 &> /dev/null; then
    echo "❌ Error: python3.11 command not found after RPM installation."
    echo "   Please check if the RPM files in '$RPM_DIR' were found and installed correctly."
    exit 1
fi

echo "🐍 Creating Python venv using python3.11: $VENV_NAME"
python3.11 -m venv "$VENV_NAME"
source "$VENV_NAME/bin/activate"

# ==== 4. Install Ansible from offline wheels ====
echo "🚀 Installing Ansible from offline wheels..."
pip install --no-index --find-links="$WHEEL_DIR" -r "$REQUIREMENTS"

echo "✅ Ansible installed in venv '$VENV_NAME'."
ansible --version
