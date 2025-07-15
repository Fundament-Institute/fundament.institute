{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    luvitpkgs.url = "github:aiverson/luvit-nix";
  };

  outputs = inputs@{ self, nixpkgs, luvitpkgs }:
      let pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          content = pkgs.callPackage ./content { };
          static = pkgs.runCommand "fundament-static" { } ''
            mkdir -p $out
            cp -r ${content}/* $out
            cp -r ${./static}/* $out
          '';
          server = pkgs.callPackage ./server { inherit static luvitpkgs; };
      in {
    packages.x86_64-linux = {fundament-institute-web = server;
  default = server;
  static = static;
};
  };
}
