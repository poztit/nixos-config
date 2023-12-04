{
  description = "François's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      nixosConfigurations = {
        "laptop" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/laptop/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.fillien = import ./home/default.nix;
            }
          ];
        };
        "desktop" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/desktop/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.fillien = import ./home/default.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        "fillien" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/default.nix
          ];
        };
      };
    };
}
