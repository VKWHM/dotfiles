return {
	cmd = { "nixd" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import (if builtins.pathExists ./flake.nix then (builtins.getFlake(toString ./.)).inputs.nixpkgs else <nixpkgs>) { }",
			},
			options = {
				-- nixos = {
				-- 	expr = "let flake = builtins.getFlake(toString ./.); in flake.nixosConfigurations.nz.options",
				-- },
				["home-manager"] = {
					expr = "(builtins.getFlake (\"git+file://\" + toString ./.)).homeConfigurations.${builtins.currentSystem}.options",
				},
				darwin = {
					expr = "(builtins.getFlake (\"git+file://\" + toString ./.)).darwinConfigurations.\"${builtins.elemAt (builtins.match \"^([^-]+)-(linux|darwin)?$\" builtins.currentSystem) 0}-darwin\".options",
				},
			},
		},
	},
}
