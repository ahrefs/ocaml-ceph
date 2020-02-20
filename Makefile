.SUFFIXES:
.PHONY: build clean

build:
	dune build @all

clean:
	dune clean
