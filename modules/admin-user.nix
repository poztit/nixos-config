{ config, lib, pkgs, ... }:

{
  # Create an admin user for server management
  users.users.admin = {
    isNormalUser = true;
    description = "System Administrator";
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "docker" # if docker is used
    ];
    shell = pkgs.zsh;

    # SSH public keys for the admin user
    # Replace these with your actual SSH public keys
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9OxDFFSebwOs3fzk9rKXtMrg/5P7JfSOvRodgwamF2 cardno:17_743_598"
    ];
  };

  # Configure sudo access for admin user
  security.sudo.extraRules = [
    {
      users = [ "admin" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # Remove NOPASSWD if you want password prompt
        }
      ];
    }
  ];
}
