
CAMLP4="camlp4o ~/.opam/4.00.1/lib/js_of_ocaml/pa_js.cmo"

all: js

js: bytecode
	js_of_ocaml -pretty -noinline test_ocp.byte

bytecode:
	ocamlbuild -use-ocamlfind -pkgs js_of_ocaml,js_of_ocaml.syntax \
	 -pp $(CAMLP4) -I ocp-indent/src test_ocp.byte


clean:
	rm -f *~ \#*\#
	rm -rf _build
