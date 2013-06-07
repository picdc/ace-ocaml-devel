
include Makefile.config
include Makefile.rules

SOURCES= ace_utils.ml tabs.ml autocomplete.ml

OCPDIR= ocp-indent-src
OCPLIB= -I $(OCPDIR) ocp_indent.cma

#TOPLVLDIR= tryocaml/toplevel
#TOPLVLLIB= -I $(TOPLVLDIR) toplevel.cma

OBJS= $(SOURCES:.ml=.cmo)

LIBS= $(OCPLIB) 

JSFLAGS = -pretty -noinline

.PHONY: depend

all: depend main.js

main.js: main.byte
	js_of_ocaml $(JSFLAGS) $<


main.byte: indent_js.cmo $(OBJS)
	$(CAMLJS) $(LIBS) -o $@ $^ $*.ml


indent_js.cmo:
	$(MAKE) -C $(OCPDIR)
	$(CAMLJS) -c $(OCPLIB) $*.ml

$(OBJS): $(SOURCES)
	$(CAMLJS) -c $*.ml

autocomplete: autocomplete.cmo
	$(CAMLJS) -c $@.ml

clean:
	rm .depend
	rm -f *~ \#*\# *.cm[ioa] *.annot
	rm -f *.byte a.out main.js

clean-all: clean
	$(MAKE) -C $(OCPDIR) clean


depend: $(SOURCES)
	$(CAMLDEP) -pp $(PP) *.mli *.ml > .depend

-include .depend
