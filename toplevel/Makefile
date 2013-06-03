
include ../Makefile.config

ML= arith_flags.ml int_misc.ml num.ml big_int.ml topnum.ml
ML_JS= toplevel.ml
MLI= arith_flags.mli int_misc.mli num.mli big_int.mli
MLI_JS= utils.mli

CMOS=$(ML:.ml=.cmo)
CMOS_JS=$(ML_JS:.ml=.cmo)
CMIS=$(MLI:.mli=.cmi)
CMIS_JS=$(MLI_JS:.mli=.cmi)


all: toplevel.cma
 # ocamlbuild -pkgs js_of_ocaml,js_of_ocaml.syntax -pp "camlp4o ~/.opam/4.00.1/lib/js_of_ocaml/pa_js.cmo" toplevel.cma
# cp _build/toplevel.cma ../lib


.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cma

$(CMOS):
	$(CAMLC) -c $*.ml

$(CMOS_JS):
	$(CAMLJS) -c $*.ml

$(CMIS):
	$(CAMLC) -c $*.mli

$(CMIS_JS):
	$(CAMLJS) -c $*.mli


toplevel.cma: $(CMIS) $(CMIS_JS) $(CMOS) $(CMOS_JS)
	$(CAMLJS) -a -o $@ $<
	mv $@ ../$@

clean:
	rm -f *~ \#*\# *.cm[ioa] *.annot
	rm -f *.byte a.out


depend: $(SOURCES)
	$(CAMLDEP) -pp $(PP) *.mli *.ml > .depend


include .depend
