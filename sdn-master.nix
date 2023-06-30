{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "sdn";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
	];

	buildInputs = with pkgs; [
		ncurses
	] ++ lib.optionals stdenv.isLinux [
		acl
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

	meta = with pkgs.lib; {
		description = "Directory navigator";
		homepage = "https://git.janouch.name/p/${pname}";
		# libacl, __STDC_ISO_10646__, crash bug in libc++
		platforms = platforms.linux;
		license = licenses.bsd0;
	};
}
