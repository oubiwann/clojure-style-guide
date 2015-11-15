INFILE = README.md
OUTPUT = build
DOWNLOAD = download
OUTFILE = $(OUTPUT)/clojure-style-guide
TITLE = "The Clojure Style Guide"

HTMLFILE = $(OUTFILE).html
PDFFILE = $(OUTFILE).pdf
EPUBFILE = $(OUTFILE).epub
MOBIFILE = $(OUTFILE).mobi

all: html epub mobi pdf
clean: clean-html clean-pdf clean-epub clean-mobi

update: all
	cp $(OUTPUT)/* $(DOWNLOAD)/

$(OUTPUT):
	mkdir -p $(OUTPUT)

ubuntu-deps:
	sudo apt-get install -y libffi-dev libxslt-dev wkhtmltopdf \
	python-pip texlive-latex-recommended texlive-fonts-recommended \
	python-pisa

python-deps:
	sudo pip install grip

### HTML Targets #############################################################

# grip does not preserve the heading links, so the ToC won't work. It is,
# however, one of the prettiest renderings.
html-grip: $(OUTPUT) clean-html
	make $(HTMLFILE)
	grip \
	--gfm README.md \
	--context=https://github.com/oubiwann/clojure-style-guide.git \
	--wide --title $(TITLE) --export $(HTMLFILE)

html: $(OUTPUT) clean-html
	pandoc -f markdown_github -t html \
	-c https://assets-cdn.github.com/assets/github-6670887f84dea33391b25bf5af0455816ab82a9bec8f4f5e4d8160d53b08c0f3.css \
	-c https://assets-cdn.github.com/assets/github2-53964e9b93636aa437196c028e3b15febd3c6d5a52d4e8368a9c2894932d294e.css \
	-T $(TITLE) \
	-o $(HTMLFILE) $(INFILE)

$(HTMLFILE):
	touch $(HTMLFILE)

clean-html: $(HTMLFILE)
	rm $(HTMLFILE)

### PDF Targets ##############################################################

pdf: html-grip
	wkhtmltopdf \
	--title $(TITLE) \
	$(HTMLFILE) $(PDFFILE)

clean-pdf:
	rm -f $(PDFFILE)

### EPUB Targets #############################################################

epub: $(OUTPUT)
	pandoc -f markdown_github -t epub -o $(EPUBFILE) $(INFILE)

clean-epub:
	rm -rf $(EPUBFILE)

### MOBI Targets #############################################################

mobi: html
	kindlegen $(HTMLFILE) || \
	echo "In order to generate a .mobi file, you'll need kindlegen: http://www.amazon.com/gp/feature.html?docId=1000765211."

clean-mobi:
	rm -rf $(MOBIFILE)

