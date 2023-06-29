{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "ponymap";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		help2man
	];

	buildInputs = with pkgs; [
		openssl
		ncurses
		libiconv
		jansson
	] ++ lib.optionals full [
		lua5_3
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
		description = "Experimental network scanner";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = with licenses; [ bsd0 mit ];
	};
}
