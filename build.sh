#!/usr/bin/env bash
set -euo pipefail

# Simple wrapper to build a .tex file with latexmk + xelatex
# Usage: ./build.sh [file.tex]

TEXFILE=${1:-examples/report.tex}

if ! command -v latexmk >/dev/null 2>&1; then
  echo "latexmk not found. Install TeX Live and latexmk (e.g., apt install latexmk texlive-xetex)." >&2
  exit 1
fi

echo "Building ${TEXFILE} with latexmk (xelatex)..."
latexmk -xelatex -pdf -interaction=nonstopmode -synctex=1 "${TEXFILE}"

echo "Done. Output in same directory as the .tex file."
