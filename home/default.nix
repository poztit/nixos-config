{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  imports = [
    ./common.nix
    ./programs/aerc.nix
    ./programs/emacs/default.nix
    ./accounts/email.nix
  ];

  myHome = {
    username = "fillien";
    homeDirectory = "/home/fillien";
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  home = {
    stateVersion = "23.05";
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "google-chrome-stable";
      MOZ_ENABLE_WAYLAND = 1;
    };
    shellAliases = {
      ccat = "pygmentize -g -O style=stata-dark,linenos=1";
      vim = "nvim";
    };
    sessionPath = [ "$HOME/univ-nantes/tools" "$HOME/univ-nantes/thèse/tools" ];
  };

  # Linux-specific packages
  home.packages = with pkgs; [
    (python312.withPackages (ps: with ps; [ pynvim numpy jupyter pygments seaborn plotly ]))
    bitwarden
    chromium
    cmake
    doxygen
    endless-sky
    evince
    firefox
    framesh
    fwupd
    git-crypt
    gnome-network-displays
    gnome-tweaks
    gnome-backgrounds
    gnome-clocks
    gnome-settings-daemon
    gnome-weather
    gnomeExtensions.appindicator
    gnuplot
    google-chrome
    graphviz
    gtest
    gthumb
    hledger
    htop
    imagemagick
    inkscape
    jetbrains-mono
    khard
    languagetool
    ledger
    libreoffice-fresh
    lz4
    massif-visualizer
    mdcat
    mpv
    nextcloud-client
    ninja
    node2nix
    nvme-cli
    pass
    pavucontrol
    pinentry
    pinta
    scrcpy
    sublime-merge
    texstudio
    valgrind
    vlc
    wl-clipboard
    yubioath-flutter
    zoom-us
  ];

  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;

  programs.starship.enableZshIntegration = true;

  xdg.configFile."khard/khard.conf".text = ''
    [addressbooks]
    [[personal]]
    path = ~/Contacts/Personal/contacts
  '';

  xdg.configFile."aerc/univ-signature".source = ./accounts/univ-signature.txt;

  accounts.contact = {
    basePath = "Contacts";
    accounts = {
      "Personal" = {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
        };
        remote = {
          url = "https://cloud.illien.org";
          type = "carddav";
          userName = "francois";
          passwordCommand = [ "pass" "personal-cloud" ];
        };
        vdirsyncer = {
          enable = true;
          collections = [ "contacts" ];
          conflictResolution = [ "remote wins" ];
        };
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      clock-show-date = true;
      clock-show-seconds = true;
      show-battery-percentage = true;
    };
    "org/gnome/desktop/calendar" = { show-weekdate = true; };
    "org/gnome/desktop/background" = {
      picture-uri = "";
      primary-color = "#2e3440";
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
    };
    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "fr+us" ]) ];
      xkb-options = "[]";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
      tap-to-click = true;
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
  };

  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';
}
