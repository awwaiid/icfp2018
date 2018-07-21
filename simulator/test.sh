#!/bin/sh

ocamlbuild -use-ocamlfind -pkg yojson,bigarray coordinate_test.native
ocamlbuild -use-ocamlfind -pkg yojson,bigarray matrix_test.native
ocamlbuild -use-ocamlfind -pkg yojson,bigarray region_test.native
ocamlbuild -use-ocamlfind -pkg yojson,bigarray state_test.native
prove -v ./*_test.native

