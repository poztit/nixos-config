{ config, lib, pkgs, ... }:
{
  # Nix store optimization and performance settings
  nix.settings = {
    # Fix download buffer warning - increase from default 64MB to 256MB
    download-buffer-size = 268435456; # 256MB in bytes

    # Automatically optimize store by hard-linking identical files
    auto-optimise-store = true;

    # Disk space management - auto-trigger GC when space is low
    min-free = lib.mkDefault (5 * 1024 * 1024 * 1024); # 5GB
    max-free = lib.mkDefault (10 * 1024 * 1024 * 1024); # 10GB

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
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  # Keep last 7 boot generations
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 7;
  boot.loader.grub.configurationLimit = lib.mkDefault 7;

  # Periodic store optimization (runs weekly)
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
