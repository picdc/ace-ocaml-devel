
include Makefile.config
include Makefile.rules

SOURCES_JS= ace_utils.ml tabs.ml

OCPDIR= ocp-indent-src
OCPLIB= -I $(OCPDIR) ocp_indent.cma

# TOPLVLDIR= toplevel
# TOPLVLLIB= -I $(TOPLVLDIR) toplevel.cma

OBJS_JS= $(SOURCES_JS:.ml=.cmo)

LIBS= $(OCPLIB)

JSFLAGS = -pretty

.PHONY: depend

all: depend main.js

main.js: main.byte
	js_of_ocaml $(JSFLAGS) $<
	oclosure_req $@

main.byte: indent_js.cmo $(OBJS_JS)
	$(CAMLJS) $(LIBS) -o $@ $^ $*.ml


indent_js.cmo:
	$(MAKE) -C $(OCPDIR)
	$(CAMLJS) -c $(OCPLIB) $*.ml

$(OBJS_JS): $(SOURCES_JS)
	$(CAMLJS) -c $*.ml


clean:
	rm .depend
	rm -f *~ \#*\# *.cm[ioa] *.annot
	rm -f *.byte a.out main.js main_oclosure.js

clean-all: clean
	$(MAKE) -C $(OCPDIR) clean


depend: $(SOURCES) $(SOURCES_JS)
	$(CAMLDEP) -pp $(PP) *.mli *.ml > .depend

include .depend
