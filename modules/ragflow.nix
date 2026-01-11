{ config, pkgs, ... }:

{
  # Import SOPS secrets
  sops.secrets = {
    ragflow_db_password = {
      sopsFile = ../secrets/secrets.yaml;
      owner = "root";
      mode = "0400";
    };
    ragflow_secret_key = {
      sopsFile = ../secrets/secrets.yaml;
      owner = "root";
      mode = "0400";
    };
    openai_api_key = {
      sopsFile = ../secrets/secrets.yaml;
      owner = "root";
      mode = "0400";
    };
  };

  # Create RAGFlow data directories
  systemd.tmpfiles.rules = [
    "d /var/lib/ragflow 0755 root root -"
    "d /var/lib/ragflow/data 0755 root root -"
    "d /var/lib/ragflow/models 0755 root root -"
  ];

  # RAGFlow systemd service using Podman
  systemd.services.ragflow = {
    description = "RAGFlow - RAG Engine";
    after = [
      "network-online.target"
      "podman.service"
      "postgresql.service"
      "redis.service"
      "elasticsearch.service"
      "minio.service"
      "minio-init.service"
    ];
    wants = [ "network-online.target" ];
    requires = [
      "postgresql.service"
      "redis.service"
      "elasticsearch.service"
      "minio.service"
    ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      # Ensure the data directories exist
      mkdir -p /var/lib/ragflow/data
      mkdir -p /var/lib/ragflow/models

      # Wait for dependencies to be ready
      echo "Waiting for PostgreSQL..."
      for i in {1..30}; do
        if ${pkgs.postgresql_15}/bin/psql -U ragflow -d ragflow -c "SELECT 1" &>/dev/null; then
          echo "PostgreSQL is ready!"
          break
        fi
        sleep 2
      done

      echo "Waiting for Redis..."
      for i in {1..30}; do
        if ${pkgs.redis}/bin/redis-cli ping &>/dev/null; then
          echo "Redis is ready!"
          break
        fi
        sleep 2
      done

      echo "Waiting for Elasticsearch..."
      for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -f http://localhost:9200/_cluster/health &>/dev/null; then
          echo "Elasticsearch is ready!"
          break
        fi
        sleep 2
      done

      echo "Waiting for MinIO..."
      for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -f http://localhost:9000/minio/health/live &>/dev/null; then
          echo "MinIO is ready!"
          break
        fi
        sleep 2
      done
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
      TimeoutStartSec = "300s";

      ExecStartPre = [
        # Remove old container if it exists
        "-${pkgs.podman}/bin/podman rm -f ragflow"
      ];

      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name ragflow \
          --rm \
          --network host \
          -v /var/lib/ragflow/data:/ragflow/data:Z \
          -v /var/lib/ragflow/models:/root/.cache:Z \
          -e "DB_TYPE=postgresql" \
          -e "POSTGRES_HOST=localhost" \
          -e "POSTGRES_PORT=5432" \
          -e "POSTGRES_USER=ragflow" \
          -e "POSTGRES_PASSWORD=$(cat ${config.sops.secrets.ragflow_db_password.path})" \
          -e "POSTGRES_DB=ragflow" \
          -e "REDIS_HOST=localhost" \
          -e "REDIS_PORT=6379" \
          -e "REDIS_DB=0" \
          -e "ES_HOSTS=http://localhost:9200" \
          -e "MINIO_ENDPOINT=localhost:9000" \
          -e "MINIO_ACCESS_KEY=minioadmin" \
          -e "MINIO_SECRET_KEY=minioadmin123" \
          -e "MINIO_SECURE=false" \
          -e "MINIO_BUCKET=ragflow" \
          -e "SECRET_KEY=$(cat ${config.sops.secrets.ragflow_secret_key.path})" \
          -e "LLM_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})" \
          -e "OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})" \
          -e "LLM_FACTORY=OpenAI" \
          -e "EMBEDDING_MODEL=text-embedding-3-small" \
          -e "CHAT_MODEL=gpt-4" \
          -e "SVR_HTTP_PORT=9380" \
          -e "HOST_IP=0.0.0.0" \
          -e "TIMEZONE=UTC" \
          docker.io/infiniflow/ragflow:latest
      '';

      ExecStop = "${pkgs.podman}/bin/podman stop -t 30 ragflow";
    };
  };

  # RAGFlow port 9380 is only accessible from localhost (Nginx will proxy it)
}
