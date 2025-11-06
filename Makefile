LATEXMK = latexmk -xelatex -pdf -interaction=nonstopmode -synctex=1
TEX = examples/report.tex
PDF = examples/report.pdf

.PHONY: all clean

all: $(PDF)

$(PDF): $(TEX)
	$(LATEXMK) $(TEX)

clean:
	latexmk -C -xelatex $(TEX)
