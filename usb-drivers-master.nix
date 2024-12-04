{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "usb-drivers";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		help2man
	] ++ lib.optionals stdenv.isDarwin [
		librsvg
	];

	buildInputs = with pkgs; [
		libusb1
		hidapi
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
		"-DSETUID="
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "User space USB drivers";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
