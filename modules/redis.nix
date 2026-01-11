{ config, pkgs, ... }:

{
  # Create Redis data directory
  systemd.tmpfiles.rules = [
    "d /var/lib/redis 0755 root root -"
  ];

  # Redis systemd service using Podman
  systemd.services.redis = {
    description = "Redis in-memory data store";
    after = [ "network-online.target" "podman.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      # Ensure the data directory exists
      mkdir -p /var/lib/redis
      chown -R 999:999 /var/lib/redis
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";

      ExecStartPre = [
        # Remove old container if it exists
        "-${pkgs.podman}/bin/podman rm -f redis"
      ];

      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name redis \
          --rm \
          --network host \
          -v /var/lib/redis:/data:Z \
          docker.io/redis:7.2-alpine \
          redis-server \
          --appendonly yes \
          --appendfsync everysec \
          --save 900 1 \
          --save 300 10 \
          --save 60 10000 \
          --maxmemory 4gb \
          --maxmemory-policy allkeys-lru \
          --tcp-backlog 511 \
          --timeout 0 \
          --tcp-keepalive 300 \
          --loglevel notice
      '';

      ExecStop = "${pkgs.podman}/bin/podman stop -t 10 redis";
    };
  };

  # Open Redis port on localhost only (no firewall rule needed)
  # Port 6379 is only accessible from localhost
}
