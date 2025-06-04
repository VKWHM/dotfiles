{pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "gwatch";
  version = "1.0";
  src = ./.;
}
