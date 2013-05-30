
FLAGS_JS=-pretty -noinline

CAMLP4="camlp4o ~/.opam/4.00.1/lib/js_of_ocaml/pa_js.cmo"

all:
	ocamlbuild -use-ocamlfind -pkgs js_of_ocaml,js_of_ocaml.syntax \
	 -pp $(CAMLP4) -I ocp-indent/src main.byte
	js_of_ocaml $(FLAGS_JS) main.byte

# utils:
# 	ocamlbuild -use-ocamlfind -pkgs js_of_ocaml,js_of_ocaml.syntax \
# 	 -pp $(CAMLP4) -I ocp-indent/src utils.byte
# 	js_of_ocaml $(FLAGS_JS) utils.byte

# js: ocp-bytecode
# 	js_of_ocaml $(FLAGS_JS) test_ocp.byte

# ocp-byte:
# 	ocamlbuild -use-ocamlfind -pkgs js_of_ocaml,js_of_ocaml.syntax \
# 	 -pp $(CAMLP4) -I ocp-indent/src test_ocp.byte


clean:
	rm -f *~ \#*\# *.byte
	rm -rf _build
