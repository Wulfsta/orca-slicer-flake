{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = { 
    self, 
    nixpkgs
  }:
  let
    supportedSystems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    pkgs = nixpkgs.legacyPackages.system;
  in 
  {
    packages = forAllSystems (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        orca-slicer = pkgs.bambu-studio.overrideDerivation (old: {
          src = pkgs.fetchFromGitHub {
            owner = "SoftFever";
            repo = "OrcaSlicer";
            rev = "v1.8.1";
            hash = "sha256-3aIVi7Wsit4vpFrGdqe7DUEC6HieWAXCdAADVtB5HKc=";
          };
        });
      }
    );
    apps = forAllSystems (system: {
      orca-slicer = {
        type = "app";
        program = "${self.packages.${system}.orca-slicer}/bin/orca-slicer";
      };
    });
  };
}
