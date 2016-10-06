all: out/*.html #out/slides-beamer.pdf

reveal.js/.git: # To download the reveal.js dependency
	git clone https://github.com/hakimel/reveal.js/


out/%.html: reveal.js/.git %.md
	@mkdir -p $(@D)
	pandoc $(input) -t revealjs --standalone --self-contained --slide-level=2 --output out/$(output)

out/slides-beamer.pdf: slides.txt
	@mkdir -p $(@D)
	pandoc -t beamer slides.txt --output out/slides-beamer.pdf
