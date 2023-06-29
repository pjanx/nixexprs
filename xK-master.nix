{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "xK";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		perl
	];

	buildInputs = with pkgs; [
		openssl
		libffi
		ncurses
		libiconv
	] ++ lib.optionals full [
		readline
		lua5_3
	] ++ lib.optionals (!full) [
		libedit
	];

	# TODO: Try to integrate xP in the build.
	# That might need a separate package. See https://nixos.wiki/wiki/Go.
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
	] ++ pkgs.lib.optionals (!full) [
		"-DWANT_READLINE=OFF"
		"-DWANT_LIBEDIT=ON"
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "IRC daemon, bot, TUI client";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
