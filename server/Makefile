
CAMLFLAGS= -thread -w @a -unsafe
CAMLOPTFLAGS= $(OCAMLFLAGS) -inline 10000
CAMLLIBS= unix.cma
PKGS= -package threads,pcre,netplex,netcgi2,nethttpd,shell

SRC= main.ml
OBJ= $(SRC:.ml=.cmx)

EXEC= server

.SUFFIXES:
.SUFFIXES: .ml .mli .cmi .cmo .cmx

all: $(EXEC)


server: $(OBJ)
	ocamlfind ocamlopt $(CAMLOPTFLAGS) $(PKGS) -linkpkg $< -o $@

.mli.cmi:
	ocamlfind ocamlc $(CAMLFLAGS) $(PKGS) -c $<

.ml.cmo:
	ocamlfind ocamlc $(CAMLFLAGS) $(PKGS) -c $<

.ml.cmx:
	ocamlfind ocamlopt $(CAMLOPTFLAGS) $(PKGS) -c $<

clean:
	rm -rf *.cmi *.cmo *~ \#*\#
	rm -rf $(EXEC)

depend:
	$(OCAMLDEP) -one-line $(OCAMLLIBS) *.ml *.mli > depend

include depend

.PHONY: clean all