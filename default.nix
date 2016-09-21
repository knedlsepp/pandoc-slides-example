{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:
with import nixpkgs { inherit system; };

stdenv.mkDerivation {
  name = "slide-builder";
  src = ./.;
  buildInputs = [ pandoc ];
}