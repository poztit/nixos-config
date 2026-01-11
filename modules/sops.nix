{ lib, pkgs, options, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  rootHome = if isDarwin then "/Users/francoisillien" else "/root";
  keyFilePath = "${rootHome}/.config/sops/age/keys.txt";
  # Detect if running in Home Manager context by checking if 'owner' option exists
  # System-level sops-nix has 'owner', Home Manager sops-nix does not
  hasOwnerOption = options.sops.secrets.type.nestedTypes.elemType.getSubOptions [ ] ? owner;
in
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    gnupg.sshKeyPaths = [ ];
    age = {
      sshKeyPaths = [ ];
      keyFile = keyFilePath;
    };

    # Define secrets for various services (only at system level where 'owner' exists)
    secrets = lib.mkIf hasOwnerOption {
      # Tailscale
      tailscale_key = {
        owner = "root";
        mode = "0400";
      };
    };
  };
}
