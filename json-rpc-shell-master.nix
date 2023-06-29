{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "json-rpc-shell";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
	];

	buildInputs = with pkgs; [
		openssl
		ncurses
		libiconv
		jansson
		curl
		libev
	] ++ lib.optionals full [
		readline
	] ++ lib.optionals (!full) [
		libedit
	];

	propagatedBuildInputs = with pkgs; [
		perl
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

	cmakeFlags = pkgs.lib.optionals (!full) [
		"-DWANT_READLINE=OFF"
		"-DWANT_LIBEDIT=ON"
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "A shell for JSON-RPC 2.0";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = with licenses; [ bsd0 mit ];
	};
}
