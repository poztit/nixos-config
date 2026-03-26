{ config, pkgs, ... }:
{
  nix.settings.trusted-users = [ "github-runner-spawnr" ];

  sops.secrets.github_runner_token = {
    owner = "root";
    mode = "0400";
  };

  services.github-runners.spawnr = {
    enable = true;
    url = "https://github.com/fillien/spawnr.dev";
    tokenFile = config.sops.secrets.github_runner_token.path;
    name = "nix-builder";
    replace = true;
    extraPackages = with pkgs; [
      git
      nix
    ];
  };
}
