{ self, pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  imports =
    [
      # ../modules/tailscale.nix
    ];

  environment.systemPackages =
    [
      pkgs.vim
      pkgs.clang-tools
      pkgs.clang
      pkgs.nixos-rebuild
    ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "root" "francoisillien" ];

  programs.zsh.enable = true;

  users.users.francoisillien = {
    name = "francoisillien";
    home = "/Users/francoisillien";
  };

  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';


  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
    PubkeyAcceptedKeyTypes ssh-ed25519
    ServerAliveInterval 60
    IPQoS throughput
  '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
    home-builder = {
      hostNames = [ "100.108.195.45" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGfO1kZxCImWUUjXz3HJb01xBn0FP8XiIel61uBxEkY";
    };
  };

  environment.variables = {
    SOPS_AGE_KEY_FILE = "/Users/francoisillien/.config/sops/age/keys.txt";
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
      {
        hostName = "100.108.195.45";
        sshUser = "builder";
        system = "x86_64-linux";
        protocol = "ssh"; # (Nix uses ssh-ng under the hood when available)
        maxJobs = 8; # match the server's max-jobs
        speedFactor = 2; # higher = prefer this machine more often
        supportedFeatures = [ "big-parallel" "kvm" "benchmark" "nixos-test" ];
      }
    ];

    # Nix store optimization settings
    settings = {
      # Fix download buffer warning - increase from default 64MB to 256MB
      download-buffer-size = 268435456; # 256MB in bytes

      # Note: auto-optimise-store is NOT used on nix-darwin as it can corrupt the store
      # Use nix.optimise.automatic instead (configured below)

      # Disk space management - auto-trigger GC when space is low
      min-free = 5368709120; # 5GB
      max-free = 10737418240; # 10GB

      # Keep build-time dependencies for better debugging
      keep-derivations = true;
      keep-outputs = true;

      # Performance optimizations
      http-connections = 50; # parallel downloads
      download-attempts = 3;
      connect-timeout = 5;

      # Cache settings for faster builds
      narinfo-cache-negative-ttl = 3600; # 1 hour
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 3; Minute = 0; }; # Weekly on Sunday at 3am
      options = "--delete-older-than 60d";
    };

    # Periodic store optimization
    optimise = {
      automatic = true;
      interval = { Weekday = 0; Hour = 4; Minute = 0; }; # Weekly on Sunday at 4am
    };
  };

  launchd.daemons.nix-daemon.serviceConfig = {
    EnvironmentVariables = {
      SSH_AUTH_SOCK = "/Users/francoisillien/.gnupg/S.gpg-agent.ssh";
      SOPS_AGE_KEY_FILE = "/Users/francoisillien/.config/sops/age/keys.txt";
    };
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
