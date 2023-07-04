{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "razer-bw-te-ctl";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		help2man
	];

	buildInputs = with pkgs; [
		libusb
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
		description = "Razer BlackWidow Tournament Edition control utility";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
