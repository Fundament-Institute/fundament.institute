{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    luvitpkgs.url = "github:aiverson/luvit-nix";
  };

  outputs = inputs@{ self, nixpkgs, luvitpkgs }: {
    packages.x86_64-linux.fundament-institute-web =
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
      in server;
    # Specify the default package
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.fundament-institute-web;
  };
}
