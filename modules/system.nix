{ config, pkgs, ... }:
{
  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  hardware.opengl.driSupport32Bit = true;
  
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.dbus.enable = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "fr";
    xkbVariant = "us";
    xkbOptions = "caps:escape";
    libinput.enable = true;
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

  services.printing.enable = true;

  users.users.fillien = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    ripgrep
    xdg-desktop-portal-gnome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
