#!/bin/sh -e
# Test whether all projects can be downloaded and built,
# in all available configurations--Nix introspection is a bit complicated,
# so they're listed explicitly.

build() {
	echo "$(tput bold)-- Building $*$(tput sgr0)"
	nix-build --arg local ${LOCAL:-false} "$@"
	echo
}

for target in *.nix
do
	[ "$target" = default.nix ] && continue

	build "$target"
	build "$target" --arg full false
done

build pdf-simple-sign-master.nix --arg go true
build fiv-master.nix --arg withResvg true
