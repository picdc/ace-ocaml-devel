
include ../Makefile.rules

all: toplevel.cma

.ml.cmo:
	$(CAMLC)

TOPLEVEL_CMIS=toplevel.cmi
TOPLEVEL_CMOS=toplevel.cmo topmain.cmo

toplevel.cma: $(TOPLEVEL_CMOS) $(TOPLEVEL_CMIS)
	$(OCAMLC) -a -o toplevel.cma $(TOPLEVEL_CMOS)
