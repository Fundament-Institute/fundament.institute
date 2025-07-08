{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let luvitpkgs = callPackage ./nix/luvitpkgs.nix { };
in mkShell { buildInputs = [ luvitpkgs.lit luvitpkgs.luvi luvitpkgs.luvit ]; }
