{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    # Recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Client settings for file uploads
    clientMaxBodySize = "100m";

    # Virtual host for RAGFlow
    virtualHosts."ragflow.local" = {
      # Listen on all interfaces (Tailscale will provide the IP)
      # No SSL since Tailscale encrypts traffic
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];

      locations."/" = {
        proxyPass = "http://localhost:9380";
        proxyWebsockets = true;  # Enable WebSocket support

        extraConfig = ''
          # Proxy headers
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # WebSocket specific headers
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";

          # Timeouts for long-running requests
          proxy_connect_timeout 300s;
          proxy_send_timeout 300s;
          proxy_read_timeout 300s;

          # Buffering settings
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };

      # Health check endpoint
      locations."/health" = {
        proxyPass = "http://localhost:9380/health";
        extraConfig = ''
          access_log off;
        '';
      };
    };

    # Additional logging
    appendHttpConfig = ''
      # Log format with more details
      log_format detailed '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         'rt=$request_time uct="$upstream_connect_time" '
                         'uht="$upstream_header_time" urt="$upstream_response_time"';

      access_log /var/log/nginx/access.log detailed;
    '';
  };

  # Ensure Nginx starts after RAGFlow
  systemd.services.nginx = {
    after = [ "ragflow.service" ];
    wants = [ "ragflow.service" ];
  };
}
