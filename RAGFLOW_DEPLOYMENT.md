# RAGFlow Deployment Guide

This guide walks you through deploying RAGFlow on your NixOS server.

## Overview

RAGFlow is deployed with the following architecture:
- **PostgreSQL** (native NixOS) - Metadata storage
- **Redis** (Podman container) - Task queue & caching
- **Elasticsearch** (Podman container) - Document indexing & vector search
- **MinIO** (Podman container) - Object storage
- **RAGFlow** (Podman container) - Main application
- **Nginx** (native NixOS) - Reverse proxy
- **Access**: Tailscale VPN only (port 80)

## Prerequisites

### System Requirements
- **CPU**: 16+ cores (recommended: 24+)
- **RAM**: 32GB minimum (recommended: 64GB)
- **Disk**: 300GB+ free space on SSD
  - PostgreSQL: ~20GB
  - Elasticsearch: 50-100GB
  - MinIO: 100GB+
  - Models cache: 50GB
  - Temporary files: 50GB+

### Check Available Resources

```bash
# Check CPU
nproc

# Check RAM
free -h

# Check disk space
df -h /var/lib
```

## Step 1: Add Secrets to SOPS

You need to add two new secrets to your encrypted secrets file. The OpenAI key already exists and will be reused.

### Generate Secrets

```bash
# Generate a random secret key for RAGFlow (64 characters)
openssl rand -hex 32

# Generate a random PostgreSQL password
openssl rand -base64 32
```

### Edit Secrets File

```bash
# From your nixos directory
cd /Users/francoisillien/nixos

# Edit the encrypted secrets file
sops secrets/secrets.yaml
```

Add these new lines to the file (SOPS will automatically encrypt them):

```yaml
tailscale_key: <existing>
openai_key: <existing>
xai_key: <existing>
ragflow_db_password: YOUR_GENERATED_POSTGRES_PASSWORD_HERE
ragflow_secret_key: YOUR_GENERATED_SECRET_KEY_HERE
```

Save and close the editor. SOPS will automatically encrypt the new values.

## Step 2: Verify Configuration

All configuration files have been created. Verify the structure:

```bash
cd /Users/francoisillien/nixos

# Check that all modules exist
ls -la modules/{postgresql,redis,elasticsearch,minio,ragflow,nginx}.nix

# Check server configuration
cat hosts/server/default.nix
```

## Step 3: Build and Test Locally (Optional but Recommended)

Before deploying to the server, test the configuration locally:

```bash
# Build the configuration (doesn't deploy)
nix build .#nixosConfigurations.server.config.system.build.toplevel

# If there are any syntax errors, they'll be caught here
```

## Step 4: Deploy to Server

Use deploy-rs to deploy the configuration:

```bash
# Deploy to the server
deploy .#server

# This will:
# 1. Build the configuration
# 2. Copy it to the server
# 3. Activate the new configuration
# 4. Start all services
```

The deployment will take 15-30 minutes depending on:
- Container image downloads (first time only)
- System compilation
- Service initialization

## Step 5: Monitor Deployment

SSH into your server and monitor the services:

```bash
# SSH to server
ssh admin@fillien-desktop

# Watch all RAGFlow-related services
watch 'systemctl status postgresql redis elasticsearch minio ragflow nginx'

# Check individual service logs
journalctl -u ragflow.service -f
journalctl -u elasticsearch.service -f
journalctl -u minio.service -f

# Check container status
podman ps -a

# Check if services are listening
ss -tlnp | grep -E '(5432|6379|9200|9000|9380|80)'
```

## Step 6: Verify Services are Running

### Check Service Status

```bash
# PostgreSQL
sudo -u postgres psql -c "SELECT version();"
sudo -u postgres psql -l | grep ragflow

# Redis
redis-cli ping

# Elasticsearch
curl http://localhost:9200/_cluster/health?pretty

# MinIO
curl http://localhost:9000/minio/health/live

# RAGFlow
curl http://localhost:9380/health
```

### Check Logs for Errors

```bash
# Check for any errors in services
journalctl -u postgresql -n 50 --no-pager | grep -i error
journalctl -u redis -n 50 --no-pager | grep -i error
journalctl -u elasticsearch -n 50 --no-pager | grep -i error
journalctl -u minio -n 50 --no-pager | grep -i error
journalctl -u ragflow -n 100 --no-pager | grep -i error
```

## Step 7: Access RAGFlow

### Find Your Tailscale IP

```bash
# On the server
tailscale ip -4
```

### Access the Web Interface

From any device connected to your Tailscale network:

```
http://<tailscale-ip>/
```

For example: `http://100.64.0.5/`

### Initial Setup

1. **Create Admin Account**: On first access, you'll be prompted to create an admin account
2. **Configure LLM Settings**:
   - Go to Settings → LLM Configuration
   - Verify OpenAI API key is configured
   - Select default models:
     - Chat model: `gpt-4` or `gpt-3.5-turbo`
     - Embedding model: `text-embedding-3-small`
3. **Test Document Upload**:
   - Upload a test document (PDF, Word, etc.)
   - Wait for processing
   - Try asking questions about the document

## Step 8: Ongoing Maintenance

### Storage Monitoring

```bash
# Check disk usage
df -h /var/lib/postgresql
df -h /var/lib/elasticsearch
df -h /var/lib/minio
df -h /var/lib/ragflow

# Set up alerts if space is low
```

### Log Rotation

Logs are automatically managed by systemd/journald. Configure retention:

```bash
# Check current journal size
journalctl --disk-usage

# Configure retention in /etc/systemd/journald.conf (via NixOS config)
# SystemMaxUse=5G
# MaxRetentionSec=1month
```

### Backups

Important data to backup:
- PostgreSQL database: `/var/lib/postgresql/`
- MinIO objects: `/var/lib/minio/`
- Elasticsearch indices: `/var/lib/elasticsearch/` (optional, can be rebuilt)

Example backup script:

```bash
# PostgreSQL backup
sudo -u postgres pg_dump ragflow > ragflow_backup_$(date +%Y%m%d).sql

# MinIO backup (use mc client or rsync)
rsync -av /var/lib/minio/ /backup/minio/
```

### Updates

To update RAGFlow or any services:

```bash
# Update container images
ssh admin@fillien-desktop
sudo podman pull docker.io/infiniflow/ragflow:latest
sudo systemctl restart ragflow

# Or update via NixOS configuration
# Edit modules/ragflow.nix to change version
# Then: deploy .#server
```

## Troubleshooting

### RAGFlow Container Won't Start

```bash
# Check dependencies
systemctl status postgresql redis elasticsearch minio

# Check logs
journalctl -u ragflow.service -n 100

# Common issues:
# - Database not ready: Wait 30s after PostgreSQL starts
# - Out of memory: Check available RAM
# - Port conflicts: Check if port 9380 is in use
```

### Elasticsearch Crashes or OOM

```bash
# Check memory usage
podman stats elasticsearch

# Elasticsearch needs at least 16GB RAM
# Check current heap size in modules/elasticsearch.nix
# ES_JAVA_OPTS=-Xms8g -Xmx8g

# Reduce if needed (minimum 4GB)
```

### Can't Access via Tailscale

```bash
# Check Tailscale status
tailscale status

# Check if Nginx is running
systemctl status nginx

# Check firewall
nft list ruleset | grep -E '(port 80|http)'

# Test locally first
curl http://localhost/
```

### MinIO Bucket Not Created

```bash
# Check minio-init service
systemctl status minio-init

# Manually create bucket
podman run --rm --network host \
  docker.io/minio/mc:latest \
  sh -c "
    mc alias set local http://localhost:9000 minioadmin minioadmin123 && \
    mc mb local/ragflow
  "
```

### PostgreSQL Connection Issues

```bash
# Check if RAGFlow user exists
sudo -u postgres psql -c "\du" | grep ragflow

# Check if database exists
sudo -u postgres psql -l | grep ragflow

# Test connection
sudo -u postgres psql -U ragflow -d ragflow -c "SELECT 1"
```

## Resource Usage Monitoring

### Set Up Monitoring Script

Create a monitoring script:

```bash
cat > /usr/local/bin/ragflow-monitor.sh << 'EOF'
#!/usr/bin/env bash

echo "=== RAGFlow System Status ==="
echo ""
echo "Services:"
systemctl is-active postgresql redis elasticsearch minio ragflow nginx | paste <(echo -e "PostgreSQL\nRedis\nElasticsearch\nMinIO\nRAGFlow\nNginx") -

echo ""
echo "Disk Usage:"
df -h /var/lib/postgresql /var/lib/elasticsearch /var/lib/minio /var/lib/ragflow | tail -n +2

echo ""
echo "Memory Usage:"
free -h | grep -E '(Mem|Swap)'

echo ""
echo "Container Status:"
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF

chmod +x /usr/local/bin/ragflow-monitor.sh
```

Run it:

```bash
/usr/local/bin/ragflow-monitor.sh
```

## Security Considerations

1. **Tailscale Only**: RAGFlow is only accessible via Tailscale VPN
2. **No Public Exposure**: No ports open to the internet except SSH
3. **Secrets Management**: All credentials encrypted with SOPS/Age
4. **Container Isolation**: Services run in isolated Podman containers
5. **Minimal Permissions**: Service users have minimal required permissions

## Performance Tuning

### PostgreSQL

Edit `modules/postgresql.nix` to adjust:
- `shared_buffers`: 25% of RAM
- `effective_cache_size`: 50-75% of RAM
- `work_mem`: Depends on query complexity

### Elasticsearch

Edit `modules/elasticsearch.nix`:
- Heap size: 50% of RAM, max 32GB
- For 64GB server: `-Xms16g -Xmx16g`

### RAGFlow Workers

If you need more parallel processing, you can add worker containers by creating additional systemd services.

## Getting Help

- **RAGFlow Docs**: https://github.com/infiniflow/ragflow
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Check Logs**: Always start with `journalctl -u <service> -n 100`

## Summary

Your RAGFlow deployment includes:
- ✅ 6 new NixOS modules created
- ✅ Centralized secrets management (SOPS)
- ✅ Automatic dependency management (systemd)
- ✅ Tailscale-only access (secure)
- ✅ Persistent storage for all services
- ✅ Automatic container restart on failure
- ✅ Integrated with existing infrastructure (ArangoDB preserved)

Access URL: `http://<tailscale-ip>/`

Happy RAG-ing! 🚀
