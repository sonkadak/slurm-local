#!/bin/bash

set -e

arch=$(dpkg --print-architecture)
OUT="offline_repo"
mkdir -p "$OUT"

# 패키지 그룹 정의
NFS_PKGS=(
  nfs-common
  nfs-kernel-server
)

COMMON_PKGS=(
  build-essential
  python3
  python3-dev
  python3-pip
  git
  wget
  curl
)

MUNGE_PKGS=(munge)

PMIX_DEP_PKGS=(
  libev-dev
  libevent-dev
  zlib1g
  zlib1g-dev
  pandoc
)

SLURM_DEP_PKGS=(
  libmunge-dev
  libmariadb-dev
  libmariadb-dev-compat
  libpam0g-dev
  libdbus-1-dev
  ruby-dev
  mariadb-server
  python3-pymysql
  mailutils
  policykit-1
  numactl
)

OPENMPI_DEP_PKGS=(
  build-essential
  libnuma-dev
)

PYXIS_DEP_PKGS=(bsdmainutils)

ENROOT_DEP_PKGS=(
  bash-completion
  pigz
  enroot
  enroot+caps
  jq
  parallel
)

download_group() {
  local group_name="$1"
  shift
  local DEB_PACKAGES=("$@")
  local GROUP_OUT="$OUT/$group_name"

  mkdir -p "$GROUP_OUT"

  for pkg in "${DEB_PACKAGES[@]}"; do
    echo "⬇️  Resolving and downloading $pkg with dependencies..."
    # resolve deps and download
    if [[ "$pkg" == "enroot" || "$pkg" == "enroot+caps" ]]; then
    curl -fSsL -O "https://github.com/NVIDIA/enroot/releases/download/v3.5.0/${pkg}_3.5.0-1_${arch}.deb"
    else
      apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends "$pkg" | grep '^\w') || echo "⚠️ Failed to download some deps for $pkg"
    fi
    echo "📁 Moving downloaded .deb packages to $GROUP_OUT"
    mv ./*.deb "$GROUP_OUT" || echo "⚠️ No .deb packages found to move."
  done
}

# 실행
download_group nfs "${NFS_PKGS[@]}"
download_group common "${COMMON_PKGS[@]}"
download_group munge "${MUNGE_PKGS[@]}"
download_group enroot "${ENROOT_DEP_PKGS[@]}"
download_group pmix "${PMIX_DEP_PKGS[@]}"
download_group slurm "${SLURM_DEP_PKGS[@]}"
download_group openmpi "${OPENMPI_DEP_PKGS[@]}"
download_group pyxis "${PYXIS_DEP_PKGS[@]}"

echo "✅ Download complete: $OUT/"