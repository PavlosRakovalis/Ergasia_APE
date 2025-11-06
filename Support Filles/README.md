# Ergasia_APE — LaTeX (Greek) workspace
This repository is prepared as a small LaTeX workspace that you can use as an alternative to Overleaf. It includes:

- An example XeLaTeX document that uses Greek (`examples/report.tex`).
- A `Makefile` and `build.sh` to compile the example with `xelatex` (via `latexmk`).
- A `Dockerfile` and `.devcontainer/devcontainer.json` so you can open the Codespace in a reproducible container with TeX Live installed.
- **Clean workspace organization**: All auxiliary files (`.aux`, `.log`, `.out`, etc.) are automatically placed in a `build/` subdirectory, keeping your main folders clean.

## Project Structure

Your workspace will stay organized like this:

```
your-project/
├── your-document.tex          # Your LaTeX source file
├── your-document.pdf          # Generated PDF (copied from build/)
├── images/                    # Your images/figures
│   └── diagram.png
├── build/                     # Hidden folder with all auxiliary files
│   ├── your-document.aux
│   ├── your-document.log
│   ├── your-document.out
│   ├── your-document.synctex.gz
│   └── ...
```

The `build/` folder is hidden in VS Code Explorer by default, so you only see your `.tex` files, images, and the final PDF!

## Quick usage (local machine)

Install the needed packages on Ubuntu (example):

```bash
sudo apt update
sudo apt install -y latexmk texlive-xetex texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-lang-greek texlive-science fonts-noto fonts-dejavu-core
```

Then build the example PDF:

```bash
make
# or
./build.sh "../Tex Filles/ PDFS/examples/report.tex"
```

The PDF will be created next to the `.tex` file (at: `../Tex Filles/ PDFS/examples/report.pdf`).

## Using the Docker container (recommended for Codespaces)

Build the image locally:

```bash
docker build -t latex-greek -f Dockerfile .
```

Run a shell in the container and build the example:

```bash
docker run --rm -it -v "$(pwd):/workspace" -w /workspace latex-greek bash
# inside container:
make
```

## Using the VS Code devcontainer / Codespace

Open the repository in Codespaces or in VS Code's "Remote - Containers" using the provided `.devcontainer/devcontainer.json`. The container uses the included `Dockerfile` and installs TeX Live with xelatex and Greek support.

The recommended VS Code extension inside the container is LaTeX Workshop (already set in the devcontainer config) which gives a good editing and build experience similar to Overleaf.

## Writing Greek in LaTeX

- This repository's example uses XeLaTeX + `polyglossia` + `fontspec`. This combo is the most straightforward for Unicode (UTF-8) Greek text and direct use of system fonts.
- If you prefer `babel` you can use `babel` with `greek` instead; for best font control use `fontspec` with XeLaTeX or LuaLaTeX.
- Example preamble in `examples/report.tex` shows `\\setdefaultlanguage{greek}` and a `\\newfontfamily` call for the Greek font.

## Notes and troubleshooting

- If the container build fails because a font package name changed in Ubuntu, adjust the package list in `Dockerfile` (common fonts with Greek glyphs: `fonts-dejavu-core`, `fonts-noto`, `fonts-lato`, `fonts-freefont-ttf`).
- If you need extra LaTeX packages, add them to the `Dockerfile` (via apt or install from CTAN) or use TeX Live manager `tlmgr` if available.

## Files added

- `examples/report.tex` — small Greek example using XeLaTeX + polyglossia
- `Makefile` — builds the example using `latexmk`
- `build.sh` — small wrapper script
- `Dockerfile` — minimal TeX Live image based on Ubuntu 24.04
- `.devcontainer/devcontainer.json` — devcontainer configuration for Codespaces/Remote-Containers

---
If you'd like I can now:

1. Attempt to install the packages directly in this Codespace and compile the example to verify everything works. (This will run apt and may require sudo.)
2. Or leave the container-only approach and let you open the repository in Codespaces which will rebuild the container automatically.

Tell me which you prefer and I'll proceed.