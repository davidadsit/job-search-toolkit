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

# Resume -- matches any file ending in "- Resume - *.md"
resume_md=("$folder"/*\ -\ Resume\ -\ *.md)
if [[ -f "${resume_md[0]}" ]]; then
  resume_name="${resume_md[0]}"
  resume_pdf="${resume_name/- Resume - *.md/- Resume.pdf}"
  resume_pdf="$folder/$(basename "${resume_md[0]%- Resume - *.md}")- Resume.pdf"
  # Derive output PDF name from input markdown name
  base=$(basename "${resume_md[0]}" | sed 's/ - Resume - .*//')
  resume_pdf="$folder/$base - Resume.pdf"
  echo "Generating resume PDF..."
  pandoc "${resume_md[0]}" \
    -f markdown+hard_line_breaks \
    -t html5 \
    --pdf-engine=weasyprint \
    --css=".claude/skills/generate-pdfs/resume.css" \
    -o "$resume_pdf" \
    2>/dev/null
  generated=$((generated + 1))
else
  echo "Skipping resume: no '* - Resume - *.md' file found in $folder/"
fi

# Cover Letter -- matches any file ending in "- Cover Letter - *.md"
cover_md=("$folder"/*\ -\ Cover\ Letter\ -\ *.md)
if [[ -f "${cover_md[0]}" ]]; then
  base=$(basename "${cover_md[0]}" | sed 's/ - Cover Letter - .*//')
  cover_pdf="$folder/$base - Cover Letter.pdf"
  echo "Generating cover letter PDF..."
  pandoc "${cover_md[0]}" \
    -t html5 \
    --pdf-engine=weasyprint \
    --css=".claude/skills/generate-pdfs/cover-letter.css" \
    --include-before-body=".claude/skills/generate-pdfs/cover-letter-header.html" \
    -o "$cover_pdf" \
    2>/dev/null
  generated=$((generated + 1))
else
  echo "Skipping cover letter: no '* - Cover Letter - *.md' file found in $folder/"
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
for fname in os.listdir(folder):
    if not fname.endswith(".pdf"):
        continue
    path = os.path.join(folder, fname)
    reader = PdfReader(path)
    writer = PdfWriter()
    for page in reader.pages:
        writer.add_page(page)
    applicant_name = fname.split(" - ")[0]
    writer.add_metadata({
        "/Creator": "",
        "/Producer": "",
        "/Author": applicant_name,
        "/Title": os.path.splitext(fname)[0],
    })
    tmp = path + ".tmp"
    with open(tmp, "wb") as f:
        writer.write(f)
    os.replace(tmp, path)
PYEOF

echo ""
echo "Page counts:"
for pdf in "$folder"/*.pdf; do
  [[ -f "$pdf" ]] || continue
  pages="(null)"
  for _ in 1 2 3; do
    pages=$(mdls -name kMDItemNumberOfPages -raw "$pdf")
    [[ "$pages" != "(null)" ]] && break
    sleep 1
  done
  echo "  $(basename "$pdf"): $pages page(s)"
  if [[ "$pages" != "(null)" ]]; then
    case "$pdf" in
      *Resume*)  [[ "$pages" -gt 2 ]] && echo "    WARNING: Resume exceeds 2 pages" ;;
      *Cover*)   [[ "$pages" -gt 1 ]] && echo "    WARNING: Cover letter spills to a second page" ;;
    esac
  fi
done

echo ""
echo "Done."
