#!/bin/bash
set -e

# 다운로드 경로 (Ansible 변수에 맞춰 설정)
DOWNLOAD_DIR="./source-packages"
mkdir -p "$DOWNLOAD_DIR"

# 버전 정보
hwloc_minor_version="2.5"
hwloc_version="${hwloc_minor_version}.0"
pmix_version="3.2.3"
openmpi_minor_version="4.0"
openmpi_version="${openmpi_minor_version}.3"
slurm_version="23.02.4"
pyxis_version="0.11.1"
enroot_version="3.5.0"

# 다운로드 URL 목록
URLS=(
  "https://download.open-mpi.org/release/hwloc/v${hwloc_minor_version}/hwloc-${hwloc_version}.tar.gz"
  "https://github.com/openpmix/openpmix/releases/download/v${pmix_version}/pmix-${pmix_version}.tar.bz2"
  "https://download.open-mpi.org/release/open-mpi/v${openmpi_minor_version}/openmpi-${openmpi_version}.tar.bz2"
  "https://download.schedmd.com/slurm/slurm-${slurm_version}.tar.bz2"
  "https://github.com/NVIDIA/pyxis/archive/v${pyxis_version}.tar.gz"
)

# 다운로드 실행
echo "📥 Downloading source packages to: $DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

for url in "${URLS[@]}"; do
  echo "⬇️  Fetching: $url"
  curl -fLO "$url"
done

echo "✅ All source packages downloaded successfully."