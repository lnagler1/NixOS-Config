{
  description = "BigNixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    lanzaboote,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        lanzaboote.nixosModules.lanzaboote
        ./configuration.nix
      ];
    };

    formatter.${system} = pkgs.alejandra;
  };
}
