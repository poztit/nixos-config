{ config, lib, pkgs, ... }:

{
  services.arangodb = {
    enable = true;

    # Database configuration
    databasePath = "/var/lib/arangodb3";

    # Network configuration
    # Listen on all interfaces - adjust as needed for security
    endpoints = [
      "tcp://0.0.0.0:8529"
    ];

    # Enable authentication
    authentication = true;

    # Additional settings can be configured here
    extraOptions = [
      "--server.statistics=true"
      "--log.level=info"
    ];
  };

  # Open firewall port for ArangoDB
  networking.firewall.allowedTCPPorts = [ 8529 ];

  # Ensure the service has proper permissions
  systemd.services.arangodb3 = {
    serviceConfig = {
      # Additional security hardening
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/arangodb3" "/var/log/arangodb3" ];
    };
  };
}
