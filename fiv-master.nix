{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "fiv";
	version = "master";

	nativeBuildInputs = with pkgs; [
		meson
		pkg-config
		ninja
		libxml2
		jq

		# Tests
		desktop-file-utils
	];

	buildInputs = with pkgs; [
		gtk3
		libwebp
		libraw

		# WIP
		libepoxy
	] ++ lib.optionals full [
		lcms2
		#resvg
		librsvg
		libheif
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

	# Up for consideration: don't rely on shebangs at all.
	patchPhase = ''
		patchShebangs .
	'';

	mesonFlags = [
		# -Dauto_features=enabled & -Dwrap_mode=nodownload & no network
		# together form a problem.
		"-Dlibjpegqs=disabled"
		"-Dlcms2fastfloat=disabled"

		"-Dtools=enabled"
		#"-Dresvg=enabled"
	] ++ pkgs.lib.optionals (!full) [
		"-Dlcms2=disabled"
		"-Dlibraw=disabled"
		"-Dresvg=disabled"
		"-Dlibrsvg=disabled"
		"-Dxcursor=disabled"
		"-Dlibheif=disabled"
		"-Dlibtiff=disabled"
		"-Dgdk-pixbuf=disabled"
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "Image browser and viewer";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = with licenses; [ bsd0 asl20 ];
	};
}
