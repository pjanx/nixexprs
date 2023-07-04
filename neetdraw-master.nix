{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "neetdraw";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
	];

	buildInputs = with pkgs; [
		ncurses
		libiconv
		libev

		# Termo demo-glib.c
		#glib
		#pcre2
		#util-linux
		#libselinux
		#libsepol
		#pcre
	];

	src = if local then
		builtins.path {
			path = ../${pname}/git;
			name = "${pname}";
		}
	else
		fetchGit {
			url = "https://git.janouch.name/p/${pname}.git";
			submodules = true;
			ref = "master";
		};

	doCheck = true;

	meta = with pkgs.lib; {
		description = "Terminal drawing application";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
