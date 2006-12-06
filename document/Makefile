default: r6rs.dvi

LATEX = latex
BIBTEX = bibtex
MAKEINDEX = makeindex
PDFLATEX = pdflatex
SCHEME = scheme48 -a batch

report: r6rs.dvi

libraries: r6rs-lib.dvi

all: report libraries

COMMON_TEX_FILES = \
	commands.tex \
	authors.tex

REPORT_TEX_FILES = r6rs.tex \
	arith.tex \
	base.tex \
	basic.tex \
	derived.tex \
	example.tex \
	expansion.tex \
	intro.tex \
	lex.tex \
	library.tex \
	numbers.tex \
	repository.tex \
	scripts.tex \
	sem.tex \
	struct.tex \
	terminology.tex \

LIB_TEX_FILES = r6rs-lib.tex \
	bytes.tex \
	complib.tex \
	convio.tex \
	enum.tex \
	eval.tex \
	exc.tex \
	hashtable.tex \
	io.tex \
	iocond.tex \
	libderived.tex \
	list.tex \
	misclib.tex \
	portio.tex \
	primio.tex \
	r5rscompat.tex \
	records.tex \
	scriptlib.tex \
	setcar.tex \
	syntax-case.tex \
	unicode.tex

BIB_FILES = rrs.bib abbrevs.bib

%.bbl : %.aux $(BIB_FILES)
	$(BIBTEX) $*

r6rs.ind : r6rs.idx r6rs-lib.idx
	rm -f r6rs-report-lib.idx
	$(SCHEME) < frob-lib-index.scm
	$(MAKEINDEX) -s r6rs.mst -c r6rs.idx r6rs-report-lib.idx

r6rs-lib.ind : r6rs-lib.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-lib.idx

r6rs.aux : $(COMMON_TEX_FILES) $(REPORT_TEX_FILES)
	$(LATEX) r6rs

r6rs.dvi : r6rs.bbl r6rs.ind
	$(LATEX) r6rs

r6rs-lib.aux : $(COMMON_TEX_FILES) $(LIB_TEX_FILES)
	$(LATEX) r6rs-lib

r6rs-lib.dvi : r6rs-lib.bbl r6rs-lib.ind
	$(LATEX) r6rs-lib

