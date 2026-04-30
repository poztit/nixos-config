{ lib, config, pkgs, ... }:

  let
  # Dynamic environment variables shared between POSIX shells (zsh, bash)
  posixDynamicEnv = ''
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_key.path})
    export XAI_API_KEY=$(cat ${config.sops.secrets.xai_key.path})
    export OPENCODE_ENABLE_EXA=1
  '';
in
{
  imports = [ ./common.nix ];

  myHome = {
    username = "francoisillien";
    homeDirectory = "/Users/francoisillien";
    pinentryPackage = pkgs.pinentry_mac;
  };

  sops.secrets.openai_key = { };
  sops.secrets.xai_key = { };

  home = {
    stateVersion = "24.11";
    file.".hushlogin".text = "";
    sessionVariables = {
      EDITOR = "nvim";
    };
    sessionPath = [
      "$HOME/.opencode/bin"
      "$HOME/.lmstudio/bin"
      "$HOME/.local/bin"
    ];
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    (python313.withPackages (ps: with ps; [ pynvim numpy jupyter pygments seaborn ]))

    # Build tools
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
    ncurses
    unrar

    # Additional tools
    yubikey-personalization
    ffmpeg
    luaPackages.luarocks
    nixd
    nil
    lua-language-server
    texlab
    rclone
    (texlive.combine { inherit (texlive) scheme-full pgfplots tikzmark; })
  ];

  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter
  ];

  # Enable bash and set dynamic env vars for POSIX shells
  programs.bash = {
    enable = true;
    initExtra = posixDynamicEnv;
  };

  programs.zsh.initContent = posixDynamicEnv;

  programs.ghostty = {
    enable = true;
    package = null; # Installed via Homebrew
    settings = {
      theme = "light:Atom One Light,dark:Atom One Dark";
      window-theme = "auto";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      cursor-style = "block";
      shell-integration-features = "no-cursor,no-sudo,title";
      command = "${pkgs.zsh}/bin/zsh";
    };
  };

}
