{ config, lib, pkgs, ... }:

{
  # Enable Podman for container management
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Create systemd service for ArangoDB container
  systemd.services.arangodb = {
    description = "ArangoDB Database Server";
    after = [ "network.target" "podman.service" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";

      # Ensure data directory exists
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p /var/lib/arangodb3"
        "${pkgs.coreutils}/bin/chown -R 1000:1000 /var/lib/arangodb3"
      ];

      # Run ArangoDB container
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm \
          --name arangodb \
          -p 8529:8529 \
          -v /var/lib/arangodb3:/var/lib/arangodb3 \
          -e ARANGO_NO_AUTH=1 \
          docker.io/arangodb/arangodb:latest \
          --experimental-vector-index=true
      '';

      ExecStop = "${pkgs.podman}/bin/podman stop -t 10 arangodb";
    };
  };

  # Open firewall port for ArangoDB
  networking.firewall.allowedTCPPorts = [ 8529 ];

  # Create data directory
  systemd.tmpfiles.rules = [
    "d /var/lib/arangodb3 0755 1000 1000 -"
  ];
}
