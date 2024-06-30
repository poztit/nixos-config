{ config, pkgs, ... }:
{
  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  #nixpkgs.config.permittedInsecurePackages = [
  #  "electron-25.9.0"
  #];

  hardware.opengl.driSupport32Bit = true;

  hardware.ledger.enable = true;

  security.rtkit.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.extraConfig.pipewire = {
    "10-default-clock" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 ];
      };
    };
  };
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
    gnome.gnome-music
    gnome.totem
    gnome-photos
    gnome-tour
    gnome-connections
    epiphany
    gedit
    calls
    gnome.geary
    gnome.gnome-maps
    gnome.gnome-logs
    gnome_mplayer
    gnome.cheese
  ]);

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  # For wireless printers
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  users.users.fillien = {
    isNormalUser = true;
    extraGroups = [ "wheel" "adbusers" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    ripgrep
    xdg-desktop-portal-gnome
    ledger-live-desktop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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
