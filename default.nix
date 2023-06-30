# Automatically produce an attribute set, so that nix-build works directly.
with builtins; let
	entries = attrNames (builtins.readDir ./.);
	good = filter (name: name != "default.nix") entries;
	nullToList = value: if value != null then value else [];
	nixes = concatMap (name: nullToList (match "(.*)\\.nix" name)) good;
in
	foldl' (acc: name: acc // { ${name} = import ./${name}.nix; }) {} nixes
