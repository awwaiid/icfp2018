#!/bin/sh

rm ./*_test.native
ocamlbuild -use-ocamlfind -pkg yojson,bigarray coordinate_test.native || exit 1
ocamlbuild -use-ocamlfind -pkg yojson,bigarray matrix_test.native || exit 1
ocamlbuild -use-ocamlfind -pkg yojson,bigarray region_test.native || exit 1
ocamlbuild -use-ocamlfind -pkg yojson,bigarray state_test.native || exit 1
prove -v ./*_test.native

