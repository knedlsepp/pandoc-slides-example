all: #out/*.html #out/slides-beamer.pdf
	pandoc presentations/Seamless-precipitation-analysis.md -t revealjs --standalone --self-contained --slide-level=2 --section-divs --output out/Seamless-precipitation-analysis.html --variable theme="serif"
 


reveal.js/.git: # To download the reveal.js dependency
	git clone https://github.com/hakimel/reveal.js/


out/%.html: reveal.js/.git presentations/%.md
	@mkdir -p $(@D)
	pandoc $(input) -t revealjs --standalone --self-contained --slide-level=2 --section-divs --output out/$(output) --variable theme="beige"

out/slides-beamer.pdf: slides.txt
	@mkdir -p $(@D)
	pandoc -t beamer slides.txt --output out/slides-beamer.pdf
