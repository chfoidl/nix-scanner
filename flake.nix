{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
  };

  outputs = { self, nixpkgs }@inputs: let
    systems = [
      # Linux machines
      "x86_64-linux"
      "aarch64-linux"
      # MacOS machines
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem(system: let 
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      deskew-pdf = import ./packages/deskew-pdf.nix {
        inherit lib pkgs;
      };

      simple-scan-deskew = import ./packages/simple-scan-deskew.nix {
        inherit lib pkgs;
      };
    });
  };
}
