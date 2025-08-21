#!/bin/bash
set -e

echo "--- Building Local RPM Repository from downloaded packages ---"
echo "    (Run this on the AIR-GAPPED repository server)"

# --- Part 1: Prerequisite Check ---

if ! command -v createrepo_c &> /dev/null; then
    echo "❌ Error: 'createrepo_c' command is required."
    echo "   Please ensure 'createrepo_c' is installed on this air-gapped machine."
    exit 1
fi

# --- Part 2: Repository Indexing ---

REPO_ROOT="offline_repo"

if [ ! -d "$REPO_ROOT" ]; then
    echo "❌ Error: Repository root directory '$REPO_ROOT' not found."
    echo "   Please ensure you have copied the downloaded packages into this directory."
    exit 1
fi

echo "--- Starting Repository Indexing Phase ---"

find "$REPO_ROOT" -type d -mindepth 1 | while read -r dir; do
  # .rpm 파일이 있는 디렉토리만 처리
  if [ -z "$(find "$dir" -maxdepth 1 -type f -name '*.rpm' 2>/dev/null)" ]; then
    continue
  fi

  echo "📦 Creating repository index in: $dir"
  createrepo_c "$dir"
done

echo
echo "✅✅✅ Local RPM repository built successfully in '$REPO_ROOT/'"
echo "➡️ You can now configure your clients to use this local repository."
