{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    # Listen on localhost only
    enableTCPIP = false;

    # Data directory
    dataDir = "/var/lib/postgresql/15";

    # Ensure databases are created
    ensureDatabases = [ "ragflow" ];

    # Ensure users are created
    ensureUsers = [
      {
        name = "ragflow";
        ensureDBOwnership = true;
      }
    ];

    # Authentication settings
    authentication = pkgs.lib.mkOverride 10 ''
      # Allow local connections
      local   all             all                                     peer
      # Allow localhost TCP connections
      host    all             all             127.0.0.1/32            md5
      host    all             all             ::1/128                 md5
    '';

    # PostgreSQL settings optimized for RAGFlow
    settings = {
      # Memory settings
      shared_buffers = "2GB";
      effective_cache_size = "6GB";
      maintenance_work_mem = "512MB";
      work_mem = "64MB";

      # WAL settings
      wal_buffers = "16MB";
      max_wal_size = "4GB";
      min_wal_size = "1GB";

      # Connection settings
      max_connections = 200;

      # Performance
      random_page_cost = 1.1;  # SSD optimized
      effective_io_concurrency = 200;

      # Logging
      log_destination = "stderr";
      logging_collector = true;
      log_directory = "/var/log/postgresql";
      log_filename = "postgresql-%Y-%m-%d.log";
      log_line_prefix = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ";
      log_min_duration_statement = 1000;  # Log slow queries > 1s
    };
  };

  # Ensure log directory exists
  systemd.tmpfiles.rules = [
    "d /var/log/postgresql 0750 postgres postgres -"
  ];

  # Ensure PostgreSQL is started before RAGFlow
  systemd.services.postgresql.wantedBy = [ "multi-user.target" ];
}
