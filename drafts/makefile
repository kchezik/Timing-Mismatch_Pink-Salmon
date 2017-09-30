all: ms

outline:
	pandoc -H style.sty -V fontsize=11pt -V geometry:margin=1in ./outline/outline.md -o ./outline/outline.pdf

ms:
	pandoc -H style.sty -V fontsize=11pt -V geometry:margin=1in --bibliography=/Users/kylechezik/Documents/Reference_Literature/bibRef.bib --csl=ecology.csl  ms.md -o ms.pdf

ms_docx:
	pandoc -H style.sty -V fontsize=11pt -V geometry:margin=1in --bibliography=/Users/kylechezik/Documents/Reference_Literature/bibRef.bib --csl=ecology.csl  ms.md -o ms.docx

