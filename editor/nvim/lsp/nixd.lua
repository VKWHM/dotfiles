local flake = '(builtins.getFlake ("git+file://" + toString ./.))'
return {
	settings = {
		nixd = {
			nixpkgs = {
				-- expr = "import " .. flake .. ".inputs.nixpkgs { }",
			},
			formatting = {
				command = { "alejandra" },
			},
			options = {
				nixos = {
					-- expr = flake .. ".nixosConfigurations.\"${builtins.currentSystem}\".options",
				},
				darwin = {
					-- expr = flake .. ".darwinConfigurations.\"${builtins.currentSystem}\".options",
				},
				["home-manager"] = {
					-- expr = flake .. ".homeConfigurations.\"${builtins.currentSystem}\".options",
				},
			},

			diagnostic = {
				suppress = {
					"nixpkgs-unfree",
				},
			},
		},
	},
}
