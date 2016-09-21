all: out/slides-revealjs.html out/slides-beamer.pdf

reveal.js/.git: # To download the reveal.js dependency
	git clone https://github.com/hakimel/reveal.js/

out/slides-revealjs.html: reveal.js/.git
	@mkdir -p $(@D)
	pandoc slides.txt -t revealjs --standalone --self-contained --output out/slides-revealjs.html

out/slides-beamer.pdf:
	@mkdir -p $(@D)
	pandoc -t beamer slides.txt --output out/slides-beamer.pdf
