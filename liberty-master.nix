{ pkgs ? import <nixpkgs> { }
, local ? false
, full ? true
}:
pkgs.stdenv.mkDerivation rec {
	pname = "liberty";
	version = "master";

	nativeBuildInputs = with pkgs; [
		cmake
		pkg-config

		go
		nodejs
		swift
	];

	buildInputs = with pkgs; [
		openssl
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

	# "go vet" creates a build cache within HOME.
	checkPhase = ''
		runHook preCheck
		HOME=$(pwd) ctest --force-new-ctest-process
		runHook postCheck
	'';

	# There is no installation target thus far, don't let nix-build fail.
	installPhase = ''
		mkdir -p $out
	'';

	meta = with pkgs.lib; {
		description = "Core header libraries and utilities";
		homepage = "https://git.janouch.name/p/${pname}";
		platforms = platforms.all;
		license = licenses.bsd0;
	};
}
