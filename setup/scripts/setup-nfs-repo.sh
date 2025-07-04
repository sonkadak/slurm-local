#!/bin/bash
set -e

REPO_ROOT=(offline_nfs offline_repo)

for target in "${REPO_ROOT[@]}"; do
  find "$target" -type d | while read -r dir; do
    # .deb 파일이 있는 디렉토리만 처리
    shopt -s nullglob
    debs=("$dir"/*.deb)
    if [ ${#debs[@]} -eq 0 ]; then
      continue
    fi

    echo "📦 Create index in: $dir"
    (
      cd "$dir"
      dpkg-scanpackages . /dev/null | tee "Packages" | gzip -9c > "Packages.gz"
    )
  done
done

echo "✅ Local APT indexes created successfully."
