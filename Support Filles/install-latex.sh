#!/usr/bin/env bash
# Installation script for LaTeX environment (Ubuntu/Debian)
# This script installs all required packages to compile Greek LaTeX documents with XeLaTeX

set -euo pipefail

echo "================================================"
echo "Installing LaTeX packages for Greek documents"
echo "================================================"
echo ""
echo "This will install:"
echo "  - XeLaTeX (texlive-xetex)"
echo "  - LaTeX packages (texlive-latex-recommended, texlive-latex-extra)"
echo "  - Fonts (fonts-noto, fonts-dejavu-core)"
echo "  - Greek language support (texlive-lang-greek)"
echo "  - Science packages (texlive-science for siunitx)"
echo "  - latexmk (build automation tool)"
echo ""
echo "This may require sudo privileges and will take a few minutes."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Updating package lists..."
sudo apt-get update

echo ""
echo "Installing LaTeX packages..."
sudo apt-get install -y \
    latexmk \
    texlive-xetex \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-lang-greek \
    texlive-science \
    fonts-noto \
    fonts-dejavu-core

echo ""
echo "================================================"
echo "Installation complete!"
echo "================================================"
echo ""
echo "You can now compile LaTeX documents with:"
echo "  - make                (from Support Filles directory)"
echo "  - ./build.sh file.tex"
echo "  - xelatex file.tex    (directly)"
echo ""
echo "XeLaTeX version:"
xelatex --version | head -1
