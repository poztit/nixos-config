{
  description = "François's NixOS Flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      # url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, sops-nix, darwin, home-manager, deploy-rs, ... }:
    let
      pkgs = import nixpkgs {
        config.allowUnfree = true;
      };
    in
    rec {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      devShells =
        let
          systems = builtins.attrNames deploy-rs.packages;
          mkShellFor = system:
            let
              pkgsFor = nixpkgs.legacyPackages.${system};
              deployRsPkg = deploy-rs.packages.${system}.deploy-rs or deploy-rs.packages.${system}.default;
            in
            pkgsFor.mkShell {
              packages = [
                deployRsPkg
              ];
            };
        in
        nixpkgs.lib.genAttrs systems (system: {
          default = mkShellFor system;
        });
      nixosConfigurations = {
        # "laptop" = nixpkgs.lib.nixosSystem {
        #   modules = [
        #     ./hosts/laptop/default.nix
        #     sops-nix.nixosModules.sops
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.users.fillien = import ./home/default.nix;
        #     }
        #   ];
        # };
        # "desktop" = nixpkgs.lib.nixosSystem {
        #   modules = [
        #     ./hosts/desktop/default.nix
        #     sops-nix.nixosModules.sops
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.users.fillien = import ./home/default.nix;
        #     }
        #   ];
        # };
        "server" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/server/default.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
      darwinConfigurations."macbook" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit self; };
        modules = [
          ./hosts/macbook.nix
          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.francoisillien = import ./home/mac.nix;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              ./modules/sops.nix
            ];
          }
          ./modules/sops.nix
        ];
      };
      homeConfigurations = {
        "fillien" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/default.nix
          ];
        };
      };
      deploy.nodes."server" = {
        hostname = "fillien-desktop";
        sshUser = "admin";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.server;
        };
      };
      checks."x86_64-linux" = deploy-rs.lib.x86_64-linux.deployChecks self.deploy;
    };
}
