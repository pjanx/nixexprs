{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	_pname = "xK";
	pname = pkgs.lib.strings.toLower _pname;
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config
		perl
	] ++ lib.optionals full [
		makeWrapper
	];

	buildInputs = with pkgs; [
		openssl
		libffi
		ncurses
		libiconv
	] ++ lib.optionals full [
		readline
		lua5_3

		# xB plugins
		guile
		tcl
		perl
		ruby
		python3
	] ++ lib.optionals (full && !tinycc.meta.broken) [
		tinycc
	] ++ lib.optionals (!full) [
		libedit
	];

	src = if local then
		builtins.path {
			path = ../${_pname}/git;
			name = "${_pname}";
		}
	else
		fetchGit {
			url = "https://git.janouch.name/p/${_pname}.git";
			submodules = true;
			ref = "master";
		};

	cmakeFlags = [
		"-DBUILD_TESTING=ON"
	] ++ pkgs.lib.optionals (!full) [
		"-DWANT_READLINE=OFF"
		"-DWANT_LIBEDIT=ON"
	];

	xP = pkgs.buildGoModule rec {
		_pname = "xP";
		pname = pkgs.lib.strings.toLower _pname;
		inherit version src doCheck meta;

		modRoot = "./${_pname}/";
#		vendorHash = pkgs.lib.fakeHash;
		vendorHash = "sha256-TK3rivjzYZwG8bfia22iQO5ZKnBzeIidsHNl6jnQUio=";

		mithril = pkgs.fetchurl {
			url = "https://unpkg.com/mithril@2.2.3/mithril.js";
			sha256 = "sha256-136Ow56fShnPfIrUvyjg4oR7tHXyGUkdzThYm+940AY=";
		};

		# This invokes a premature build that may miss compiler flags.
		preBuild = ''
			cp ${mithril} public/mithril.js
			make
		'';

		installPhase = ''
			runHook preInstall

			mkdir -p $out/lib/xP $out/share/xP
			mv $GOPATH/bin/xP $out/lib/xP/
			cp -r public/ $out/share/xP/

			runHook postInstall
		'';
	};

	xS = pkgs.buildGoModule rec {
		_pname = "xS";
		pname = pkgs.lib.strings.toLower _pname;
		inherit version src doCheck meta;

		modRoot = "./${_pname}/";
		vendorHash = null;

		# This invokes a premature build that may miss compiler flags.
		preBuild = ''
			make
		'';
	};

	# While we can't include them in this derivation, we can link to them.
	postInstall = pkgs.lib.optionals full ''
		makeWrapper ${xP}/lib/xP/xP $out/bin/xP --chdir ${xP}/share/xP/public
		makeWrapper ${xS}/bin/xS $out/bin/xS
	'';

	doCheck = true;

	meta = with pkgs.lib; {
		description = "IRC daemon, bot, TUI client"
			+ optionals full " and its web frontend";
		homepage = "https://git.janouch.name/p/${_pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
