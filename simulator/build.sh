#!/bin/sh

ocamlbuild -r -use-ocamlfind -pkgs yojson,bigarray simulator.native

