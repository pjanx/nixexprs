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
	] ++ lib.optionals full [
		gnome.gdm.dev
		glib
		pcre2
		systemd.dev
	] ++ lib.optionals (full && stdenv.isLinux) [
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

	# It's a weird mess, gdm.pc.in includes the subdirectory in includedir.
	patchPhase = ''
		sed -i 's|gdm-user-switching.h>|gdm/&|' gdm-switch-user.c
	'';

	cmakeFlags = [
		"-DSYSTEMD_UNITDIR=${placeholder "out"}/lib/systemd/system"
	];

	doCheck = true;

	meta = with pkgs.lib; {
		description = "Desktop tools";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
