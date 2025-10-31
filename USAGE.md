# Usage Guide - Claude Context MCP

This guide explains how to use the Claude Context MCP server to index and search your codebase.

## Prerequisites

Before using the MCP server, ensure:
- ✅ Docker containers are running (MILVUS and Ollama)
- ✅ VS Code is configured with the MCP server (see [VSCODE_SETUP.md](./VSCODE_SETUP.md))
- ✅ You're in a project directory you want to index

## Quick Start

### 1. Open Your Project

Open your project folder in VS Code or navigate to it in Claude Code:

```bash
cd /path/to/your/project
```

### 2. Index Your Codebase

In your conversation with Claude, simply say:

```
Index this codebase
```

Or use the MCP tool directly:

```
Use the index_codebase tool on the current directory
```

**What happens during indexing:**
- The MCP server scans all files in your project
- Code files are split into logical chunks
- Each chunk is embedded using the `nomic-embed-text` model
- Embeddings are stored in the local MILVUS database
- A BM25 index is created for keyword search

**Indexing time depends on:**
- Number of files
- Total code size
- Your system's performance

**Example times:**
- Small project (< 100 files): 1-2 minutes
- Medium project (100-1000 files): 3-10 minutes
- Large project (> 1000 files): 10-30 minutes

### 3. Check Indexing Status

To see the progress:

```
Check the indexing status
```

Or:

```
What's the status of my codebase indexing?
```

### 4. Search Your Code

Once indexed, you can search semantically:

```
Find functions that handle user authentication
```

```
Show me where API endpoints are defined
```

```
Find code related to database migrations
```

The MCP server will return relevant code snippets with context.

## Available Tools

The Claude Context MCP server provides 4 main tools:

### 1. `index_codebase`

**Purpose:** Index a codebase directory for search

**Usage:**
```
Index this codebase
Index the directory /path/to/project
```

**Parameters:**
- `directory` (optional): Path to index, defaults to current directory
- `projectName` (optional): Custom project name, defaults to directory name

**Example responses:**
- "Indexing started for project 'my-app'"
- "Indexing complete. Processed 523 files."

### 2. `search_code`

**Purpose:** Search the indexed codebase using natural language

**Usage:**
```
Find error handling code
Search for database connection logic
Show me all API route definitions
```

**Parameters:**
- `query`: Natural language search query
- `topK` (optional): Number of results to return (default: 10)
- `projectName` (optional): Specific project to search

**Returns:**
- File paths
- Code snippets
- Relevance scores
- Line numbers

### 3. `get_indexing_status`

**Purpose:** Check the indexing progress

**Usage:**
```
Check indexing status
What's the progress of indexing?
Is indexing complete?
```

**Returns:**
- Current status (indexing/completed)
- Progress percentage
- Files processed
- Estimated time remaining

### 4. `clear_index`

**Purpose:** Remove the index for a project

**Usage:**
```
Clear the index for this codebase
Delete the indexed data
```

**Parameters:**
- `projectName` (optional): Project to clear, defaults to current directory

**Use when:**
- You want to re-index from scratch
- Project structure has significantly changed
- Freeing up database space

## Best Practices

### Effective Search Queries

**✅ Good queries:**
- "Find authentication middleware"
- "Show me database schema definitions"
- "Where are API error handlers?"
- "Functions that process user input"

**❌ Less effective queries:**
- "Show me code" (too vague)
- "line 42" (use direct file navigation)
- Very specific variable names (better to use grep)

**Pro tips:**
- Use natural language describing what the code does
- Focus on functionality, not syntax
- Combine concepts: "authentication + middleware"
- Ask about patterns: "error handling patterns"

### When to Re-index

Re-index your codebase when:
- ✅ Major refactoring completed
- ✅ New features added (significant code changes)
- ✅ Dependencies updated (if they're indexed)
- ✅ Search results seem outdated

You don't need to re-index for:
- ❌ Minor bug fixes
- ❌ Comment changes
- ❌ Single file updates

**Incremental updates:**
Currently, the MCP server doesn't support incremental updates. You need to clear and re-index. This is planned for future updates.

### File Inclusion Rules

By default, the MCP server indexes:

**Included extensions:**
- `.js`, `.jsx`, `.ts`, `.tsx`
- `.py`, `.java`, `.cpp`, `.c`, `.h`
- `.go`, `.rs`, `.rb`, `.php`
- `.cs`, `.swift`, `.kt`, `.scala`
- `.md`, `.json`, `.yaml`, `.yml`
- `.html`, `.css`, `.scss`, `.sass`
- And many more...

**Automatically excluded:**
- `node_modules/`
- `.git/`
- `dist/`, `build/`, `out/`
- `.env*` files
- Binary files
- Large files (> 1MB by default)

**Custom exclusions:**

Add to your MCP config in VS Code settings:

```json
{
  "mcpServers": {
    "claude-context": {
      "env": {
        "CUSTOM_IGNORE_PATTERNS": "temp/**,*.backup,private/**"
      }
    }
  }
}
```

**Custom inclusions:**

```json
{
  "mcpServers": {
    "claude-context": {
      "env": {
        "CUSTOM_EXTENSIONS": ".vue,.svelte,.astro"
      }
    }
  }
}
```

## Example Workflows

### Workflow 1: Understanding a New Codebase

```
You: Index this codebase

[Wait for indexing to complete]

You: What's the overall architecture of this application?
You: Find the main entry points
You: Show me how authentication works
You: Where are the API endpoints defined?
You: Find database models and schemas
```

### Workflow 2: Feature Development

```
You: Find all code related to user profile management
You: Show me the authentication middleware
You: Where are API validation functions?

[Use the results to understand the context]

You: Create a new endpoint for updating user preferences
     that follows the same patterns
```

### Workflow 3: Bug Investigation

```
You: Find error handling code for API requests
You: Show me where database connection errors are caught
You: Search for logging related to [specific feature]

[Identify the issue]

You: Fix the error handling in [specific file]
```

### Workflow 4: Refactoring

```
You: Find all usages of the old authentication method
You: Show me duplicate code patterns
You: Where is [deprecated function] used?

[Review results]

You: Refactor these to use the new pattern
```

## Performance Tips

### Optimize Indexing Speed

1. **Increase batch size** (uses more memory but faster):
```json
{
  "EMBEDDING_BATCH_SIZE": "200"
}
```

2. **Exclude unnecessary files**:
```json
{
  "CUSTOM_IGNORE_PATTERNS": "tests/**,docs/**,examples/**"
}
```

3. **Use dense-only mode** (faster, but less accurate):
```json
{
  "HYBRID_MODE": "false"
}
```

### Optimize Search Quality

1. **Use hybrid mode** (default, more accurate):
```json
{
  "HYBRID_MODE": "true"
}
```

2. **Increase results** for broader context:
```json
{
  "mcpServers": {
    "claude-context": {
      "command": "npx",
      "args": ["-y", "@zilliz/claude-context-mcp@latest"],
      "env": {
        "TOP_K": "20"
      }
    }
  }
}
```

3. **Use AST splitter** for better code structure:
```json
{
  "SPLITTER_TYPE": "ast"
}
```

## Managing Multiple Projects

### Index Multiple Projects

You can index multiple codebases:

```
Index the directory /path/to/project-a with name "project-a"
Index the directory /path/to/project-b with name "project-b"
```

### Search Specific Projects

```
Search for authentication code in project "project-a"
Find API endpoints in "project-b"
```

### Clear Specific Projects

```
Clear the index for project "project-a"
```

### List All Indexed Projects

Currently, there's no built-in tool for this. You can:
1. Check MILVUS directly
2. Keep track of indexed projects manually
3. Use project naming conventions

## Troubleshooting

### Indexing Fails

**Check available disk space:**
```bash
docker exec milvus-standalone df -h
```

**Check Ollama is running:**
```bash
docker exec ollama ollama list
```

**View detailed logs:**
```bash
docker-compose logs -f
```

### Search Returns No Results

**Verify indexing completed:**
```
Check the indexing status
```

**Try different queries:**
- Make queries more general
- Use different terminology
- Check if files were actually indexed

**Re-index if needed:**
```
Clear the index
Index this codebase
```

### Slow Performance

**Reduce indexed files:**
- Add more exclusion patterns
- Index only essential directories

**Increase resources:**
- Allocate more memory to Docker
- Close other applications

**Use dense-only mode:**
```json
{
  "HYBRID_MODE": "false"
}
```

### Out of Memory

**Reduce batch size:**
```json
{
  "EMBEDDING_BATCH_SIZE": "50"
}
```

**Allocate more memory to Docker:**
- Docker Desktop → Settings → Resources → Memory
- Increase to at least 8GB

## Advanced Usage

### Custom Code Splitting

Use AST-based splitting for better structure awareness:

```json
{
  "SPLITTER_TYPE": "ast"
}
```

Or LangChain splitting for larger chunks:

```json
{
  "SPLITTER_TYPE": "langchain"
}
```

### Programmatic Usage

The MCP server can be used with any MCP client:

```javascript
// Example using MCP client library
const client = new MCPClient({
  command: 'npx',
  args: ['-y', '@zilliz/claude-context-mcp@latest'],
  env: {
    EMBEDDING_PROVIDER: 'Ollama',
    MILVUS_ADDRESS: '127.0.0.1:19530',
    OLLAMA_HOST: 'http://127.0.0.1:11434',
    OLLAMA_MODEL: 'nomic-embed-text'
  }
});

await client.callTool('index_codebase', {
  directory: '/path/to/project'
});
```

## Data Management

### Storage Location

**MILVUS data:**
- Docker volume: `milvus_data`
- View with: `docker volume inspect mcp-code-context_milvus_data`

**Ollama models:**
- Docker volume: `ollama_data`
- View with: `docker volume inspect mcp-code-context_ollama_data`

### Backup Your Index

```bash
# Stop services
docker-compose down

# Backup volumes
docker run --rm -v mcp-code-context_milvus_data:/data -v $(pwd)/backup:/backup ubuntu tar czf /backup/milvus-backup.tar.gz /data

# Restart services
docker-compose up -d
```

### Restore from Backup

```bash
# Stop services
docker-compose down

# Restore volumes
docker run --rm -v mcp-code-context_milvus_data:/data -v $(pwd)/backup:/backup ubuntu tar xzf /backup/milvus-backup.tar.gz -C /

# Restart services
docker-compose up -d
```

## Next Steps

Now that you're familiar with using the MCP server:

1. **Experiment** with different search queries
2. **Optimize** your configuration for your workflow
3. **Integrate** into your development process
4. **Contribute** improvements back to the community

## Resources

- [Configuration Guide](./docs/CONFIGURATION.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
- [Claude Context GitHub](https://github.com/zilliztech/claude-context)
- [MCP Documentation](https://modelcontextprotocol.io/)
