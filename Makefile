diapos.pdf: ejemplo_slides.md presentation.sty my-template.tex
	pandoc ejemplo_slides.md -t beamer -o diapos.pdf --pdf-engine=lualatex --template=my-template.tex --slide-level=2