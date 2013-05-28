
CAMLP4="camlp4o ~/.opam/4.00.1/lib/js_of_ocaml/pa_js.cmo"

all: indent-js

indent-js:
	ocamlbuild -use-ocamlfind -pkgs js_of_ocaml,js_of_ocaml.syntax \
	 -pp $(CAMLP4) -I ocp-indent/src test_ocp.byte
	js_of_ocaml test_ocp.byte


clean:
	rm -f *~ \#*\#
	rm -rf _build