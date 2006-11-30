default: r6rs.dvi

LATEX = latex
BIBTEX = bibtex
MAKEINDEX = makeindex
PDFLATEX = pdflatex

TEX_FILES = r6rs.tex \
	arith.tex \
	base.tex \
	basic.tex \
	bytes.tex \
	commands.tex \
	complib.tex \
	convio.tex \
	derived.tex \
	enum.tex \
	eval.tex \
	example.tex \
	exc.tex \
	expansion.tex \
	first.tex \
	hashtable.tex \
	intro.tex \
	io.tex \
	iocond.tex \
	lex.tex \
	library.tex \
	list.tex \
	misclib.tex \
	numbers.tex \
	portio.tex \
	primio.tex \
	r5rscompat.tex \
	records.tex \
	repository.tex \
	scriptlib.tex \
	scripts.tex \
	sem.tex \
	setcar.tex \
	struct.tex \
	syntax-case.tex \
	terminology.tex \
	unicode.tex

BIB_FILES = rrs.bib abbrevs.bib

%.bbl : %.aux $(BIB_FILES)
	$(BIBTEX) $*

%.ind : %.idx
	$(MAKEINDEX) -c $<

r6rs.aux : $(TEX_FILES)
	$(LATEX) r6rs

r6rs.dvi : r6rs.bbl r6rs.ind
	$(LATEX) r6rs
