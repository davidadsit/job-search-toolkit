#!/usr/bin/env bash
# Generate resume and cover letter PDFs for a specific job application.
# Usage: generate-job-docs.sh <ApplicationFolderName>

set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${1:-}" ]]; then
  echo "Usage: generate-job-docs.sh <ApplicationFolderName>"
  echo ""
  echo "Available application folders:"
  for dir in Applications/*/; do
    [[ -d "$dir" ]] && echo "  $(basename "$dir")"
  done
  exit 1
fi

folder="Applications/$1"

if [[ ! -d "$folder" ]]; then
  echo "Error: folder '$folder' does not exist."
  echo ""
  echo "Available application folders:"
  for dir in Applications/*/; do
    [[ -d "$dir" ]] && echo "  $(basename "$dir")"
  done
  exit 1
fi

generated=0

# Resume
if [[ -f "$folder/resume.md" ]]; then
  echo "Generating resume PDF..."
  pandoc "$folder/resume.md" \
    -f markdown+hard_line_breaks \
    -t html5 \
    --pdf-engine=weasyprint \
    --css=".claude/skills/generate-pdfs/resume.css" \
    -o "$folder/Dave Adsit - Resume.pdf" \
    2>/dev/null
  generated=$((generated + 1))
else
  echo "Skipping resume: no resume.md found in $folder/"
fi

# Cover Letter
if [[ -f "$folder/cover-letter.md" ]]; then
  echo "Generating cover letter PDF..."
  pandoc "$folder/cover-letter.md" \
    -t html5 \
    --pdf-engine=weasyprint \
    --css=".claude/skills/generate-pdfs/cover-letter.css" \
    --include-before-body=".claude/skills/generate-pdfs/cover-letter-header.html" \
    -o "$folder/Dave Adsit - Cover Letter.pdf" \
    2>/dev/null
  generated=$((generated + 1))
else
  echo "Skipping cover letter: no cover-letter.md found in $folder/"
fi

if [[ "$generated" -eq 0 ]]; then
  echo ""
  echo "No PDFs generated."
  exit 1
fi

# Strip pandoc/WeasyPrint metadata to avoid ATS spam flags
python3 - "$folder" <<'PYEOF'
import sys, os
from pypdf import PdfReader, PdfWriter

folder = sys.argv[1]
files = [
    os.path.join(folder, "Dave Adsit - Resume.pdf"),
    os.path.join(folder, "Dave Adsit - Cover Letter.pdf"),
]
for path in files:
    if not os.path.exists(path):
        continue
    reader = PdfReader(path)
    writer = PdfWriter()
    for page in reader.pages:
        writer.add_page(page)
    writer.add_metadata({
        "/Creator": "",
        "/Producer": "",
        "/Author": "Dave Adsit",
        "/Title": os.path.splitext(os.path.basename(path))[0],
    })
    tmp = path + ".tmp"
    with open(tmp, "wb") as f:
        writer.write(f)
    os.replace(tmp, path)
PYEOF

echo ""
echo "Page counts:"
for pdf in "$folder/Dave Adsit - Resume.pdf" "$folder/Dave Adsit - Cover Letter.pdf"; do
  [[ -f "$pdf" ]] || continue
  pages=$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')
  echo "  $(basename "$pdf"): $pages page(s)"
  case "$pdf" in
    *Resume*)  [[ "$pages" -gt 2 ]] && echo "    WARNING: Resume exceeds 2 pages" ;;
    *Cover*)   [[ "$pages" -gt 1 ]] && echo "    WARNING: Cover letter spills to a second page" ;;
  esac
done

echo ""
echo "Done."
