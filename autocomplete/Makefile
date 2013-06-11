include ../Makefile.config
include ../Makefile.rules


RELIB= -I ~/.opam/4.00.1/lib/re re.cma re_emacs.cma re_str.cma

INCLUDES= -I ../ ace_utils.cmo

SOURCES= completion_data.ml completion_lexer.mll

SOURCES1= $(SOURCES:.mll=.ml)
OBJS= $(SOURCES1:.ml=.cmo)

all: depend autocomplete.cmo

depend: $(SOURCES)
	$(CAMLDEP) -pp $(PP) *.mli *.ml > .depend

autocomplete.cmo: $(OBJS)
	$(CAMLFIND) $(CAMLC) -package re $^ \
	-linkpkg -o autocomplete.cma -a $*.ml

clean:
	rm -rf *.cm[iao]
	rm completion_lexer.ml


-include .depend
