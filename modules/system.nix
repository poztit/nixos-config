{ config, inputs, pkgs, ... }:
{
  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  hardware.graphics.enable32Bit = true;

  hardware.ledger.enable = true;

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [];
  sops.gnupg.sshKeyPaths = [];
  sops.age.keyFile = "/home/fillien/.config/sops/age/keys.txt";

  sops.secrets.tailscale_key = {};

  security.rtkit.enable = true;
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

  services.pcscd.enable = true;

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

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  services.tailscale.enable = true;


  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --auth-key file:${config.sops.secrets.tailscale_key.path}
    '';
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
    neovim
    wget
    git
    ripgrep
    pciutils
    usbutils
    xdg-desktop-portal-gnome
    ledger-live-desktop
    tailscale
    age-plugin-yubikey
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
