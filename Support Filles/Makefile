LATEXMK = latexmk -pdfxe -shell-escape -interaction=nonstopmode -synctex=1 -output-directory=build
TEX = ../Tex\ Filles/\ PDFS/examples/report.tex
PDF = ../Tex\ Filles/\ PDFS/examples/report.pdf

.PHONY: all clean

all: $(PDF)

$(PDF): $(TEX)
	cd "../Tex Filles/ PDFS/examples" && latexmk -pdfxe -shell-escape -interaction=nonstopmode -synctex=1 -output-directory=build report.tex && cp build/report.pdf .

clean:
	cd "../Tex Filles/ PDFS/examples" && latexmk -C -pdfxe report.tex
