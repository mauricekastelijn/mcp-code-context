# MILVUS Setup Guide

This guide provides detailed information about setting up MILVUS locally using Docker.

## What is MILVUS?

MILVUS is an open-source vector database built for AI applications. It stores and indexes the embeddings of your code, enabling semantic search.

**Key Features:**
- 🚀 High-performance vector search
- 💾 Persistent storage
- 🔍 Hybrid search (dense + sparse vectors)
- 📈 Scalable architecture

## Architecture

The local MILVUS setup includes three containers:

```
┌─────────────────────────────────────┐
│   MILVUS Standalone                 │
│   (Main Service)                    │
│   Port: 19530                       │
└────────┬────────────┬───────────────┘
         │            │
         ▼            ▼
    ┌────────┐   ┌────────┐
    │  etcd  │   │ MinIO  │
    │ (Meta) │   │ (Data) │
    └────────┘   └────────┘
```

### Components

1. **MILVUS Standalone** - Main vector database service
   - Port: 19530 (gRPC)
   - Health check: 9091

2. **etcd** - Metadata storage
   - Stores collection schemas, index information
   - Internal service (not exposed)

3. **MinIO** - Object storage
   - Stores vector data files
   - Web UI: http://127.0.0.1:9001
   - Credentials: minioadmin/minioadmin

## Automated Setup

### Windows

```powershell
.\setup-windows.ps1
```

### Linux/Mac

```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

The automated setup will:
1. Start all MILVUS components
2. Wait for services to be healthy
3. Verify connectivity

## Manual Setup

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- At least 2GB disk space

### Step 1: Start Services

```bash
docker-compose up -d etcd minio milvus
```

### Step 2: Wait for Services

```bash
# Check container status
docker ps

# Check health status
docker inspect --format='{{.State.Health.Status}}' milvus-standalone

# Wait for "healthy" status
```

### Step 3: Verify Connection

**Check MILVUS health:**
```bash
curl http://127.0.0.1:9091/healthz
```

**Access MinIO Web UI:**
- URL: http://127.0.0.1:9001
- Username: minioadmin
- Password: minioadmin

## Configuration

### Default Configuration

The default configuration is suitable for development:

```yaml
milvus:
  image: milvusdb/milvus:v2.4.0
  ports:
    - "19530:19530"  # gRPC API
    - "9091:9091"    # HTTP health check
```

### Custom Configuration

To customize MILVUS, create a config file:

**1. Create `milvus.yaml`:**

```yaml
# milvus.yaml
etcd:
  endpoints:
    - etcd:2379
minio:
  address: minio:9000
  accessKeyID: minioadmin
  secretAccessKey: minioadmin
  bucketName: milvus-bucket
common:
  storageType: minio
```

**2. Mount the config in docker-compose.yml:**

```yaml
milvus:
  volumes:
    - milvus_data:/var/lib/milvus
    - ./milvus.yaml:/milvus/configs/milvus.yaml
```

### Environment Variables

You can configure MILVUS using environment variables:

```yaml
milvus:
  environment:
    - MILVUS_CONFIG_PATH=/milvus/configs/milvus.yaml
    - LOG_LEVEL=info
```

## Data Management

### Storage Locations

**MILVUS data:**
```bash
# Volume name
mcp-code-context_milvus_data

# Inspect volume
docker volume inspect mcp-code-context_milvus_data
```

**etcd data:**
```bash
mcp-code-context_milvus_etcd
```

**MinIO data:**
```bash
mcp-code-context_milvus_minio
```

### Backup Data

**1. Stop services:**
```bash
docker-compose down
```

**2. Backup volumes:**

**Windows (PowerShell):**
```powershell
docker run --rm -v mcp-code-context_milvus_data:/data -v ${PWD}/backup:/backup ubuntu tar czf /backup/milvus-data.tar.gz /data
docker run --rm -v mcp-code-context_milvus_etcd:/data -v ${PWD}/backup:/backup ubuntu tar czf /backup/milvus-etcd.tar.gz /data
docker run --rm -v mcp-code-context_milvus_minio:/data -v ${PWD}/backup:/backup ubuntu tar czf /backup/milvus-minio.tar.gz /data
```

**Linux/Mac:**
```bash
mkdir -p backup
docker run --rm -v mcp-code-context_milvus_data:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/milvus-data.tar.gz /data
docker run --rm -v mcp-code-context_milvus_etcd:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/milvus-etcd.tar.gz /data
docker run --rm -v mcp-code-context_milvus_minio:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/milvus-minio.tar.gz /data
```

**3. Restart services:**
```bash
docker-compose up -d
```

### Restore from Backup

**1. Stop services:**
```bash
docker-compose down
```

**2. Remove existing volumes:**
```bash
docker volume rm mcp-code-context_milvus_data
docker volume rm mcp-code-context_milvus_etcd
docker volume rm mcp-code-context_milvus_minio
```

**3. Restore volumes:**

**Windows (PowerShell):**
```powershell
docker volume create mcp-code-context_milvus_data
docker volume create mcp-code-context_milvus_etcd
docker volume create mcp-code-context_milvus_minio

docker run --rm -v mcp-code-context_milvus_data:/data -v ${PWD}/backup:/backup ubuntu tar xzf /backup/milvus-data.tar.gz -C /
docker run --rm -v mcp-code-context_milvus_etcd:/data -v ${PWD}/backup:/backup ubuntu tar xzf /backup/milvus-etcd.tar.gz -C /
docker run --rm -v mcp-code-context_milvus_minio:/data -v ${PWD}/backup:/backup ubuntu tar xzf /backup/milvus-minio.tar.gz -C /
```

**Linux/Mac:**
```bash
docker volume create mcp-code-context_milvus_data
docker volume create mcp-code-context_milvus_etcd
docker volume create mcp-code-context_milvus_minio

docker run --rm -v mcp-code-context_milvus_data:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/milvus-data.tar.gz -C /
docker run --rm -v mcp-code-context_milvus_etcd:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/milvus-etcd.tar.gz -C /
docker run --rm -v mcp-code-context_milvus_minio:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/milvus-minio.tar.gz -C /
```

**4. Restart services:**
```bash
docker-compose up -d
```

### Clear All Data

To start fresh without backups:

```bash
docker-compose down -v
docker-compose up -d
```

## Monitoring

### View Logs

```bash
# All MILVUS logs
docker-compose logs -f milvus

# etcd logs
docker-compose logs -f etcd

# MinIO logs
docker-compose logs -f minio

# All logs
docker-compose logs -f
```

### Check Resource Usage

```bash
# Container stats
docker stats milvus-standalone milvus-etcd milvus-minio

# Disk usage
docker exec milvus-standalone df -h
```

### MinIO Web Interface

Access MinIO at http://127.0.0.1:9001

**View stored data:**
1. Login with minioadmin/minioadmin
2. Browse the `milvus-bucket`
3. View vector data files

## Troubleshooting

### Container Won't Start

**Check if port is in use:**
```bash
# Windows
netstat -ano | findstr "19530"

# Linux/Mac
lsof -i :19530
```

**View error logs:**
```bash
docker-compose logs milvus
```

**Common issues:**
- Insufficient memory (needs at least 2GB)
- Port conflict
- Corrupted volume

### Connection Refused

**Verify service is healthy:**
```bash
docker inspect --format='{{.State.Health.Status}}' milvus-standalone
```

**Check if port is exposed:**
```bash
docker port milvus-standalone
```

**Test connection:**
```bash
curl http://127.0.0.1:9091/healthz
```

### Slow Performance

**Increase resources:**
- Docker Desktop → Settings → Resources
- Allocate more memory (8GB recommended)
- Allocate more CPUs (4+ recommended)

**Check disk space:**
```bash
docker exec milvus-standalone df -h
```

### Data Corruption

**Reset MILVUS:**
```bash
docker-compose down -v
docker-compose up -d
```

**Then re-index your codebase.**

### etcd or MinIO Issues

**Restart specific service:**
```bash
docker-compose restart etcd
docker-compose restart minio
docker-compose restart milvus
```

**Check service logs:**
```bash
docker-compose logs etcd
docker-compose logs minio
```

## Advanced Topics

### Using MILVUS Cloud Instead

If you prefer cloud hosting:

1. Sign up at [Zilliz Cloud](https://cloud.zilliz.com/)
2. Get your API key
3. Update MCP config:

```json
{
  "MILVUS_ADDRESS": "your-endpoint.zilliz.com:19530",
  "MILVUS_TOKEN": "your-api-key"
}
```

4. Remove local MILVUS from docker-compose.yml

### Scaling MILVUS

For production use, consider:
- MILVUS cluster mode (multiple nodes)
- External etcd cluster
- S3 instead of MinIO
- Load balancing

See [MILVUS documentation](https://milvus.io/docs) for details.

### Performance Tuning

**Optimize index settings:**
- Use appropriate index types
- Adjust index parameters
- Monitor query performance

**Resource allocation:**
- More memory = faster queries
- More CPUs = faster indexing
- SSD storage = better I/O

## Resources

- [MILVUS Official Documentation](https://milvus.io/docs)
- [MILVUS GitHub](https://github.com/milvus-io/milvus)
- [Zilliz Cloud](https://cloud.zilliz.com/)
- [MinIO Documentation](https://min.io/docs/)

## Next Steps

- [Configure Ollama](./OLLAMA_SETUP.md)
- [Configure VS Code](../VSCODE_SETUP.md)
- [Start Using the MCP](../USAGE.md)
