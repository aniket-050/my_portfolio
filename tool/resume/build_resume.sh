#!/usr/bin/env bash
# Renders tool/resume/resume.html to web/resume/Aniket_Parihar_Resume.pdf
# using headless Google Chrome.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
"$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  --print-to-pdf="$root/web/resume/Aniket_Parihar_Resume.pdf" \
  "file://$root/tool/resume/resume.html"
