#!/usr/bin/env bash
set -euo pipefail

# Simple wrapper to build a .tex file with xelatex
# Usage: ./build.sh [file.tex]
# Auxiliary files will be placed in a build/ subdirectory

TEXFILE=${1:-examples/report.tex}
TEXDIR=$(dirname "$TEXFILE")
TEXBASE=$(basename "$TEXFILE" .tex)

if ! command -v xelatex >/dev/null 2>&1; then
  echo "xelatex not found. Install TeX Live and latexmk (e.g., apt install latexmk texlive-xetex)." >&2
  exit 1
fi

# Create build directory
mkdir -p "$TEXDIR/build"

echo "Building ${TEXFILE} with xelatex (output in build/)..."
cd "$TEXDIR"
xelatex -interaction=nonstopmode -synctex=1 -output-directory=build "$(basename "$TEXFILE")"

# Copy PDF to main directory for easy access
if [ -f "build/${TEXBASE}.pdf" ]; then
  cp "build/${TEXBASE}.pdf" .
  echo "Done. PDF: $TEXDIR/${TEXBASE}.pdf"
  echo "Auxiliary files in: $TEXDIR/build/"
else
  echo "Error: PDF was not generated." >&2
  exit 1
fi
