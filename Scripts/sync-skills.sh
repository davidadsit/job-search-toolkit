#!/usr/bin/env bash
# Pull shared skills from the public job-search-toolkit repo into this private repo.
# Path resolution order:
#   1. $1 argument (explicit path override)
#   2. JOB_SEARCH_TOOLKIT env var
#   3. .toolkit-path file at repo root (single line, absolute path)
#   4. Default: ../../code/job-search-toolkit

set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -n "${1:-}" ]]; then
  toolkit="$1"
elif [[ -n "${JOB_SEARCH_TOOLKIT:-}" ]]; then
  toolkit="$JOB_SEARCH_TOOLKIT"
elif [[ -f .toolkit-path ]]; then
  toolkit="$(head -n 1 .toolkit-path)"
else
  toolkit="../../code/job-search-toolkit"
fi

if [[ ! -d "$toolkit" ]]; then
  echo "Error: toolkit directory '$toolkit' does not exist."
  echo "Set JOB_SEARCH_TOOLKIT, create .toolkit-path, or pass path as argument."
  exit 1
fi

SKILLS_SRC="$toolkit/.claude/skills"
SKILLS_DST=".claude/skills"

echo "Pulling from: $toolkit"
echo ""

for skill in archive-job compact-experience-bank customize-for-job find-jobs generate-pdfs; do
  if [[ -d "$SKILLS_SRC/$skill" ]]; then
    echo "Syncing $skill..."
    cp -r "$SKILLS_SRC/$skill/" "$SKILLS_DST/$skill/"
  else
    echo "Warning: $skill not found in toolkit, skipping."
  fi
done

# Restore personal cover letter header (never overwrite with the public placeholder)
git checkout -- ".claude/skills/generate-pdfs/cover-letter-header.html" 2>/dev/null || true

echo ""
echo "Done. Review changes with: git diff .claude/skills/"
