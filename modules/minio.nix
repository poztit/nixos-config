{ config, pkgs, ... }:

{
  # Create MinIO data directory
  systemd.tmpfiles.rules = [
    "d /var/lib/minio 0755 root root -"
  ];

  # MinIO systemd service using Podman
  systemd.services.minio = {
    description = "MinIO Object Storage";
    after = [ "network-online.target" "podman.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      # Ensure the data directory exists with proper permissions
      mkdir -p /var/lib/minio
      chown -R 1000:1000 /var/lib/minio
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";

      ExecStartPre = [
        # Remove old container if it exists
        "-${pkgs.podman}/bin/podman rm -f minio"
      ];

      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name minio \
          --rm \
          --network host \
          -v /var/lib/minio:/data:Z \
          -e "MINIO_ROOT_USER=minioadmin" \
          -e "MINIO_ROOT_PASSWORD=minioadmin123" \
          -e "MINIO_BROWSER=on" \
          docker.io/minio/minio:latest \
          server /data --console-address ":9001"
      '';

      ExecStop = "${pkgs.podman}/bin/podman stop -t 10 minio";
    };
  };

  # MinIO bucket creation service (runs after MinIO is up)
  systemd.services.minio-init = {
    description = "Initialize MinIO buckets for RAGFlow";
    after = [ "minio.service" ];
    wants = [ "minio.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Wait for MinIO to be ready
      echo "Waiting for MinIO to be ready..."
      for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -f http://localhost:9000/minio/health/live &>/dev/null; then
          echo "MinIO is ready!"
          break
        fi
        echo "Waiting for MinIO... ($i/30)"
        sleep 2
      done

      # Use Podman to run mc (MinIO client) to create bucket
      ${pkgs.podman}/bin/podman run --rm --network host \
        docker.io/minio/mc:latest \
        sh -c "
          mc alias set local http://localhost:9000 minioadmin minioadmin123 && \
          mc mb --ignore-existing local/ragflow && \
          mc anonymous set download local/ragflow && \
          echo 'MinIO bucket ragflow created successfully'
        " || echo "Bucket creation failed or already exists"
    '';
  };

  # MinIO ports are only accessible from localhost (no firewall rules needed)
  # Port 9000: API
  # Port 9001: Console
}
