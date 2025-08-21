#!/bin/bash
# This script downloads all necessary RPM packages for a local Slurm YUM repository on Rocky Linux.
# It downloads packages into separate directories based on their group, under an 'rpms' subdirectory.

set -e

# === 1. Configuration ===
arch=$(uname -m)
OUTPUT_DIR="offline_repo"
RPM_ROOT="$OUTPUT_DIR/rpms"

# Define package groups. Dependencies will be resolved automatically for each group.
NFS_PKGS=(
  nfs-utils
)

DEVELOPMENT_TOOLS_PKGS=(
   autoconf
   automake
   binutils
   bison
   flex
   gcc
   gcc-c++
   gdb
   glibc-devel
   libtool
   make
   pkgconf
   pkgconf-m4
   pkgconf-pkg-config
   redhat-rpm-config
   rpm-build
   rpm-sign
   strace
)
COMMON_PKGS=(
  python3.11
  python3.11-pip
  python3.11-setuptools
)

MUNGE_PKGS=(
  munge
)

PMIX_DEP_PKGS=(
  libev-devel
  libevent-devel
  zlib
  zlib-devel
  #pandoc
)

SLURM_PKGS=(
  munge-devel
  readline-devel
  mariadb-devel
  numactl-devel
  pam-devel
  http-parser-devel
  json-c-devel
  perl-ExtUtils-MakeMaker
  libatomic
  mariadb-server
  python3-PyMySQL
  mailx
  policycoreutils-python-utils
)

PYXIS_PKGS=(
  util-linux
)

ENROOT_PKGS=(
  enroot
  enroot+caps
  bash-completion
  pigz
  jq
  parallel
)

# === 2. Preparation ===
mkdir -p "$RPM_ROOT"

echo "🔧 Installing EPEL repository to make newer packages available..."
sudo dnf install -y epel-release

echo "🔄 Refreshing repository metadata..."
sudo dnf clean all
sudo dnf makecache

# === 3. Dependency Resolution and Download per Group ===
echo "🔎 Resolving and downloading packages for each group into separate directories..."

# Function to process a package group
download_group() {
  local group_name="$1"
  # Use nameref to get the array variable by its name
  declare -n packages_array="$2"
  local group_dir="$RPM_ROOT/$group_name"

  mkdir -p "$group_dir"
  echo
  echo "--- Processing group: $group_name ---"

  # Use dnf repoquery to get a complete, recursive list of dependencies.
  # local FULL_PACKAGE_LIST
  # FULL_PACKAGE_LIST=$(dnf repoquery \
  #   --requires \
  #   --resolve \
  #   --recursive \
  #   --archlist=x86_64,noarch \
  #   --setopt=install_weak_deps=false \
  #   --exclude glibc-langpack-* \
  #   "${packages_array[@]}")

  # if [ -z "$FULL_PACKAGE_LIST" ]; then
  #     echo "⚠️  Could not resolve dependencies for group '$group_name'. Skipping."
  #     return
  # fi

  echo "📦 Downloading RPMs for '$group_name' to: $group_dir"
  TMPROOT=$(mktemp -d)
  rm -rf "$TMPROOT"
  sudo rpm --root "$TMPROOT" --initdb
  # Download all resolved packages to the target directory
  local rest=()
  for pkg in "${packages_array[@]}"; do
    case "$pkg" in enroot|enroot+caps)
        sudo dnf -q download --destdir="$group_dir" "https://github.com/NVIDIA/enroot/releases/download/v3.5.0/${pkg}-3.5.0-1.el8.${arch}.rpm"
        ;;
      *)
        rest+=("$pkg")
        ;;
    esac
  done

  if ((${#rest[@]} > 0)); then
    mapfile -t rest < <(printf '%s\n' "${rest[@]}" | sed 's/\r$//' | awk 'NF' | sort -u)
    sudo dnf download \
      --disablerepo='*' --enablerepo=baseos,appstream,epel,powertools,extras \
      --setopt=install_weak_deps=false \
      --exclude=glibc-langpack-* \
      --archlist=x86_64,noarch \
      --installroot="$TMPROOT" \
      --releasever=8 \
      --resolve \
      --destdir="$group_dir" \
      "${rest[@]}"
  fi
}

# Process each group
download_group "nfs" NFS_PKGS
download_group "development" DEVELOPMENT_TOOLS_PKGS
download_group "common" COMMON_PKGS
download_group "munge" MUNGE_PKGS
download_group "pmix" PMIX_DEP_PKGS
download_group "slurm" SLURM_PKGS
download_group "pyxis" PYXIS_PKGS
download_group "enroot" ENROOT_PKGS

echo
echo "✅ All RPMs downloaded into their respective group directories under: $RPM_ROOT"