{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zsh-alias-finder = {
      url = "github:akash329d/zsh-alias-finder";
      flake = false;
    };
    zsh-autopair = {
      url = "github:hlissner/zsh-autopair";
      flake = false;
    };
    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };
    forgit = {
      url = "github:wfxr/forgit";
      flake = false;
    };
  };
  outputs = {
    self,
    darwin,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    home-manager,
    nixpkgs,
    disko,
    flake-utils,
    ...
  } @ inputs: let
    user = "whoami";
    linuxSystems = ["x86_64-linux" "aarch64-linux"];
    darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = with pkgs;
        mkShell {
          nativeBuildInputs = with pkgs; [bashInteractive git];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
    };
    mkApp = scriptName: system: {
      type = "app";
      program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
        #!/usr/bin/env bash
        PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
        echo "Running ${scriptName} for ${system}"
        exec ${self}/nixos-config/apps/${system}/${scriptName}
      '')}/bin/${scriptName}";
    };
    mkLinuxApps = system: {
      "apply" = mkApp "apply" system;
      "build-switch" = mkApp "build-switch" system;
      "copy-keys" = mkApp "copy-keys" system;
      "create-keys" = mkApp "create-keys" system;
      "check-keys" = mkApp "check-keys" system;
      "install" = mkApp "install" system;
    };
    mkDarwinApps = system: {
      "apply" = mkApp "apply" system;
      "build" = mkApp "build" system;
      "build-switch" = mkApp "build-switch" system;
      "copy-keys" = mkApp "copy-keys" system;
      "create-keys" = mkApp "create-keys" system;
      "check-keys" = mkApp "check-keys" system;
      "rollback" = mkApp "rollback" system;
    };
    # Helper to make a Home-Manager config for any system
    makeHomeCfg = build: let
      user = "vkwhm";
      matchSystem = builtins.match "^([^-]+)-linux(-desktop)?$" build;
      isDesktop = (builtins.elemAt matchSystem 1) == "-desktop";
      system = "${builtins.elemAt matchSystem 0}-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          [
            (args: {
              home.username = user;
              home.homeDirectory = "/home/${user}";
              home.stateVersion = "24.11";
              home.whmConfig = {
                enable = true;
                link.nvim = true;
                link.vim = true;
                link.tmux = true;
              };
              utils.theme.appearance =
                if isDesktop
                then "auto"
                else "dark";
            })
            ./nixos-config/modules/shared/whmconfig.nix
            ./nixos-config/modules/shared/utils/theme.nix
            ./nixos-config/modules/shared/shell.nix
          ]
          ++ (
            if isDesktop
            then [
              ./nixos-config/modules/linux/desktop.nix
            ]
            else []
          );

        extraSpecialArgs = {inherit user inputs;};
      };
  in {
    # devShells = forAllSystems devShell;
    apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
    homeConfigurations = nixpkgs.lib.genAttrs (linuxSystems ++ ["x86_64-linux-desktop" "aarch64-linux-desktop"]) (
      system:
        makeHomeCfg system
    );
    darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
      system: let
        user = "whoami";
      in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./nixos-config/hosts/darwin
          ];
        }
    );

    #  nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
    #    inherit system;
    #    specialArgs = inputs;
    #    modules = [
    #      disko.nixosModules.disko
    #      home-manager.nixosModules.home-manager {
    #        home-manager = {
    #          useGlobalPkgs = true;
    #          useUserPackages = true;
    #          users.${user} = import ./modules/nixos/home-manager.nix;
    #        };
    #      }
    #      ./hosts/nixos
    #    ];
    # });
  };
}
