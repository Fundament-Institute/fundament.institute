{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

let
  content = callPackage ./content { };
  static = runCommand "fundament-static" { } ''
    mkdir -p $out
    cp -r ${content}/* $out
    cp -r ${./static}/* $out
       '';
  server = callPackage ./server { inherit static; };
in server
