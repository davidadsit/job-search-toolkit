#!/usr/bin/env bash
# Push shared skills and scripts from this private repo to the public job-search-toolkit.
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

SKILLS_SRC=".claude/skills"
SKILLS_DST="$toolkit/.claude/skills"
SCRIPTS_DST="$toolkit/Scripts"

echo "Pushing to: $toolkit"
echo ""

# Shared skills only -- private skills stay in the personal repo
for skill in archive-job compact-experience-bank customize-for-job find-jobs generate-pdfs; do
  if [[ -d "$SKILLS_SRC/$skill" ]]; then
    echo "Pushing skill: $skill"
    cp -r "$SKILLS_SRC/$skill/" "$SKILLS_DST/$skill/"
  else
    echo "Warning: $skill not found in private repo, skipping."
  fi
done

# Restore toolkit's placeholder cover letter header (never push personal content)
git -C "$toolkit" checkout -- ".claude/skills/generate-pdfs/cover-letter-header.html" 2>/dev/null || true

# Shared scripts
for script in generate-base-docs.sh generate-job-docs.sh sync-skills.sh push-skills.sh fetch-rendered.mjs package.json; do
  if [[ -f "Scripts/$script" ]]; then
    echo "Pushing script: $script"
    cp "Scripts/$script" "$SCRIPTS_DST/$script"
  else
    echo "Warning: Scripts/$script not found, skipping."
  fi
done

echo ""
echo "Done. Review changes with: git -C \"$toolkit\" diff"
