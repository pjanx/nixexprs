{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "logdiag";
	version = "master";

	nativeBuildInputs = with pkgs; [
		wrapGAppsHook
		cmake
		pkg-config
	];

	buildInputs = with pkgs; [
		gnome.adwaita-icon-theme
		gtk3
		json-glib
		lua5_2

		# To address pkg-config warnings, all the way down.
		libthai
		pcre2
		libdatrie
		libepoxy
	] ++ lib.optionals (!stdenv.isDarwin) [
		libxkbcommon
		xorg.libXdmcp
		xorg.libXtst
	] ++ lib.optionals stdenv.isLinux [
		util-linux
		libselinux
		libsepol
		pcre
	];

	nativeCheckInputs = with pkgs; lib.optionals (!stdenv.isDarwin) [
		xvfb-run
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

	# See nixpkgs commit b1e73fa2e086f1033a33d93524ae2a1781d12b95 about icons.
	# It used to work automatically.
	preFixup = ''
		gappsWrapperArgs+=(
			--prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
		)
	'';

	doCheck = true;

	checkPhase = with pkgs; ''
		runHook preCheck
		${lib.optionalString (!stdenv.isDarwin) "xvfb-run"} \
		ctest --force-new-ctest-process
		runHook postCheck
	'';

	meta = with pkgs.lib; {
		description = "Schematic editor";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
