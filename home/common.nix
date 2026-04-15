{ lib, config, pkgs, ... }:

{
  options.myHome = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for home-manager";
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "The home directory path";
    };
    pinentryPackage = lib.mkOption {
      type = lib.types.package;
      description = "The pinentry package to use for GPG";
    };
  };

  config = {
    home = {
      username = config.myHome.username;
      homeDirectory = config.myHome.homeDirectory;
    };

    home.packages = with pkgs; [
      # Fonts
      nerd-fonts.fira-code
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      google-fonts

      # Development tools
      age
      imagemagick
      clang-tools
      fd
      gh
      gnupg
      jq
      lua
      neovim
      nodejs
      ripgrep
      sops
      magic-wormhole
    ];

    programs = {
      home-manager.enable = true;

      git = {
        enable = true;
        package = pkgs.gitFull;
        settings = {
          user.name = "François Illien";
          user.email = "francois@illien.org";
        };
        signing.key = "DB5372EA1A0CAAD5206F966E1E5F31E85D6D31FB";
        signing.signByDefault = true;
        signing.format = "openpgp";
      };

      starship = {
        enable = true;
        settings.command_timeout = 1000;
      };

      eza = {
        enable = true;
        icons = "auto";
        git = true;
        extraOptions = [
          "--group-directories-first"
        ];
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
          size = 10000;
          save = 10000;
          ignoreAllDups = true;
          ignoreSpace = true;
          share = true;
        };
        initContent = ''
          # CSI u (kitty keyboard protocol) bindings for Ctrl+ keys
          # Format: \e[<unicode codepoint>;<modifier>u where 5 = Ctrl
          bindkey '\e[97;5u'  beginning-of-line                    # Ctrl+A
          bindkey '\e[98;5u'  backward-char                        # Ctrl+B
          bindkey '\e[100;5u' delete-char-or-list                  # Ctrl+D
          bindkey '\e[101;5u' end-of-line                          # Ctrl+E
          bindkey '\e[102;5u' forward-char                         # Ctrl+F
          bindkey '\e[104;5u' backward-delete-char                 # Ctrl+H
          bindkey '\e[107;5u' kill-line                            # Ctrl+K
          bindkey '\e[108;5u' clear-screen                         # Ctrl+L
          bindkey '\e[110;5u' down-line-or-history                 # Ctrl+N
          bindkey '\e[112;5u' up-line-or-history                   # Ctrl+P
          bindkey '\e[114;5u' history-incremental-search-backward  # Ctrl+R
          bindkey '\e[116;5u' transpose-chars                      # Ctrl+T
          bindkey '\e[117;5u' kill-whole-line                      # Ctrl+U
          bindkey '\e[119;5u' backward-kill-word                   # Ctrl+W
          bindkey '\e[121;5u' yank                                 # Ctrl+Y
        '';
        localVariables = {
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#a89984";
          LESS_TERMCAP_mb = "$'\\E[01;31m'";
          LESS_TERMCAP_md = "$'\\E[01;31m'";
          LESS_TERMCAP_me = "$'\\E[0m'";
          LESS_TERMCAP_se = "$'\\E[0m'";
          LESS_TERMCAP_so = "$'\\E[01;44;33m'";
          LESS_TERMCAP_ue = "$'\\E[0m'";
          LESS_TERMCAP_us = "$'\\E[01;32m'";
        };
      };
    };

    services.ssh-agent.enable = false;
    services.gpg-agent = {
      enable = true;
      enableScDaemon = true;
      enableSshSupport = true;
      pinentry.package = config.myHome.pinentryPackage;
    };

    xdg.configFile.nvim = {
      source = ./programs/nvim;
      recursive = true;
    };
  };
}
