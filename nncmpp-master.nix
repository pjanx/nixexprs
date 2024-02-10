{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "nncmpp";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config

		# Tests
		libxml2
		desktop-file-utils
	] ++ lib.optionals full [
		librsvg
	];

	buildInputs = with pkgs; [
		ncurses
		libunistring
		curl

		# Termo demo-glib.c
		#glib
		#pcre2
		#util-linux
		#libselinux
		#libsepol
		#pcre
	] ++ lib.optionals full [
		fftw
		fftwSinglePrec
		libpng
		libpulseaudio
		xorg.libXft
		xorg.libXau
		xorg.libXdmcp
		expat
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

	cmakeFlags = [
		"-DBUILD_TESTING=ON"
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "MPD client";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = with licenses; [ bsd0 mit ];
	};
}
