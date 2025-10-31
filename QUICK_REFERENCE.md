# Quick Reference Guide

## Setup Commands

### Initial Setup

**Windows:**
```powershell
.\setup-windows.ps1
```

**Linux/Mac:**
```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

### Cleanup

**Windows:**
```powershell
.\cleanup-windows.ps1
```

**Linux/Mac:**
```bash
./cleanup-linux.sh
```

## Docker Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Stop and Remove All Data
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f milvus
docker-compose logs -f ollama
```

### Restart Services
```bash
docker-compose restart
```

### Check Status
```bash
docker-compose ps
```

### Check Resource Usage
```bash
docker stats
```

## Ollama Commands

### List Models
```bash
docker exec ollama ollama list
```

### Download Model
```bash
docker exec ollama ollama pull nomic-embed-text
```

### Remove Model
```bash
docker exec ollama ollama rm nomic-embed-text
```

### Show Model Info
```bash
docker exec ollama ollama show nomic-embed-text
```

## MILVUS Commands

### Check Health
```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri "http://127.0.0.1:9091/healthz"

# Linux/Mac
curl http://127.0.0.1:9091/healthz
```

### Access MinIO UI
```
http://127.0.0.1:9001
Username: minioadmin
Password: minioadmin
```

## MCP Usage

### Index Codebase
```
Index this codebase
```

### Check Status
```
Check the indexing status
```

### Search Code
```
Find functions that handle authentication
Show me API endpoints
Search for error handling code
```

### Clear Index
```
Clear the index for this codebase
```

## VS Code MCP Configuration

**Location:** Settings → Edit settings.json

```json
{
  "mcpServers": {
    "claude-context": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "EMBEDDING_PROVIDER": "Ollama",
        "MILVUS_ADDRESS": "127.0.0.1:19530",
        "OLLAMA_HOST": "http://127.0.0.1:11434",
        "OLLAMA_MODEL": "nomic-embed-text"
      }
    }
  }
}
```

## Service Endpoints

| Service | Endpoint | Credentials |
|---------|----------|-------------|
| MILVUS gRPC | 127.0.0.1:19530 | - |
| MILVUS Health | http://127.0.0.1:9091/healthz | - |
| Ollama API | http://127.0.0.1:11434 | - |
| MinIO Web | http://127.0.0.1:9001 | minioadmin/minioadmin |
| MinIO API | http://127.0.0.1:9000 | minioadmin/minioadmin |

## Troubleshooting

### Services Won't Start
```bash
# Check if ports are in use
netstat -ano | findstr "19530 11434"  # Windows
lsof -i :19530,11434                  # Linux/Mac

# View detailed logs
docker-compose logs

# Reset everything
docker-compose down -v
docker-compose up -d
```

### Model Not Found
```bash
docker exec ollama ollama pull nomic-embed-text
```

### Connection Issues
```bash
# Check services are running
docker-compose ps

# Check health
docker inspect --format='{{.State.Health.Status}}' milvus-standalone
docker inspect --format='{{.State.Health.Status}}' ollama
```

### Node.js Version Issues
```bash
# Check version
node --version

# Install correct version (must be >= 20 and < 24)
nvm install 20
nvm use 20
```

## File Locations

### Configuration Files
- Main config: `docker-compose.yml`
- VS Code settings: See [VSCODE_SETUP.md](./VSCODE_SETUP.md)

### Docker Volumes
- MILVUS data: `mcp-code-context_milvus_data`
- Ollama models: `mcp-code-context_ollama_data`
- etcd data: `mcp-code-context_milvus_etcd`
- MinIO data: `mcp-code-context_milvus_minio`

### Documentation
- Main README: [README.md](./README.md)
- VS Code Setup: [VSCODE_SETUP.md](./VSCODE_SETUP.md)
- Usage Guide: [USAGE.md](./USAGE.md)
- MILVUS Setup: [docs/MILVUS_SETUP.md](./docs/MILVUS_SETUP.md)
- Ollama Setup: [docs/OLLAMA_SETUP.md](./docs/OLLAMA_SETUP.md)
- Configuration: [docs/CONFIGURATION.md](./docs/CONFIGURATION.md)
- Troubleshooting: [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)

## Backup & Restore

### Backup All Data
```bash
docker-compose down
mkdir -p backup

# Backup MILVUS
docker run --rm -v mcp-code-context_milvus_data:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/milvus-data.tar.gz /data

# Backup Ollama models
docker run --rm -v mcp-code-context_ollama_data:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/ollama-data.tar.gz /data

docker-compose up -d
```

### Restore Data
```bash
docker-compose down
docker volume rm mcp-code-context_milvus_data
docker volume rm mcp-code-context_ollama_data

docker volume create mcp-code-context_milvus_data
docker volume create mcp-code-context_ollama_data

docker run --rm -v mcp-code-context_milvus_data:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/milvus-data.tar.gz -C /
docker run --rm -v mcp-code-context_ollama_data:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/ollama-data.tar.gz -C /

docker-compose up -d
```

## Performance Tips

### For Faster Indexing
```json
{
  "HYBRID_MODE": "false",
  "EMBEDDING_BATCH_SIZE": "500"
}
```

### For Better Accuracy
```json
{
  "HYBRID_MODE": "true",
  "OLLAMA_MODEL": "mxbai-embed-large"
}
```

### For Limited Memory
```json
{
  "EMBEDDING_BATCH_SIZE": "50",
  "OLLAMA_MODEL": "all-minilm"
}
```

## Common File Patterns to Exclude

```json
{
  "CUSTOM_IGNORE_PATTERNS": "node_modules/**,dist/**,build/**,coverage/**,*.min.js,*.map,*.lock,package-lock.json"
}
```

## Resource Requirements

### Minimum
- **RAM:** 8GB
- **Disk:** 4GB
- **CPU:** 4 cores

### Recommended
- **RAM:** 12GB+
- **Disk:** 10GB+
- **CPU:** 6+ cores

## Quick Health Check

Run this to verify everything is working:

```bash
# Check containers
docker-compose ps

# Test MILVUS
curl http://127.0.0.1:9091/healthz

# Test Ollama
curl http://127.0.0.1:11434/api/tags

# Check models
docker exec ollama ollama list
```

Expected output: All containers running, both health checks return 200 OK, nomic-embed-text model listed.

## Getting Help

1. Check [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
2. Review [Documentation](#file-locations)
3. Check [Claude Context Issues](https://github.com/zilliztech/claude-context/issues)
