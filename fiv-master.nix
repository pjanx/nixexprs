{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
, withResvg ? false
}:
pkgs.stdenv.mkDerivation rec {
	pname = "fiv";
	version = "master";

	nativeBuildInputs = with pkgs; [
		wrapGAppsHook
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
		librsvg
		libheif
	] ++ lib.optionals withResvg [
		resvg
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

		# https://gitlab.gnome.org/GNOME/glib/-/issues/30240
		ulimit -n 8192
	'';

	mesonFlags = [
		# -Dauto_features=enabled & -Dwrap_mode=nodownload & no network
		# together form a problem.
		"-Dlibjpegqs=disabled"
		"-Dlcms2fastfloat=disabled"

		"-Dtools=enabled"
	] ++ pkgs.lib.optionals (!full) [
		"-Dlcms2=disabled"
		"-Dlibraw=disabled"
		"-Dresvg=disabled"
		"-Dlibrsvg=disabled"
		"-Dxcursor=disabled"
		"-Dlibheif=disabled"
		"-Dlibtiff=disabled"
		"-Dgdk-pixbuf=disabled"
	] ++ pkgs.lib.optionals withResvg [
		"-Dresvg=enabled"
	];

	preFixup = ''
		gappsWrapperArgs+=(
			--prefix PATH : $out/bin:${pkgs.lib.makeBinPath [ pkgs.exiftool ]}
		)
	'';

	doCheck = true;

	meta = with pkgs.lib; {
		description = "Image browser and viewer";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = with licenses; [ bsd0 asl20 ];
	};
}
