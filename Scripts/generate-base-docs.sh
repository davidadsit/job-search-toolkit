#!/usr/bin/env bash
# Regenerate the generic resume and cover letter PDFs in Documents/
# from the source markdown files in Inputs/.

set -euo pipefail
cd "$(dirname "$0")/.."

echo "Generating resume PDF..."
pandoc "Inputs/resume.md" \
  -f markdown+hard_line_breaks \
  -t html5 \
  --pdf-engine=weasyprint \
  --css=".claude/skills/generate-pdfs/resume.css" \
  -o "Documents/Dave Adsit - Resume 2026.pdf" \
  2>/dev/null

echo "Generating cover letter PDF..."
pandoc "Inputs/cover-letter.md" \
  -t html5 \
  --pdf-engine=weasyprint \
  --css=".claude/skills/generate-pdfs/cover-letter.css" \
  --include-before-body=".claude/skills/generate-pdfs/cover-letter-header.html" \
  -o "Documents/Dave Adsit - Cover Letter 2026.pdf" \
  2>/dev/null

echo ""
echo "Page counts:"
for pdf in "Documents/Dave Adsit - Resume 2026.pdf" "Documents/Dave Adsit - Cover Letter 2026.pdf"; do
  [[ -f "$pdf" ]] || continue
  pages=$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')
  echo "  $pdf: $pages page(s)"
  case "$pdf" in
    *Resume*)  [[ "$pages" -gt 2 ]] && echo "    WARNING: Resume exceeds 2 pages" ;;
    *Cover*)   [[ "$pages" -gt 1 ]] && echo "    WARNING: Cover letter spills to a second page" ;;
  esac
done

echo ""
echo "Done."
