
include Makefile.config
include Makefile.rules

SOURCES= ace_utils.ml tabs.ml

OCPDIR= ocp-indent-src
OCPLIB= -I $(OCPDIR) ocp_indent.cma

RELIB= -I ~/.opam/4.00.1/lib/re re.cma re_emacs.cma re_str.cma

#TOPLVLDIR= tryocaml/toplevel
#TOPLVLLIB= -I $(TOPLVLDIR) toplevel.cma

OBJS= $(SOURCES:.ml=.cmo)

LIBS= $(OCPLIB) $(RELIB)

JSFLAGS = -pretty -noinline

.PHONY: depend

all: depend main.js

main.js: main.byte
	js_of_ocaml $(JSFLAGS) $<


main.byte: $(OBJS) indent_js.cmo autocomplete.cmo
	$(CAMLJS) $(LIBS) -o $@ $^ $*.ml


indent_js.cmo: 
	$(MAKE) -C $(OCPDIR)
	$(CAMLJS) -c $(OCPLIB) $*.ml


autocomplete.cmo: ace_utils.cmo 
	$(CAMLJS) $(RELIB) $^ -c $*.ml

$(OBJS): $(SOURCES)
	$(CAMLJS) -c $*.ml




clean:
	rm .depend
	rm -f *~ \#*\# *.cm[ioa] *.annot
	rm -f *.byte a.out main.js

clean-all: clean
	$(MAKE) -C $(OCPDIR) clean


depend: $(SOURCES)
	$(CAMLDEP) -pp $(PP) *.mli *.ml > .depend

-include .depend
