{ self, pkgs, ... }: {
  environment.systemPackages =
    [
      pkgs.vim
      pkgs.clang-tools
      pkgs.clang
    ];

  nix.settings.experimental-features = "nix-command flakes";

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
    ];
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
