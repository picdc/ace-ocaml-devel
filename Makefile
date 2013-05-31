
include Makefile.rules

OCPDIR= ocp-indent-src
OCPLIB= -I $(OCPDIR) ocp_indent.cma

LIBS= $(OCPLIB)

JSFLAGS = -pretty

all: depend main.js

indent_js.cmo:
	$(MAKE) -C $(OCPDIR)
	$(CAMLJS) -c $(OCPLIB) $*.ml

ace_utils.cmo:
	$(CAMLJS) -c $*.ml


main.byte: indent_js.cmo ace_utils.cmo
	$(CAMLJS) -o $@ $(LIBS) $^ $*.ml


main.js: main.byte
	js_of_ocaml $(JSFLAGS) $<

clean:
	rm -f *~ \#*\# *.cm[ioa] *.annot
	rm -f *.byte a.out

clean-all: clean
	$(MAKE) -C $(OCPDIR) clean


depend: $(SOURCES)
	$(CAMLDEP) -pp $(PP) *.mli *.ml > .depend


include .depend
