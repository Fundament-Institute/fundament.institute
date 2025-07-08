{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

let

  lua = lua52Packages.lua.withPackages
    (p: with p; [ lpeg markdown luafilesystem penlight ]);

  website = stdenv.mkDerivation rec {
    name = "fundament-institute-website-${version}";
    version = "0.0.1";
    src = ./.;
    buildInputs = [ lua ];

    buildPhase = ''
      mkdir $out
      lua build.lua . $out
    '';
    installPhase = ''
      # cp -r static $out/
    '';

    LUA_PATH = "./?.lua;";

    meta = {
      description = "Fundament Research Institute website";
      homepage = "https://github.com/Fundament-Institute/fundament.institute";

      license = lib.licenses.apache2;
      platforms = lib.platforms.all;
    };
  };
in website
