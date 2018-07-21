#!/bin/sh

ocamlbuild -use-ocamlfind -pkgs yojson,bigarray simulator.native

