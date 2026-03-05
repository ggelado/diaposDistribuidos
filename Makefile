diapos.pdf: ejemplo_slides.md presentation.sty my-template.tex
	pandoc ejemplo_slides.md -t beamer -o diapos.pdf --pdf-engine=lualatex --template=my-template.tex --slide-level=2

documento.docx: ejemplo_slides.md
	pandoc ejemplo_slides.md -o documento.docx