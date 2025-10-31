# VS Code MCP Configuration

This guide explains how to configure the Claude Context MCP server in VS Code (Cascade).

## Prerequisites

Before configuring the MCP server, ensure:
- ✅ Docker containers are running (run `setup-windows.ps1` or `setup-linux.sh`)
- ✅ Node.js (>= 20.0.0 and < 24.0.0) is installed
- ✅ VS Code (Cascade) is installed

## Configuration Steps

### Step 1: Locate VS Code User Directory

The MCP configuration goes in a separate `mcp.json` file (not in settings.json).

**Windows:**
```
%APPDATA%\Code\User\
```
Full path: `C:\Users\YourUsername\AppData\Roaming\Code\User\`

**Linux:**
```
~/.config/Code/User/
```

**Mac:**
```
~/Library/Application Support/Code/User/
```

### Step 2: Create mcp.json File

In the User directory, create a new file named `mcp.json` with the following content:

```json
{
    "servers": {
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

**Note:** This is a separate file from `settings.json`. Both files should be in the same directory.

### Step 3: Verify File Location

Your VS Code User directory should now have:
```
Code/User/
  ├── settings.json    (your existing settings)
  └── mcp.json         (new MCP configuration)
```

### Step 4: Reload VS Code

1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
2. Type "Developer: Reload Window"
3. Press Enter

## Configuration Explanation

Here's what each configuration option does:

| Variable | Value | Description |
|----------|-------|-------------|
| `EMBEDDING_PROVIDER` | `Ollama` | Uses local Ollama for embeddings instead of OpenAI |
| `MILVUS_ADDRESS` | `127.0.0.1:19530` | Local MILVUS database address |
| `OLLAMA_HOST` | `http://127.0.0.1:11434` | Local Ollama API endpoint |
| `OLLAMA_MODEL` | `nomic-embed-text` | The embedding model to use |

## Advanced Configuration (Optional)

### Using a Different Embedding Model

If you want to use a different Ollama model:

1. **Pull the model:**
```bash
docker exec ollama ollama pull <model-name>
```

2. **Update mcp.json:**
```json
{
    "servers": {
        "claude-context": {
            "command": "npx",
            "args": ["-y", "@zilliz/claude-context-mcp@latest"],
            "env": {
                "EMBEDDING_PROVIDER": "Ollama",
                "MILVUS_ADDRESS": "127.0.0.1:19530",
                "OLLAMA_HOST": "http://127.0.0.1:11434",
                "OLLAMA_MODEL": "<model-name>"
            }
        }
    }
}
```

### Additional Configuration Options

You can add these optional environment variables to `mcp.json`:

```json
{
    "servers": {
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
                "CUSTOM_EXTENSIONS": ".vue,.svelte,.astro",
                "CUSTOM_IGNORE_PATTERNS": "temp/**,*.backup"
            }
        }
    }
}
```

| Variable | Default | Description |
|----------|---------|-------------|
| `HYBRID_MODE` | `true` | Enable hybrid search (BM25 + dense vector) |
| `EMBEDDING_BATCH_SIZE` | `100` | Batch size for processing embeddings |
| `SPLITTER_TYPE` | `ast` | Code splitter type (`ast` or `langchain`) |
| `CUSTOM_EXTENSIONS` | - | Additional file extensions to index |
| `CUSTOM_IGNORE_PATTERNS` | - | Additional patterns to ignore |

## Verification

To verify the MCP server is configured correctly:

1. **Open VS Code**

2. **Open a project folder**

3. **Try the MCP commands** (see [USAGE.md](./USAGE.md) for detailed usage)

4. **Check MCP Server Status**
   - The MCP server will start automatically when you use it
   - Check the output panel for any errors

## Troubleshooting

### MCP Server Won't Start

**Check Node.js version:**
```bash
node --version
```
Should be >= 20.0.0 and < 24.0.0

**If using Node.js 24.x or higher:**
```bash
# Windows (using nvm-windows)
nvm install 20
nvm use 20

# Linux/Mac (using nvm)
nvm install 20
nvm use 20
```

### Connection Errors

**Verify services are running:**
```bash
docker ps
```

You should see containers: `milvus-standalone`, `ollama`, `milvus-etcd`, `milvus-minio`

**Test MILVUS connection:**
```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri "http://127.0.0.1:9091/healthz"

# Linux/Mac
curl http://127.0.0.1:9091/healthz
```

**Test Ollama connection:**
```bash
# Windows (PowerShell)
Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags"

# Linux/Mac
curl http://127.0.0.1:11434/api/tags
```

### Embedding Model Not Found

**Check if model is downloaded:**
```bash
docker exec ollama ollama list
```

**Download the model if missing:**
```bash
docker exec ollama ollama pull nomic-embed-text
```

### Port Already in Use

If ports 19530 or 11434 are already in use:

1. **Find the process using the port:**

**Windows:**
```powershell
netstat -ano | findstr "19530"
netstat -ano | findstr "11434"
```

**Linux/Mac:**
```bash
lsof -i :19530
lsof -i :11434
```

2. **Stop the conflicting service or change the ports in docker-compose.yml**

### MCP Server Crashes

**View the MCP server logs:**
- Open VS Code Output panel
- Select "MCP: claude-context" from the dropdown

**Common issues:**
- Node.js version incompatibility (must be < 24.0.0)
- Services not running
- Network connectivity issues

### Reset Everything

If nothing works, try a complete reset:

**Windows:**
```powershell
.\cleanup-windows.ps1
.\setup-windows.ps1
```

**Linux/Mac:**
```bash
./cleanup-linux.sh
./setup-linux.sh
```

Then reconfigure VS Code following the steps above.

## Alternative MCP Clients

### Claude Desktop

For Claude Desktop, create/edit the configuration file:

**Windows:**
```
%APPDATA%\Claude\claude_desktop_config.json
```

**Mac:**
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Linux:**
```
~/.config/Claude/claude_desktop_config.json
```

Add (Claude Desktop still uses the older mcpServers format):
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

Then restart Claude Desktop.

**Note:** Claude Desktop uses a different configuration format than VS Code. Use `mcpServers` for Claude Desktop and `servers` in `mcp.json` for VS Code.

### Cline (VS Code Extension)

In Cline's MCP settings, add the same configuration as above.

## Next Steps

Once configured, proceed to [USAGE.md](./USAGE.md) to learn how to:
- Index your codebase
- Search code semantically
- Use the MCP tools effectively

## Additional Resources

- [Claude Context Documentation](https://github.com/zilliztech/claude-context)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [Troubleshooting Guide](./docs/TROUBLESHOOTING.md)
