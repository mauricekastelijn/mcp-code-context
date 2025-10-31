# Ollama Setup Guide

This guide provides detailed information about setting up Ollama locally using Docker.

## What is Ollama?

Ollama is a tool for running large language models locally. In this setup, it provides the embedding model (`nomic-embed-text`) that converts code into vector embeddings.

**Key Features:**
- 🚀 Fast local inference
- 🔒 Privacy-focused (no data leaves your machine)
- 💾 Model management
- 🔄 Multiple model support

## Why nomic-embed-text?

The `nomic-embed-text` model is specifically designed for text embeddings:
- **Size:** ~274MB (lightweight)
- **Dimension:** 768 dimensions
- **Speed:** Fast inference
- **Quality:** Excellent for code and text
- **Context Length:** 8192 tokens

## Architecture

```
┌─────────────────────────────┐
│   Ollama Container          │
│                             │
│   ┌─────────────────────┐  │
│   │  nomic-embed-text   │  │
│   │  (Embedding Model)  │  │
│   └─────────────────────┘  │
│                             │
│   HTTP API: :11434          │
└─────────────────────────────┘
```

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
1. Start Ollama container
2. Download `nomic-embed-text` model
3. Verify the model is available

## Manual Setup

### Prerequisites

- Docker installed
- At least 2GB RAM available
- At least 2GB disk space

### Step 1: Start Ollama

```bash
docker-compose up -d ollama
```

### Step 2: Download Model

```bash
docker exec ollama ollama pull nomic-embed-text
```

**Expected output:**
```
pulling manifest
pulling 970aa74c0a90... 100% ▕████████████████▏ 274 MB
pulling c71d239df917... 100% ▕████████████████▏  11 KB
pulling ce4a164fc046... 100% ▕████████████████▏   17 B
pulling 31df60cc282f... 100% ▕████████████████▏  420 B
verifying sha256 digest
writing manifest
success
```

### Step 3: Verify Model

```bash
docker exec ollama ollama list
```

**Expected output:**
```
NAME                    ID              SIZE      MODIFIED
nomic-embed-text:latest abc12345678     274 MB    2 minutes ago
```

### Step 4: Test Embedding

```bash
curl http://127.0.0.1:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "Hello, world!"
}'
```

**Expected output:**
```json
{
  "embedding": [0.123, -0.456, 0.789, ...]
}
```

## Configuration

### Default Configuration

The default configuration in `docker-compose.yml`:

```yaml
ollama:
  container_name: ollama
  image: ollama/ollama:latest
  ports:
    - "11434:11434"
  volumes:
    - ollama_data:/root/.ollama
  environment:
    - OLLAMA_KEEP_ALIVE=24h
    - OLLAMA_HOST=0.0.0.0
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_KEEP_ALIVE` | `5m` | How long to keep models in memory |
| `OLLAMA_HOST` | `127.0.0.1` | Host to bind to |
| `OLLAMA_ORIGINS` | `*` | CORS origins |
| `OLLAMA_NUM_PARALLEL` | `1` | Number of parallel requests |

### Custom Configuration

**Keep models loaded longer:**
```yaml
ollama:
  environment:
    - OLLAMA_KEEP_ALIVE=24h  # Keep for 24 hours
```

**Allow more parallel requests:**
```yaml
ollama:
  environment:
    - OLLAMA_NUM_PARALLEL=4  # Process 4 requests simultaneously
```

## Using Different Models

### Available Embedding Models

You can use other embedding models:

| Model | Size | Dimensions | Best For |
|-------|------|------------|----------|
| `nomic-embed-text` | 274MB | 768 | General text (recommended) |
| `mxbai-embed-large` | 669MB | 1024 | High-quality embeddings |
| `all-minilm` | 46MB | 384 | Small, fast |

### Download Additional Models

```bash
docker exec ollama ollama pull mxbai-embed-large
```

### Switch Models

Update your MCP configuration:

```json
{
  "OLLAMA_MODEL": "mxbai-embed-large"
}
```

Then restart VS Code.

### List Downloaded Models

```bash
docker exec ollama ollama list
```

### Remove Models

```bash
docker exec ollama ollama rm nomic-embed-text
```

## Data Management

### Storage Location

**Model data:**
```bash
# Volume name
mcp-code-context_ollama_data

# Inspect volume
docker volume inspect mcp-code-context_ollama_data
```

**Model files location inside container:**
```
/root/.ollama/models/
```

### Backup Models

**1. Stop services:**
```bash
docker-compose down
```

**2. Backup volume:**

**Windows (PowerShell):**
```powershell
docker run --rm -v mcp-code-context_ollama_data:/data -v ${PWD}/backup:/backup ubuntu tar czf /backup/ollama-data.tar.gz /data
```

**Linux/Mac:**
```bash
mkdir -p backup
docker run --rm -v mcp-code-context_ollama_data:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/ollama-data.tar.gz /data
```

**3. Restart services:**
```bash
docker-compose up -d
```

### Restore Models

**1. Stop services:**
```bash
docker-compose down
```

**2. Remove existing volume:**
```bash
docker volume rm mcp-code-context_ollama_data
```

**3. Restore volume:**

**Windows (PowerShell):**
```powershell
docker volume create mcp-code-context_ollama_data
docker run --rm -v mcp-code-context_ollama_data:/data -v ${PWD}/backup:/backup ubuntu tar xzf /backup/ollama-data.tar.gz -C /
```

**Linux/Mac:**
```bash
docker volume create mcp-code-context_ollama_data
docker run --rm -v mcp-code-context_ollama_data:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/ollama-data.tar.gz -C /
```

**4. Restart services:**
```bash
docker-compose up -d
```

### Clear All Models

To remove all downloaded models:

```bash
docker exec ollama sh -c "rm -rf /root/.ollama/models/*"
```

Or remove the volume:

```bash
docker-compose down
docker volume rm mcp-code-context_ollama_data
docker-compose up -d
```

## Monitoring

### View Logs

```bash
docker-compose logs -f ollama
```

### Check Resource Usage

```bash
docker stats ollama
```

### API Endpoints

**List models:**
```bash
curl http://127.0.0.1:11434/api/tags
```

**Show model info:**
```bash
curl http://127.0.0.1:11434/api/show -d '{
  "name": "nomic-embed-text"
}'
```

**Generate embeddings:**
```bash
curl http://127.0.0.1:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "Your text here"
}'
```

## Performance Optimization

### GPU Support

If you have an NVIDIA GPU:

**1. Install NVIDIA Container Toolkit:**

**Linux:**
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

**2. Update docker-compose.yml:**

```yaml
ollama:
  image: ollama/ollama:latest
  runtime: nvidia  # Add this
  environment:
    - NVIDIA_VISIBLE_DEVICES=all
```

**3. Restart services:**
```bash
docker-compose down
docker-compose up -d
```

### CPU Optimization

**Allocate more CPUs:**

In Docker Desktop:
- Settings → Resources → CPUs
- Increase to 4+ CPUs

**Or in docker-compose.yml:**
```yaml
ollama:
  cpus: 4
  mem_limit: 4g
```

### Memory Management

**Keep models in memory longer:**
```yaml
ollama:
  environment:
    - OLLAMA_KEEP_ALIVE=24h
```

**Allocate more memory:**
```yaml
ollama:
  mem_limit: 4g
```

## Troubleshooting

### Model Download Fails

**Check internet connection:**
```bash
docker exec ollama curl -I https://ollama.ai
```

**Check disk space:**
```bash
docker exec ollama df -h
```

**Retry download:**
```bash
docker exec ollama ollama pull nomic-embed-text
```

### Connection Refused

**Check if container is running:**
```bash
docker ps | grep ollama
```

**Check if port is accessible:**
```bash
curl http://127.0.0.1:11434/api/tags
```

**Restart container:**
```bash
docker-compose restart ollama
```

### Slow Embedding Generation

**Check CPU usage:**
```bash
docker stats ollama
```

**Possible solutions:**
- Use GPU acceleration
- Allocate more CPUs
- Use a smaller model
- Increase `OLLAMA_NUM_PARALLEL`

### Out of Memory

**Check memory usage:**
```bash
docker stats ollama
```

**Solutions:**
- Increase Docker memory limit
- Use a smaller model
- Reduce `OLLAMA_NUM_PARALLEL`
- Set shorter `OLLAMA_KEEP_ALIVE`

### Model Not Found

**List available models:**
```bash
docker exec ollama ollama list
```

**Download model:**
```bash
docker exec ollama ollama pull nomic-embed-text
```

**Check model name in config:**
Ensure `OLLAMA_MODEL` matches exactly.

## Advanced Topics

### Using Remote Ollama

To use Ollama running on another machine:

**1. Update docker-compose.yml:**
```yaml
# Comment out or remove ollama service
```

**2. Update MCP config:**
```json
{
  "OLLAMA_HOST": "http://192.168.1.100:11434"
}
```

### Custom Models

You can import custom GGUF models:

```bash
# Create Modelfile
echo "FROM ./my-model.gguf" > Modelfile

# Create model
docker exec -i ollama ollama create my-embed-model -f Modelfile
```

### Batch Processing

For better performance when indexing:

```json
{
  "EMBEDDING_BATCH_SIZE": "200"
}
```

Ollama will process multiple embeddings in parallel.

### API Authentication

To secure Ollama (not included by default):

Use a reverse proxy like Nginx or Traefik with authentication.

## Comparing Models

### Benchmark nomic-embed-text

```bash
time docker exec ollama ollama run nomic-embed-text "Test embedding"
```

### Compare Different Models

| Metric | nomic-embed-text | mxbai-embed-large | all-minilm |
|--------|------------------|-------------------|------------|
| Size | 274MB | 669MB | 46MB |
| Speed | Fast | Medium | Very Fast |
| Quality | High | Very High | Medium |
| Dimensions | 768 | 1024 | 384 |

**Recommendation:** `nomic-embed-text` offers the best balance.

## Resources

- [Ollama Official Documentation](https://ollama.ai/)
- [Ollama GitHub](https://github.com/ollama/ollama)
- [Ollama Models Library](https://ollama.ai/library)
- [Nomic Embed Text](https://huggingface.co/nomic-ai/nomic-embed-text-v1)

## Next Steps

- [Configure MILVUS](./MILVUS_SETUP.md)
- [Configure VS Code](../VSCODE_SETUP.md)
- [Start Using the MCP](../USAGE.md)
