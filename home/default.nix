{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  home = {
    username = "fillien";
    homeDirectory = "/home/fillien";
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.
    sessionVariables = {
      EDITOR = "emacs";
      BROWSER = "brave";
      MOZ_ENABLE_WAYLAND = 1;
    };
    shellAliases = {
      # Replace ls by exa
      ls = "eza --sort type --classify";
      l = "eza --sort type --classify";
      ll = "eza --long --icons --sort type --classify";
      lll = "eza --long --icons --all --sort type --classify";
      la = "eza --all --sort type --classify";
      lla = "eza --long --icons --all --sort type --classify";
      lt = "eza --tree --sort type";

      # Cat with syntax highlighting
      ccat = "pygmentize -g -O style=stata-dark,linenos=1";

      # Use Neovim in place of Vim
      vim = "nvim";
    };
    sessionPath = [ "$HOME/univ-nantes/tools" "$HOME/univ-nantes/thèse/tools" ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.

  home.packages = with pkgs; [
    fira
    source-code-pro
    source-sans-pro
    (nerdfonts.override { fonts = [ "FiraCode" "FantasqueSansMono" ]; })

    firefox
    ledger
    hledger
    eza
    gnome.gnome-settings-daemon
    gnome.gnome-backgrounds
    gnome.gnome-clocks
    gnome.gnome-weather
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    htop
    nvme-cli
    python39Packages.pygments
    ripgrep
    stow
    sublime-merge
    vlc
    mattermost-desktop
    clang-tools
    calls
    libreoffice-fresh
    evince
    node2nix
    pass
    git-crypt
    languagetool
    lz4
    mdcat
    khard
    zoom
    gnome-network-displays
    cobang
    nextcloud-client
  ];

  xdg.configFile."khard/khard.conf".text = ''
    [addressbooks]
    [[personal]]
    path = ~/Contacts/Personal/contacts
  '';

  xdg.configFile."aerc/univ-signature".source = ./accounts/univ-signature.txt;

  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;

  imports = [
    ./programs/aerc.nix
    ./accounts/email.nix
  ];

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

  programs = {
    home-manager.enable = true;
    #firefox = {
    #  enable = true;
    #  package = pkgs.firefox-wayland;
    #  profiles."fillien" = {
    #  	settings = {
    #      "layout.css.prefers-color-scheme.content-override" = 0;
    #      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    #      "intl.locale.requested" = "fr,en-US";
    #      "signon.rememberSignons" = false;
    #      "browser.startup.page" = 3;
    #      "browser.newtabpage.activity-stream.feeds.topsites" = false;
    #      "extensions.formautofill.creditCards.enabled" = false;
    #    };
    #  };
    #};

    #vdirsyncer.enable = false;

    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "François Illien";
      userEmail = "francois@illien.org";
      signing.key = "DB5372EA1A0CAAD5206F966E1E5F31E85D6D31FB";
      signing.signByDefault = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv.enable = true;
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      "oh-my-zsh" = {
        enable = true;
        plugins = [ "history" ];
      };
      localVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#a89984";
        LESS_TERMCAP_mb = "$'\E[01;31m'";
        LESS_TERMCAP_md = "$'\E[01;31m'";
        LESS_TERMCAP_me = "$'\E[0m'";
        LESS_TERMCAP_se = "$'\E[0m'";
        LESS_TERMCAP_so = "$'\E[01;44;33m'";
        LESS_TERMCAP_ue = "$'\E[0m'";
        LESS_TERMCAP_us = "$'\E[01;32m'";
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
  };

  #services.vdirsyncer.enable = true;
  services.emacs.enable = true;

  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';
  services.ssh-agent.enable = false;
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };
}
