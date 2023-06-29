{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "tdv";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		librsvg

		# Tests
		libxml2
		desktop-file-utils
	];

	buildInputs = with pkgs; [
		ncurses
		icu
		glib
		pango

		# To address pkg-config warnings for pango.
		libthai
		pcre2
		libdatrie
	] ++ lib.optionals full [
		gtk3

		# To address pkg-config warnings for gtk3.
		libepoxy
	] ++ lib.optionals (full && !stdenv.isDarwin) [
		libxkbcommon
		xorg.libXdmcp
		xorg.libXtst
	] ++ lib.optionals stdenv.isLinux [
		# To address pkg-config warnings for glib.
		util-linux
		libselinux
		libsepol
		pcre
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
		description = "Translation dictionary viewer";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = with licenses; [ bsd0 mit ];
	};
}
