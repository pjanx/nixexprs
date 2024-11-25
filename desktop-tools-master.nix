{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "desktop-tools";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
	];

	buildInputs = with pkgs; [
		xorg.libX11
		xorg.libXext
		xorg.libXdmcp
		libpulseaudio
		dbus.dev
		python3
	] ++ lib.optionals (full && stdenv.isLinux) [
		gnome.gdm.dev
		glib
		pcre2
		systemd.dev

		# To address pkg-config warnings for glib.
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

	cmakeFlags = [
		"-DSYSTEMD_UNITDIR=${placeholder "out"}/lib/systemd/system"
		"-DSETUID="
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "Desktop tools";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
