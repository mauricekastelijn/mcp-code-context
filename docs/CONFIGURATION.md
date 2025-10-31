# Configuration Guide

This guide covers all configuration options for the Claude Context MCP server with local MILVUS and Ollama.

## Overview

The MCP server is configured through environment variables in your VS Code settings.json file. This guide explains each option and provides examples for different use cases.

## Basic Configuration

### Minimal Setup (Recommended)

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

This is the simplest configuration that works with the local Docker setup.

## Environment Variables

### Required Variables

#### `EMBEDDING_PROVIDER`

**Description:** Which embedding service to use

**Values:**
- `Ollama` - Local Ollama (recommended for this setup)
- `OpenAI` - OpenAI API (requires API key)
- `VoyageAI` - VoyageAI API (requires API key)
- `Gemini` - Google Gemini API (requires API key)

**Default:** `OpenAI`

**Example:**
```json
{
  "EMBEDDING_PROVIDER": "Ollama"
}
```

#### `MILVUS_ADDRESS`

**Description:** Address of the MILVUS server

**Format:** `host:port`

**Default:** None (required)

**Examples:**
```json
// Local setup
{
  "MILVUS_ADDRESS": "127.0.0.1:19530"
}

// Remote MILVUS
{
  "MILVUS_ADDRESS": "192.168.1.100:19530"
}

// Zilliz Cloud
{
  "MILVUS_ADDRESS": "your-cluster.zilliz.com:19530"
}
```

#### `OLLAMA_HOST`

**Description:** URL of the Ollama API server

**Format:** `http://host:port`

**Default:** `http://127.0.0.1:11434`

**Examples:**
```json
// Local setup
{
  "OLLAMA_HOST": "http://127.0.0.1:11434"
}

// Remote Ollama
{
  "OLLAMA_HOST": "http://192.168.1.100:11434"
}

// Custom port
{
  "OLLAMA_HOST": "http://127.0.0.1:8080"
}
```

#### `OLLAMA_MODEL` or `EMBEDDING_MODEL`

**Description:** Name of the embedding model to use

**Default:** Provider-specific default

**Examples:**
```json
// Using OLLAMA_MODEL
{
  "OLLAMA_MODEL": "nomic-embed-text"
}

// Using EMBEDDING_MODEL (works for all providers)
{
  "EMBEDDING_MODEL": "nomic-embed-text"
}

// Different model
{
  "OLLAMA_MODEL": "mxbai-embed-large"
}
```

**Available Ollama Models:**
- `nomic-embed-text` - 274MB, 768 dims (recommended)
- `mxbai-embed-large` - 669MB, 1024 dims (higher quality)
- `all-minilm` - 46MB, 384 dims (faster, smaller)

### Optional Variables

#### `MILVUS_TOKEN`

**Description:** Authentication token for MILVUS (Zilliz Cloud)

**Required:** Only for Zilliz Cloud

**Example:**
```json
{
  "MILVUS_TOKEN": "your-zilliz-api-key"
}
```

#### `HYBRID_MODE`

**Description:** Enable hybrid search (BM25 + vector search)

**Values:** `true` | `false`

**Default:** `true`

**Example:**
```json
{
  "HYBRID_MODE": "true"
}
```

**When to use:**
- `true` - More accurate results (recommended)
- `false` - Faster search, vector-only

#### `EMBEDDING_BATCH_SIZE`

**Description:** Number of items to embed in one batch

**Range:** 1-1000

**Default:** `100`

**Example:**
```json
{
  "EMBEDDING_BATCH_SIZE": "200"
}
```

**Tuning:**
- **Larger** (200-500): Faster indexing, more memory
- **Smaller** (50-100): Slower indexing, less memory
- **Very small** (1-50): For limited memory systems

#### `SPLITTER_TYPE`

**Description:** Code splitting strategy

**Values:**
- `ast` - Abstract Syntax Tree based (recommended)
- `langchain` - Simple text-based chunking

**Default:** `ast`

**Example:**
```json
{
  "SPLITTER_TYPE": "ast"
}
```

**When to use:**
- `ast` - Better code structure awareness (recommended)
- `langchain` - Fallback if AST fails, simpler splitting

#### `CUSTOM_EXTENSIONS`

**Description:** Additional file extensions to index

**Format:** Comma-separated list with dots

**Default:** None

**Example:**
```json
{
  "CUSTOM_EXTENSIONS": ".vue,.svelte,.astro,.ejs"
}
```

**Common additions:**
- `.vue` - Vue.js components
- `.svelte` - Svelte components
- `.astro` - Astro components
- `.ejs` - EJS templates
- `.hbs` - Handlebars templates

#### `CUSTOM_IGNORE_PATTERNS`

**Description:** Additional glob patterns to exclude from indexing

**Format:** Comma-separated glob patterns

**Default:** None

**Example:**
```json
{
  "CUSTOM_IGNORE_PATTERNS": "temp/**,*.backup,private/**,test-data/**"
}
```

**Common patterns:**
- `temp/**` - Temporary directories
- `*.backup` - Backup files
- `private/**` - Private directories
- `test-data/**` - Test data
- `*.log` - Log files
- `docs/**` - Documentation

## Configuration Examples

### 1. Development Setup (Default)

Balanced performance and accuracy:

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
        "OLLAMA_MODEL": "nomic-embed-text",
        "HYBRID_MODE": "true",
        "EMBEDDING_BATCH_SIZE": "100",
        "SPLITTER_TYPE": "ast"
      }
    }
  }
}
```

### 2. High-Performance Setup

Faster indexing, more memory usage:

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
        "OLLAMA_MODEL": "nomic-embed-text",
        "HYBRID_MODE": "false",
        "EMBEDDING_BATCH_SIZE": "500",
        "SPLITTER_TYPE": "langchain"
      }
    }
  }
}
```

### 3. Low-Resource Setup

For systems with limited memory:

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
        "OLLAMA_MODEL": "all-minilm",
        "HYBRID_MODE": "false",
        "EMBEDDING_BATCH_SIZE": "50",
        "SPLITTER_TYPE": "langchain"
      }
    }
  }
}
```

### 4. High-Quality Setup

Best accuracy, slower:

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
        "OLLAMA_MODEL": "mxbai-embed-large",
        "HYBRID_MODE": "true",
        "EMBEDDING_BATCH_SIZE": "50",
        "SPLITTER_TYPE": "ast"
      }
    }
  }
}
```

### 5. Full-Stack Web Development

Optimized for web projects:

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
        "OLLAMA_MODEL": "nomic-embed-text",
        "HYBRID_MODE": "true",
        "EMBEDDING_BATCH_SIZE": "100",
        "SPLITTER_TYPE": "ast",
        "CUSTOM_EXTENSIONS": ".vue,.svelte,.astro,.ejs,.hbs",
        "CUSTOM_IGNORE_PATTERNS": "dist/**,build/**,node_modules/**,*.min.js,*.map"
      }
    }
  }
}
```

### 6. Monorepo Setup

For large monorepos:

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
        "OLLAMA_MODEL": "nomic-embed-text",
        "HYBRID_MODE": "true",
        "EMBEDDING_BATCH_SIZE": "200",
        "SPLITTER_TYPE": "ast",
        "CUSTOM_IGNORE_PATTERNS": "node_modules/**,dist/**,build/**,coverage/**,.nx/**"
      }
    }
  }
}
```

## Docker Configuration

### docker-compose.yml Customization

#### Change Ports

If default ports conflict:

```yaml
services:
  milvus:
    ports:
      - "19531:19530"  # Changed from 19530
      
  ollama:
    ports:
      - "11435:11434"  # Changed from 11434
```

Then update MCP config:
```json
{
  "MILVUS_ADDRESS": "127.0.0.1:19531",
  "OLLAMA_HOST": "http://127.0.0.1:11435"
}
```

#### Increase Memory Limits

```yaml
services:
  milvus:
    mem_limit: 4g
    
  ollama:
    mem_limit: 8g
```

#### Add CPU Limits

```yaml
services:
  milvus:
    cpus: 4
    
  ollama:
    cpus: 6
```

#### Enable GPU for Ollama

```yaml
ollama:
  runtime: nvidia
  environment:
    - NVIDIA_VISIBLE_DEVICES=all
```

#### Change Data Persistence

```yaml
volumes:
  milvus_data:
    driver: local
    driver_opts:
      type: none
      device: /path/to/persistent/storage
      o: bind
```

## Advanced Configuration

### Multiple Environments

Create separate configurations for different use cases:

**settings.json:**
```json
{
  "mcpServers": {
    "claude-context-dev": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "EMBEDDING_PROVIDER": "Ollama",
        "MILVUS_ADDRESS": "127.0.0.1:19530",
        "OLLAMA_HOST": "http://127.0.0.1:11434",
        "OLLAMA_MODEL": "nomic-embed-text"
      }
    },
    "claude-context-prod": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "EMBEDDING_PROVIDER": "Ollama",
        "MILVUS_ADDRESS": "127.0.0.1:19530",
        "OLLAMA_HOST": "http://127.0.0.1:11434",
        "OLLAMA_MODEL": "mxbai-embed-large",
        "HYBRID_MODE": "true",
        "EMBEDDING_BATCH_SIZE": "200"
      }
    }
  }
}
```

### Remote Services

Using remote MILVUS and Ollama:

```json
{
  "mcpServers": {
    "claude-context": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "EMBEDDING_PROVIDER": "Ollama",
        "MILVUS_ADDRESS": "10.0.0.5:19530",
        "OLLAMA_HOST": "http://10.0.0.6:11434",
        "OLLAMA_MODEL": "nomic-embed-text"
      }
    }
  }
}
```

### Zilliz Cloud Integration

Using cloud MILVUS instead of local:

```json
{
  "mcpServers": {
    "claude-context": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "EMBEDDING_PROVIDER": "Ollama",
        "MILVUS_ADDRESS": "your-cluster.zilliz.com:19530",
        "MILVUS_TOKEN": "your-api-key",
        "OLLAMA_HOST": "http://127.0.0.1:11434",
        "OLLAMA_MODEL": "nomic-embed-text"
      }
    }
  }
}
```

### OpenAI Embeddings

Using OpenAI instead of Ollama:

```json
{
  "mcpServers": {
    "claude-context": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "EMBEDDING_PROVIDER": "OpenAI",
        "OPENAI_API_KEY": "sk-your-api-key",
        "EMBEDDING_MODEL": "text-embedding-3-large",
        "MILVUS_ADDRESS": "127.0.0.1:19530"
      }
    }
  }
}
```

## Performance Tuning

### Indexing Speed

**Fastest:**
```json
{
  "HYBRID_MODE": "false",
  "EMBEDDING_BATCH_SIZE": "500",
  "SPLITTER_TYPE": "langchain"
}
```

**Balanced:**
```json
{
  "HYBRID_MODE": "true",
  "EMBEDDING_BATCH_SIZE": "100",
  "SPLITTER_TYPE": "ast"
}
```

### Search Quality

**Best Quality:**
```json
{
  "HYBRID_MODE": "true",
  "OLLAMA_MODEL": "mxbai-embed-large",
  "SPLITTER_TYPE": "ast"
}
```

**Fastest Search:**
```json
{
  "HYBRID_MODE": "false",
  "OLLAMA_MODEL": "all-minilm"
}
```

### Memory Usage

**Minimal Memory:**
```json
{
  "EMBEDDING_BATCH_SIZE": "50",
  "OLLAMA_MODEL": "all-minilm"
}
```

**High Memory:**
```json
{
  "EMBEDDING_BATCH_SIZE": "500",
  "OLLAMA_MODEL": "mxbai-embed-large"
}
```

## Validation

### Test Configuration

After changing configuration:

1. **Restart VS Code**
   ```
   Ctrl+Shift+P → Developer: Reload Window
   ```

2. **Test indexing**
   ```
   Index this codebase
   ```

3. **Test search**
   ```
   Find authentication code
   ```

4. **Check logs**
   - View → Output → MCP: claude-context

### Verify Services

```bash
# Check MILVUS
curl http://127.0.0.1:9091/healthz

# Check Ollama
curl http://127.0.0.1:11434/api/tags

# Check Docker
docker-compose ps
```

## Best Practices

1. **Start with defaults** - Use recommended configuration first
2. **One change at a time** - Test each change individually
3. **Monitor performance** - Watch CPU, memory, disk usage
4. **Document changes** - Keep notes on what works
5. **Backup data** - Before major configuration changes
6. **Test thoroughly** - Verify indexing and search work

## Troubleshooting

If configuration doesn't work:

1. **Validate JSON** - Use [jsonlint.com](https://jsonlint.com/)
2. **Check logs** - View → Output → MCP: claude-context
3. **Verify services** - Ensure Docker containers are running
4. **Reset to defaults** - Try minimal configuration first
5. **Check versions** - Ensure compatible Node.js version

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for detailed help.

## Resources

- [Claude Context Docs](https://github.com/zilliztech/claude-context)
- [MILVUS Configuration](https://milvus.io/docs/configure-docker.md)
- [Ollama Models](https://ollama.ai/library)
- [MCP Protocol](https://modelcontextprotocol.io/)
