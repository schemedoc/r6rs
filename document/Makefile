LATEX = latex
# LATEX = pdflatex
BIBTEX = bibtex
MAKEINDEX = makeindex
SCHEME = scheme48 -a batch
MZSCHEME = mzscheme
# use the one from tex2page distro, *not* the one included with PLT Scheme
TEX2PAGE = /afs/wsi/home/sperber/build/tex2page/tex2page

report: thirdrun

COMMON_TEX_FILES = \
	commands.tex

REPORT_TEX_FILES = r6rs.tex \
	semantics-commands.tex \
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
	programs.tex \
	repository.tex \
	semantics.tex \
	struct.tex \
	terminology.tex \

LIB_TEX_FILES = r6rs-lib.tex \
	bytevector.tex \
	complib.tex \
	convio.tex \
	enum.tex \
	eval.tex \
	exc.tex \
	hashtable.tex \
	io.tex \
	iocond.tex \
	list.tex \
	control.tex \
	portio.tex \
	r5rscompat.tex \
	records.tex \
	programlib.tex \
	setcar.tex \
	syntax-case.tex \
	unicode.tex

APP_TEX_FILES = r6rs-app.tex \
	casesensitivity.tex \
	scriptappendix.tex \
	sourcerep.tex \
	librarynames.tex \
	filesystemmapping.tex

BIB_FILES = rrs.bib abbrevs.bib

%.bbl : %.aux $(BIB_FILES)
	$(BIBTEX) $*

r6rs.ind : r6rs.idx r6rs-lib.idx
	rm -f r6rs-report-lib.idx
	$(SCHEME) < frob-lib-index.scm
	$(MAKEINDEX) -s r6rs.mst -c r6rs.idx r6rs-report-lib.idx

r6rs-lib.ind : r6rs-lib.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-lib.idx

r6rs-app.ind : r6rs-app.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-app.idx

r6rs.idx r6rs.aux : $(COMMON_TEX_FILES) $(REPORT_TEX_FILES)
	$(LATEX) r6rs

ifeq "$(LATEX)" "latex"
r6rs.dvi : r6rs.bbl r6rs.ind r6-fig-grammar-parti.tex
	$(LATEX) r6rs

r6rs-lib.dvi : r6rs-lib.bbl r6rs-lib.ind
	$(LATEX) r6rs-lib

r6rs-app.dvi : r6rs-app.bbl r6rs-app.ind
	$(LATEX) r6rs-app

r6rs.pdf : r6rs.dvi
	dvipdf r6rs.dvi

r6rs-lib.pdf : r6rs-lib.dvi
	dvipdf r6rs-lib.dvi

r6rs-app.pdf : r6rs-app.dvi
	dvipdf r6rs-app.dvi
else
r6rs.pdf : r6rs.bbl r6rs.ind r6-fig-grammar-parti.tex
	$(LATEX) r6rs

r6rs-lib.pdf : r6rs-lib.bbl r6rs-lib.ind
	$(LATEX) r6rs-lib

r6rs-app.pdf : r6rs-app.bbl r6rs-app.ind
	$(LATEX) r6rs-app
endif

r6rs-lib.idx r6rs-lib.aux : $(COMMON_TEX_FILES) $(LIB_TEX_FILES)
	$(LATEX) r6rs-lib

r6rs-app.idx r6rs-app.aux : $(COMMON_TEX_FILES) $(LIB_TEX_FILES)
	$(LATEX) r6rs-app

r6-fig-grammar-parti.tex: tex-translate.ss ../model/r6rs.scm
	$(MZSCHEME) -qu tex-translate.ss

firstrun: $(COMMON_TEX_FILES) $(REPORT_TEX_FILES) $(LIB_TEX_FILES)
	$(MZSCHEME) -qu tex-translate.ss
	$(LATEX) r6rs
	$(LATEX) r6rs-lib
	$(LATEX) r6rs-app
	touch firstrun

secondrun: firstrun r6rs.bbl r6rs-lib.bbl r6rs-app.bbl
	$(SCHEME) < frob-lib-index.scm
	$(MAKEINDEX) -s r6rs.mst -c r6rs.idx r6rs-report-lib.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-lib.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-app.idx
	$(LATEX) r6rs
	$(LATEX) r6rs-lib
	$(LATEX) r6rs-app
	touch secondrun

thirdrun: secondrun
	$(SCHEME) < frob-lib-index.scm
	$(MAKEINDEX) -s r6rs.mst -c r6rs.idx r6rs-report-lib.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-lib.idx
	$(MAKEINDEX) -s r6rs.mst -c r6rs-app.idx
	$(LATEX) r6rs
	$(LATEX) r6rs-lib
	$(LATEX) r6rs-app
	touch thirdrun

html:	r6rs-html r6rs-lib-html r6rs-app-html

r6rs-html: $(REPORT_TEX_FILES) r6-fig-grammar-parti.tex
	rm -rf r6rs-html r6rs-Z-G-*
	$(TEX2PAGE) r6rs
	$(TEX2PAGE) r6rs
	$(TEX2PAGE) r6rs
	$(MAKEINDEX) -s r6rs.mst -c r6rs-html/r6rs-Z-I.idx
	$(TEX2PAGE) r6rs
	$(TEX2PAGE) r6rs

r6rs-lib-html: $(LIB_TEX_FILES)
	rm -rf r6rs-lib-html r6rs-lib-Z-G-*
	$(TEX2PAGE) r6rs-lib
	$(TEX2PAGE) r6rs-lib
	$(TEX2PAGE) r6rs-lib
	$(MAKEINDEX) -s r6rs.mst -c r6rs-lib-html/r6rs-lib-Z-I.idx
	$(TEX2PAGE) r6rs-lib
	$(TEX2PAGE) r6rs-lib

r6rs-app-html: $(APP_TEX_FILES)
	rm -rf r6rs-app-html r6rs-app-Z-G-*
	$(TEX2PAGE) r6rs-app
	$(TEX2PAGE) r6rs-app
	$(TEX2PAGE) r6rs-app

clean:
	-rm -f r6rs.idx r6rs.log r6rs.toc r6rs.aux r6rs.bbl r6rs.blg r6rs.eval4tex r6rs.ilg r6rs.ind
	-rm -f r6rs-lib.idx r6rs-lib.log r6rs-lib.toc r6rs-lib.aux r6rs-lib.bbl r6rs-lib.blg r6rs-lib.eval4tex r6rs-lib.ilg r6rs-lib.ind
	-rm -f r6rs-report-lib.idx
	-rm -f r6rs-app.idx r6rs-app.log r6rs-app.toc r6rs-app.aux r6rs-app.bbl r6rs-app.blg r6rs-app.eval4tex r6rs-app.ilg r6rs-app.ind
	-rm -f firstrun secondrun thirdrun
	-rm -rf r6rs-html r6rs-lib-html r6rs-app-html
	-rm -f r6rs-Z-G-* r6rs-lib-Z-G-* r6rs-app-Z-G-*

reallyclean: clean
	-rm -f r6rs.dvi r6rs-lib.dvi r6rs-app.dvi
	-rm -f r6rs.pdf r6rs-lib.pdf r6rs-app.pdf
	-rm -f r6-fig-*.tex semantics-index.tex
