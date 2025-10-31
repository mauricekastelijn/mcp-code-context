# Troubleshooting Guide

This guide covers common issues and their solutions when using the Claude Context MCP setup.

## Quick Diagnostics

Run these commands to check the health of your setup:

### Check Services

```bash
# Check running containers
docker ps

# Check container health
docker inspect --format='{{.State.Health.Status}}' milvus-standalone
docker inspect --format='{{.State.Health.Status}}' ollama

# Check all containers
docker-compose ps
```

### Check Connectivity

**MILVUS:**
```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri "http://127.0.0.1:9091/healthz"

# Linux/Mac
curl http://127.0.0.1:9091/healthz
```

**Ollama:**
```bash
# Windows (PowerShell)
Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags"

# Linux/Mac
curl http://127.0.0.1:11434/api/tags
```

### Check Logs

```bash
# All logs
docker-compose logs

# Specific service
docker-compose logs milvus
docker-compose logs ollama

# Follow logs
docker-compose logs -f
```

## Common Issues

### 1. Services Won't Start

#### Symptoms
- Docker containers fail to start
- Health checks never complete
- Containers restart repeatedly

#### Diagnosis

```bash
# Check container status
docker-compose ps

# View error logs
docker-compose logs
```

#### Solutions

**Port conflicts:**
```bash
# Windows
netstat -ano | findstr "19530 11434 9001"

# Linux/Mac
lsof -i :19530
lsof -i :11434
lsof -i :9001
```

If ports are in use, either:
1. Stop the conflicting service
2. Change ports in `docker-compose.yml`

**Insufficient resources:**
- Open Docker Desktop → Settings → Resources
- Increase Memory to at least 8GB
- Increase CPUs to at least 4

**Corrupted containers:**
```bash
# Remove and recreate
docker-compose down -v
docker-compose up -d
```

### 2. MCP Server Won't Start

#### Symptoms
- VS Code shows MCP server error
- Server crashes immediately
- Connection refused errors

#### Diagnosis

Check VS Code Output panel:
- View → Output
- Select "MCP: claude-context" from dropdown

#### Solutions

**Wrong Node.js version:**
```bash
node --version
```

Must be >= 20.0.0 and < 24.0.0

**Install correct version:**

**Windows (using nvm-windows):**
```bash
nvm install 20.17.0
nvm use 20.17.0
```

**Linux/Mac (using nvm):**
```bash
nvm install 20
nvm use 20
```

**Invalid configuration:**

Check your VS Code settings.json:
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

**Services not running:**
```bash
docker-compose up -d
```

### 3. Indexing Fails

#### Symptoms
- Indexing starts but never completes
- Error during indexing
- No files are indexed

#### Diagnosis

```bash
# Check Ollama has the model
docker exec ollama ollama list

# Check MILVUS is accessible
curl http://127.0.0.1:9091/healthz

# Check disk space
docker exec milvus-standalone df -h
```

#### Solutions

**Model not found:**
```bash
docker exec ollama ollama pull nomic-embed-text
```

**Insufficient disk space:**
```bash
# Check available space
docker system df

# Clean up
docker system prune -a --volumes
```

**Large files causing issues:**

Add exclusions in MCP config:
```json
{
  "CUSTOM_IGNORE_PATTERNS": "*.bin,*.so,*.dll,*.exe,*.zip"
}
```

**Network connectivity:**
```bash
# Ensure containers can communicate
docker network inspect mcp-code-context_milvus
```

### 4. Search Returns No Results

#### Symptoms
- Search completes but returns nothing
- Wrong results returned
- Incomplete results

#### Diagnosis

```bash
# Check indexing completed
# Ask Claude: "Check the indexing status"

# Verify data in MILVUS
docker exec milvus-standalone ls -lh /var/lib/milvus
```

#### Solutions

**Indexing didn't complete:**
```
Index this codebase
```

**Wrong project indexed:**
- Check you're in the correct directory
- Clear and re-index:
```
Clear the index
Index this codebase
```

**Query too specific:**
- Try broader queries
- Use different terminology

**Index corrupted:**
```bash
# Reset MILVUS
docker-compose restart milvus

# Re-index
```

### 5. Slow Performance

#### Symptoms
- Indexing takes very long
- Search is slow
- System becomes unresponsive

#### Diagnosis

```bash
# Check resource usage
docker stats

# Check CPU and memory
docker stats --no-stream
```

#### Solutions

**Allocate more resources:**
- Docker Desktop → Settings → Resources
- Increase Memory to 12GB+
- Increase CPUs to 6+

**Reduce batch size:**
```json
{
  "EMBEDDING_BATCH_SIZE": "50"
}
```

**Exclude large directories:**
```json
{
  "CUSTOM_IGNORE_PATTERNS": "node_modules/**,dist/**,build/**"
}
```

**Use dense-only mode:**
```json
{
  "HYBRID_MODE": "false"
}
```

### 6. Connection Errors

#### Symptoms
- "Connection refused"
- "ECONNREFUSED"
- "Cannot connect to MILVUS"

#### Diagnosis

```bash
# Check if containers are running
docker ps

# Check container health
docker inspect milvus-standalone --format='{{.State.Health}}'

# Test connectivity
curl http://127.0.0.1:9091/healthz
curl http://127.0.0.1:11434/api/tags
```

#### Solutions

**Services not started:**
```bash
docker-compose up -d
```

**Wrong host/port in config:**

Ensure config has:
```json
{
  "MILVUS_ADDRESS": "127.0.0.1:19530",
  "OLLAMA_HOST": "http://127.0.0.1:11434"
}
```

**Firewall blocking:**
- Windows: Allow Docker in Windows Firewall
- Linux: Check `iptables` rules

**Docker networking issues:**
```bash
# Recreate network
docker-compose down
docker-compose up -d
```

### 7. Out of Memory

#### Symptoms
- Containers crash
- System becomes slow
- "Out of memory" errors

#### Diagnosis

```bash
# Check memory usage
docker stats --no-stream

# Check available memory
free -h  # Linux
```

#### Solutions

**Increase Docker memory:**
- Docker Desktop → Settings → Resources
- Set to at least 8GB (12GB+ recommended)

**Reduce batch size:**
```json
{
  "EMBEDDING_BATCH_SIZE": "50"
}
```

**Close other applications**

**Restart services:**
```bash
docker-compose restart
```

**Reduce model cache time:**
```yaml
ollama:
  environment:
    - OLLAMA_KEEP_ALIVE=5m
```

### 8. Data Loss

#### Symptoms
- Previously indexed codebases are gone
- Need to re-index everything

#### Diagnosis

```bash
# Check if volumes exist
docker volume ls | grep mcp-code-context

# Check volume data
docker volume inspect mcp-code-context_milvus_data
```

#### Solutions

**Volumes were removed:**

If you ran `docker-compose down -v`, volumes are deleted.

**Restore from backup:**
```bash
# See docs/MILVUS_SETUP.md for backup/restore instructions
```

**Prevent data loss:**
- Never use `docker-compose down -v` unless intentional
- Regular backups
- Use named volumes

### 9. Model Download Issues

#### Symptoms
- "Model not found"
- Download fails or hangs
- Partial download

#### Diagnosis

```bash
# Check downloaded models
docker exec ollama ollama list

# Check disk space
docker exec ollama df -h

# Check network
docker exec ollama curl -I https://ollama.ai
```

#### Solutions

**Network issues:**
- Check internet connection
- Try again later
- Use VPN if blocked

**Disk space:**
```bash
# Clean up
docker system prune -a
```

**Corrupted download:**
```bash
# Remove and re-download
docker exec ollama ollama rm nomic-embed-text
docker exec ollama ollama pull nomic-embed-text
```

### 10. VS Code Integration Issues

#### Symptoms
- MCP tools don't appear
- VS Code doesn't recognize MCP server
- Configuration not working

#### Diagnosis

1. Open VS Code Output panel
2. Select "MCP: claude-context"
3. Look for errors

#### Solutions

**Configuration not loaded:**
- Restart VS Code
- Developer: Reload Window (Ctrl+Shift+P)

**Wrong settings.json location:**

**Windows:**
```
%APPDATA%\Code\User\settings.json
```

**Linux/Mac:**
```
~/.config/Code/User/settings.json
```

**Syntax error in JSON:**

Validate your JSON at https://jsonlint.com/

**Extension conflicts:**
- Disable other MCP extensions
- Try in a clean VS Code profile

## Platform-Specific Issues

### Windows

**WSL 2 issues:**
```powershell
# Update WSL
wsl --update

# Set WSL 2 as default
wsl --set-default-version 2
```

**Docker Desktop issues:**
- Ensure WSL 2 integration is enabled
- Settings → Resources → WSL Integration

**Path issues:**
- Use forward slashes in paths
- Or double backslashes: `C:\\path\\to\\project`

### Linux

**Permission denied:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
```

**SELinux issues:**
```bash
# Check if SELinux is enforcing
getenforce

# If needed, set to permissive (temporary)
sudo setenforce 0
```

**Systemd issues:**
```bash
# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
```

### macOS

**Docker Desktop memory:**
- Increase in Settings → Resources → Memory
- Minimum 8GB, recommend 12GB+

**Performance:**
- Enable VirtioFS in Docker Desktop
- Use native Apple Silicon image if on M1/M2

## Reset Everything

If all else fails, complete reset:

### Windows

```powershell
# Stop services
docker-compose down -v

# Remove all Docker data
docker system prune -a --volumes

# Restart Docker Desktop

# Setup again
.\setup-windows.ps1
```

### Linux/Mac

```bash
# Stop services
docker-compose down -v

# Remove all Docker data
docker system prune -a --volumes

# Restart Docker
sudo systemctl restart docker

# Setup again
./setup-linux.sh
```

## Getting Help

### Collect Debug Information

Before asking for help, collect:

```bash
# System info
docker version
docker-compose version
node --version

# Container status
docker-compose ps

# Logs
docker-compose logs > debug-logs.txt

# Resource usage
docker stats --no-stream > debug-stats.txt
```

### Where to Get Help

1. **Check documentation:**
   - This troubleshooting guide
   - [MILVUS Setup](./MILVUS_SETUP.md)
   - [Ollama Setup](./OLLAMA_SETUP.md)

2. **Upstream issues:**
   - [Claude Context GitHub](https://github.com/zilliztech/claude-context/issues)
   - [MILVUS GitHub](https://github.com/milvus-io/milvus/issues)
   - [Ollama GitHub](https://github.com/ollama/ollama/issues)

3. **Community:**
   - MILVUS Discord
   - Ollama Discord

## Prevention

### Best Practices

1. **Regular backups**
   ```bash
   # Weekly backup script
   ./backup.sh
   ```

2. **Monitor resources**
   ```bash
   docker stats
   ```

3. **Keep logs**
   ```bash
   docker-compose logs > logs/$(date +%Y%m%d).log
   ```

4. **Update regularly**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

5. **Don't use `-v` flag** unless you want to delete data:
   ```bash
   # ❌ This deletes all data
   docker-compose down -v
   
   # ✅ This keeps data
   docker-compose down
   ```

## Appendix: Common Error Messages

### "Cannot connect to the Docker daemon"

**Cause:** Docker is not running

**Solution:**
- Windows: Start Docker Desktop
- Linux: `sudo systemctl start docker`

### "port is already allocated"

**Cause:** Port is in use by another service

**Solution:**
- Find and stop conflicting service
- Or change port in docker-compose.yml

### "no space left on device"

**Cause:** Disk full

**Solution:**
```bash
docker system prune -a --volumes
```

### "Ollama model not found"

**Cause:** Model not downloaded

**Solution:**
```bash
docker exec ollama ollama pull nomic-embed-text
```

### "MILVUS collection not found"

**Cause:** Codebase not indexed

**Solution:**
```
Index this codebase
```

### "Node version incompatible"

**Cause:** Wrong Node.js version

**Solution:**
```bash
nvm install 20
nvm use 20
```

## Need More Help?

If your issue isn't covered here:

1. Search the [Claude Context issues](https://github.com/zilliztech/claude-context/issues)
2. Create a new issue with:
   - Your OS and versions
   - Error messages
   - Steps to reproduce
   - Logs (sanitize sensitive data)
