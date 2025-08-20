{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  sops.secrets.openai_key = { };
  home = {
    username = "francoisillien";
    homeDirectory = "/Users/francoisillien";
    stateVersion = "24.11"; # Please read the comment before changing.
    sessionVariables = {
      GPG_TTY = "$(tty)";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
      PATH = "$HOME/.lmstudio/bin:$PATH";
      OPENAI_API_KEY = "$(cat ${config.sops.secrets.openai_key.path})";
      EDITOR = "vim";
    };
    shellAliases = {
      ls = "eza --sort type --classify";
      l = "eza --sort type --classify";
      ll = "eza --long --icons --sort type --classify";
      lll = "eza --long --icons --all --sort type --classify";
      la = "eza --all --sort type --classify";
      lla = "eza --long --icons --all --sort type --classify";
      lt = "eza --tree --sort type";

      vim = "nvim";
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.iosevka
    (python313.withPackages (ps: with ps; [ pynvim numpy jupyter pygments seaborn ]))
    age
    clang-tools

    gcc
    gnumake
    pkg-config
    autoconf
    automake
    bison
    bzip2
    coreutils
    curl
    diffutils
    findutils
    flex
    gawk
    gettext
    gzip
    libtool
    m4
    patch
    unzip
    zx
    zlib

    eza
    fd
    fira
    gnupg
    jq
    lua
    neovim
    nodejs
    ripgrep
    sops
    source-code-pro
    source-sans-pro
    wezterm
    yubikey-personalization
    magic-wormhole
    ffmpeg
    luaPackages.luarocks
    nixd
    nil
    rclone
    (texlive.combine { inherit (texlive) scheme-full pgfplots tikzmark; })
  ];

  imports = [
    ./programs/wezterm/default.nix
  ];

  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter
  ];
  xdg.configFile.nvim = {
    source = ./programs/nvim;
    recursive = true;
  };
  services.ssh-agent.enable = false;
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  programs = {
    home-manager.enable = true;
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
      autosuggestion.enable = true;
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
}
