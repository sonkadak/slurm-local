#!/bin/bash
set -e

#REPO_ROOT="./offline_repo"
REPO_ROOT="./offline_nfs"

find "$REPO_ROOT" -type d | while read -r dir; do
  # .deb 파일이 있는 디렉토리만 처리
  shopt -s nullglob
  debs=("$dir"/*.deb)
  if [ ${#debs[@]} -eq 0 ]; then
    continue
  fi

  echo "📦 Create index in: $dir"
  dpkg-scanpackages "$dir" /dev/null | tee "$dir/Packages" | gzip -9c > "$dir/Packages.gz"
done

echo "✅ Local APT indexes created successfully."
