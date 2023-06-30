{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "sensei-raw-ctl";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		help2man
	];

	buildInputs = with pkgs; [
		libusb
	] ++ lib.optionals full [
		gtk3

		# To address pkg-config warnings, all the way down.
		libthai
		pcre2
		libdatrie
		libepoxy
	] ++ lib.optionals (full && !stdenv.isDarwin) [
		libxkbcommon
		xorg.libXdmcp
		xorg.libXtst
	] ++ lib.optionals (full && stdenv.isLinux) [
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

	doCheck = true;

	meta = with pkgs.lib; {
		description = "SteelSeries Sensei Raw control utility";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}

