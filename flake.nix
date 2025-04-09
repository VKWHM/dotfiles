{
  description = "WHM Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
  let
    user = rec {
      username = "vkwhm";
      home = "/home/${username}";
    };
    system = "x86_64-linux";
    pkgs = import nixpkgs {
        inherit system;
      };
  in {
    homeConfigurations = {
      ${user.username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./nix/home.nix ];
        extraSpecialArgs = { inherit user; };
      };
    };
  };
}
