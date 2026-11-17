{
  description = "EPIVÍOSI MEDIC — documentation médicale et dossiers chiffrés hors-ligne pour EPIVÍOSI OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      modeles = pkgs.callPackage ./templates { };
    in
    {
      # Implémente `epiviosi.medic.enable` (option déclarée par le socle EPIVÍOSI OS).
      nixosModules.default = import ./module.nix;

      packages.${system} = {
        epiviosi-medic-modeles = modeles;
        epiviosi-medic-coffre = pkgs.callPackage ./pkgs/epiviosi-medic-coffre { inherit modeles; };
        default = self.packages.${system}.epiviosi-medic-coffre;
      };

      checks.${system} = {
        inherit (self.packages.${system}) epiviosi-medic-modeles epiviosi-medic-coffre;
        vm = import ./tests/medic.nix {
          inherit pkgs;
          module = self.nixosModules.default;
        };
      };
    };
}
