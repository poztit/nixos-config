{ config, inputs, pkgs, ... }:
{
  imports = [
    ./sops.nix
    ./tailscale.nix
  ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";

  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.builder = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9OxDFFSebwOs3fzk9rKXtMrg/5P7JfSOvRodgwamF2 cardno:17_743_598"
    ];
  };

  nix.settings = {
    trusted-users = [ "root" "builder" ];
    max-jobs = 8;
    cores = 0;
    sandbox = "relaxed";
    system-features = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
    pciutils
    wget
    podman
    magic-wormhole
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.pcscd.enable = true;
}
