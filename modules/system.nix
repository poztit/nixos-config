{ config, inputs, pkgs, ... }:
{
  imports = [
    ./sound.nix
    ./sops.nix
    ./tailscale.nix
  ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  hardware.graphics.enable32Bit = true;

  hardware.ledger.enable = true;

  services.fwupd.enable = true;
  services.dbus.enable = true;
  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "fr";
    xkb.variant = "us";
    xkb.options = "caps:escape";
  };

  environment.gnome.excludePackages = (with pkgs; [
    calls
    cheese
    epiphany
    geary
    gedit
    gnome-connections
    gnome-logs
    gnome-maps
    gnome-music
    gnome-photos
    gnome-tour
    totem
  ]);

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan pkgs.epkowa ];
  };

  services.ipp-usb.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  # For wireless printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  users.users.fillien = {
    isNormalUser = true;
    extraGroups = [ "wheel" "adbusers" "scanner" "lp" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    ledger-live-desktop
    neovim
    pciutils
    ripgrep
    usbutils
    wget
    xdg-desktop-portal-gnome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.pcscd.enable = true;

  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      mono
    ];
  };
}
