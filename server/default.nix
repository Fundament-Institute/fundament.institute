{ lib, luvitpkgs, static, ... }:

luvitpkgs.lib.x86_64-linux.makeLitPackage {
  pname = "fundament.institute";
  version = "0.0.1";

  litSha256 = "sha256-0jObLw/HeHped8A6kYustJzJmgI43LjDimK2BCRZCNo=";

  patchPhase = if static != null then "cp -r ${static} static" else "";

  src = lib.sourceFilesBySuffices ./. [
    ".lua"
    ".html"
    ".c"
    ".h"
    ".js"
    ".css"
    ".png"
    ".dat"
  ];
}
