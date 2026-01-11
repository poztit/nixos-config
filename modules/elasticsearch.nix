{ config, pkgs, ... }:

{
  # Create Elasticsearch data directory
  systemd.tmpfiles.rules = [
    "d /var/lib/elasticsearch 0755 root root -"
  ];

  # Increase vm.max_map_count for Elasticsearch (required)
  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
  };

  # Elasticsearch systemd service using Podman
  systemd.services.elasticsearch = {
    description = "Elasticsearch search and analytics engine";
    after = [ "network-online.target" "podman.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      # Ensure the data directory exists with proper permissions
      mkdir -p /var/lib/elasticsearch
      chown -R 1000:1000 /var/lib/elasticsearch
      chmod 755 /var/lib/elasticsearch
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
      TimeoutStartSec = "300s";

      # Memory limits for the service
      MemoryMax = "20G";
      MemoryHigh = "18G";

      ExecStartPre = [
        # Remove old container if it exists
        "-${pkgs.podman}/bin/podman rm -f elasticsearch"
      ];

      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name elasticsearch \
          --rm \
          --network host \
          -v /var/lib/elasticsearch:/usr/share/elasticsearch/data:Z \
          -e "discovery.type=single-node" \
          -e "ES_JAVA_OPTS=-Xms8g -Xmx8g" \
          -e "xpack.security.enabled=false" \
          -e "xpack.security.http.ssl.enabled=false" \
          -e "cluster.name=ragflow-cluster" \
          -e "node.name=ragflow-node-1" \
          -e "bootstrap.memory_lock=false" \
          -e "http.cors.enabled=true" \
          -e "http.cors.allow-origin=*" \
          -e "logger.level=info" \
          docker.io/elasticsearch:8.11.3
      '';

      ExecStop = "${pkgs.podman}/bin/podman stop -t 30 elasticsearch";
    };
  };

  # Elasticsearch port 9200 is only accessible from localhost (no firewall rule)
}
