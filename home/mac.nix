{ lib, config, pkgs, ... }:

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
      PATH = "$HOME/.lmstudio/bin:$HOME/.local/bin:$PATH";
    };
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

  # macOS-specific: Nushell integration
  programs.starship.enableNushellIntegration = true;
  programs.direnv.enableNushellIntegration = true;

  programs.ghostty = {
    enable = true;
    package = null; # Installed via Homebrew
    settings = {
      theme = "light:Atom One Light,dark:Atom One Dark";
      window-theme = "auto";
      font-family = "FiraCode Nerd Font";
      font-size = 14;
      command = "${pkgs.nushell}/bin/nu";
    };
  };

  programs.nushell = {
    enable = true;
    configFile.text = ''
      # Dark theme colors
      const dark_theme = {
        separator: dark_gray
        leading_trailing_space_bg: { attr: n }
        header: green_bold
        empty: blue
        bool: light_cyan
        int: white
        filesize: cyan
        duration: white
        date: purple
        range: white
        float: white
        string: white
        nothing: white
        binary: white
        cell_path: white
        row_index: green_bold
        record: white
        list: white
        hints: dark_gray
        shape_garbage: red_bold
        shape_binary: purple_bold
        shape_bool: light_cyan
        shape_int: purple_bold
        shape_float: purple_bold
        shape_range: yellow_bold
        shape_internalcall: cyan_bold
        shape_external: cyan
        shape_externalarg: green_bold
        shape_literal: blue
        shape_operator: yellow
        shape_signature: green_bold
        shape_string: green
        shape_string_interpolation: cyan_bold
        shape_datetime: cyan_bold
        shape_list: cyan_bold
        shape_table: blue_bold
        shape_record: cyan_bold
        shape_block: blue_bold
        shape_filepath: cyan
        shape_directory: cyan
        shape_globpattern: cyan_bold
        shape_variable: purple
        shape_flag: blue_bold
        shape_pipe: purple_bold
        shape_redirection: purple_bold
        shape_custom: green
        shape_nothing: light_cyan
        shape_matching_brackets: { attr: u }
      }

      # Light theme colors - darker colors for light backgrounds
      const light_theme = {
        separator: light_gray
        leading_trailing_space_bg: { attr: n }
        header: dark_gray
        empty: blue
        bool: dark_cyan
        int: black
        filesize: dark_cyan
        duration: black
        date: purple
        range: black
        float: black
        string: black
        nothing: black
        binary: black
        cell_path: black
        row_index: dark_green
        record: black
        list: black
        hints: light_gray
        shape_garbage: red_bold
        shape_binary: purple
        shape_bool: dark_cyan
        shape_int: purple
        shape_float: purple
        shape_range: yellow
        shape_internalcall: blue_bold
        shape_external: blue
        shape_externalarg: dark_green
        shape_literal: dark_blue
        shape_operator: yellow
        shape_signature: dark_green
        shape_string: dark_green
        shape_string_interpolation: dark_cyan
        shape_datetime: dark_cyan
        shape_list: dark_cyan
        shape_table: dark_blue
        shape_record: dark_cyan
        shape_block: dark_blue
        shape_filepath: dark_cyan
        shape_directory: dark_cyan
        shape_globpattern: dark_cyan
        shape_variable: purple
        shape_flag: dark_blue
        shape_pipe: purple
        shape_redirection: purple
        shape_custom: dark_green
        shape_nothing: dark_cyan
        shape_matching_brackets: { attr: u }
      }

      # Detect macOS appearance
      def is-dark-mode [] {
        (do { defaults read -g AppleInterfaceStyle } | complete | get stdout | str trim) == "Dark"
      }

      # Update theme based on macOS appearance
      def update-theme [] {
        if (is-dark-mode) {
          $env.config.color_config = $dark_theme
        } else {
          $env.config.color_config = $light_theme
        }
      }

      # Initial config with pre_prompt hook to auto-update theme
      $env.config = {
        show_banner: false
        edit_mode: emacs
        color_config: (if (is-dark-mode) { $dark_theme } else { $light_theme })
        hooks: {
          pre_prompt: [{ update-theme }]
        }
      }

      # Sorted ls variants - directories first, then by name
      def l [path?: path] { (if ($path | is-empty) { ls } else { ls $path }) | sort-by { $in.type != "dir" } name }
      def ll [path?: path] { (if ($path | is-empty) { ls -l } else { ls -l $path }) | sort-by { $in.type != "dir" } name }
      def la [path?: path] { (if ($path | is-empty) { ls -a } else { ls -a $path }) | sort-by { $in.type != "dir" } name }
      def lla [path?: path] { (if ($path | is-empty) { ls -la } else { ls -la $path }) | sort-by { $in.type != "dir" } name }
    '';
    envFile.text = ''
      # Set up PATH first (nix profiles + custom paths)
      $env.PATH = ($env.PATH | split row (char esep) | prepend [
        $"/etc/profiles/per-user/($env.USER)/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        $"($env.HOME)/.nix-profile/bin"
        $"($env.HOME)/.lmstudio/bin"
        $"($env.HOME)/.local/bin"
      ])

      $env.EDITOR = "nvim"
      $env.GPG_TTY = (tty)
      $env.SSH_AUTH_SOCK = (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket | str trim)
      $env.OPENAI_API_KEY = (open ${config.sops.secrets.openai_key.path} | str trim)
      $env.XAI_API_KEY = (open ${config.sops.secrets.xai_key.path} | str trim)
    '';
  };
}
