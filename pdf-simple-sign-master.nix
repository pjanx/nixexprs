{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.buildGoModule rec {
	pname = "pdf-simple-sign";
	version = "master";

	# The author recognizes that this is awful.
	# gropdf-enabled groff build was broken as of writing.
	nativeCheckInputs = with pkgs; [
		ncurses
		inkscape
		#(groff.override { enableGhostscript = true; })
		libreoffice
		imagemagick

		openssl
		# certutil
		nss.tools
		# pdfsig
		(poppler.override { utils = true; })
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

#	vendorHash = pkgs.lib.fakeHash;
	vendorHash = "sha256-05h2f22TPRwadHZfueO8lXKS3Js7d8QVSOrEkY7qUZ8=";

	doCheck = true;

	# libreoffice doesn't contain the lowriter script.
	patchPhase = ''
		sed -i 's/^lowriter/soffice --writer/' test.sh
	'';

	checkPhase = ''
		runHook preCheck
		./test.sh $GOPATH/bin/pdf-simple-sign
		runHook postCheck
	'';

	meta = with pkgs.lib; {
		description = "Simple PDF signer";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
