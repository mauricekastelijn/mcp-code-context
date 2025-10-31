# Claude Context MCP - Local Setup

A self-contained setup for running the [claude-context MCP server](https://github.com/zilliztech/claude-context) with local services using Docker containers.

## 🎯 Overview

This repository provides a fully local deployment of the Claude Context MCP server with:
- **MILVUS** - Local vector database for storing embeddings
- **Ollama** - Local embedding model inference
- **Docker** - Containerized services for easy setup

## ✨ Features

- 🔒 **Fully Local** - No cloud dependencies, all data stays on your machine
- 🚀 **One-Command Setup** - Automated scripts for Windows and Linux
- 🐳 **Docker-Based** - Consistent environment across platforms
- 📦 **Self-Contained** - Everything you need in one repository

## 📋 Prerequisites

Before you begin, ensure you have:
- **Docker** and **Docker Compose** installed
- **Node.js** (>= 20.0.0 and < 24.0.0)
- **VS Code** (for MCP integration)
- At least **8GB RAM** available for Docker containers
- At least **4GB disk space** for models and database

### 🏢 Corporate Proxy/Firewall Users

⚠️ **Important:** If you're behind a corporate proxy (e.g., Cisco Umbrella, Zscaler), you'll need to add your CA certificate before running setup.

**Quick steps:**
1. Export your organization's root CA certificate
2. Place it in `ollama/res/Cisco_Umbrella_Root_CA.cer`
3. Run the setup script (it will automatically build with your certificate)

**📖 See [CORPORATE_PROXY_SETUP.md](./CORPORATE_PROXY_SETUP.md) for complete step-by-step instructions.**

If you're **not** behind a corporate proxy, skip this - the default setup will work.

### Install Docker

**Windows:**
- Download and install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
- Ensure WSL 2 is enabled

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Install Node.js

**Windows:**
- Download from [nodejs.org](https://nodejs.org/) (LTS version 20.x or 22.x)

**Linux:**
```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/mauricekastelijn/mcp-code-context.git
cd mcp-code-context
```

### 2. Run Setup Script

**Windows (PowerShell):**
```powershell
.\setup-windows.ps1
```

**Linux/Mac:**
```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

This will:
1. Start MILVUS database in Docker
2. Start Ollama service in Docker
3. Download the `nomic-embed-text` embedding model
4. Verify all services are running

### 3. Configure VS Code

Follow the instructions in [VSCODE_SETUP.md](./VSCODE_SETUP.md) to add the MCP server to VS Code.

### 4. Verify Setup

**Windows:**
```powershell
.\verify-setup.ps1
```

**Linux/Mac:**
```bash
chmod +x verify-setup.sh
./verify-setup.sh
```

This will check that all services are running correctly.

### 5. Start Using

See [USAGE.md](./USAGE.md) for detailed instructions on indexing codebases and using the MCP server.

Check [EXAMPLES.md](./EXAMPLES.md) for practical examples and real-world use cases.

## 📚 Documentation

### Getting Started
- [Quick Reference](./QUICK_REFERENCE.md) - Quick commands and shortcuts
- [VS Code Setup](./VSCODE_SETUP.md) - MCP server configuration in VS Code
- [Usage Guide](./USAGE.md) - How to use the MCP server
- [Examples](./EXAMPLES.md) - Practical examples and use cases
- [Corporate Proxy Setup](./CORPORATE_PROXY_SETUP.md) - Setup behind corporate firewalls

### Detailed Guides
- [MILVUS Setup](./docs/MILVUS_SETUP.md) - Detailed MILVUS configuration
- [Ollama Setup](./docs/OLLAMA_SETUP.md) - Detailed Ollama configuration
- [Configuration](./docs/CONFIGURATION.md) - Advanced configuration options
- [Troubleshooting](./docs/TROUBLESHOOTING.md) - Common issues and solutions

### Contributing
- [Contributing Guide](./CONTRIBUTING.md) - How to contribute to this project

## 🔧 Architecture

```
┌─────────────────┐
│   VS Code       │
│  (MCP Client)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Claude Context │
│   MCP Server    │
└────┬──────┬─────┘
     │      │
     ▼      ▼
┌─────────┐ ┌─────────┐
│ MILVUS  │ │ Ollama  │
│ :19530  │ │ :11434  │
└─────────┘ └─────────┘
```

## 🛠️ Manual Setup

If you prefer to set up services manually:

1. **MILVUS**: See [docs/MILVUS_SETUP.md](./docs/MILVUS_SETUP.md)
2. **Ollama**: See [docs/OLLAMA_SETUP.md](./docs/OLLAMA_SETUP.md)
3. **VS Code**: See [VSCODE_SETUP.md](./VSCODE_SETUP.md)

## 🔄 Managing Services

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

### Restart Services
```bash
docker-compose restart
```

## 📊 Resource Usage

Expected resource consumption:
- **MILVUS**: ~2GB RAM, ~1GB disk (varies with indexed data)
- **Ollama**: ~2-4GB RAM (depends on model), ~1.5GB disk
- **Total**: ~4-6GB RAM, ~2-3GB disk minimum

## 🧹 Cleanup

To remove all services and data:

**Windows:**
```powershell
.\cleanup-windows.ps1
```

**Linux/Mac:**
```bash
./cleanup-linux.sh
```

This will:
- Stop all containers
- Remove containers and volumes
- Clean up downloaded models (optional)

## ⚙️ Configuration

The MCP server uses these environment variables:

```json
{
  "EMBEDDING_PROVIDER": "Ollama",
  "MILVUS_ADDRESS": "127.0.0.1:19530",
  "OLLAMA_HOST": "http://127.0.0.1:11434",
  "OLLAMA_MODEL": "nomic-embed-text"
}
```

For advanced configuration options, see [docs/CONFIGURATION.md](./docs/CONFIGURATION.md).

## 🐛 Troubleshooting

### Services won't start
```bash
# Check if ports are already in use
netstat -an | grep -E "(19530|11434)"  # Linux
netstat -an | findstr "19530 11434"    # Windows
```

### Ollama model not found
```bash
docker exec -it ollama ollama list
docker exec -it ollama ollama pull nomic-embed-text
```

### MILVUS connection failed
```bash
docker-compose logs milvus
docker-compose restart milvus
```

For more solutions, see [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md).

## 🤝 Contributing

This setup is based on the official [claude-context](https://github.com/zilliztech/claude-context) project. For issues with the MCP server itself, please refer to the upstream repository.

## 📄 License

This setup repository is provided as-is for educational and development purposes. Please refer to the original [claude-context license](https://github.com/zilliztech/claude-context/blob/master/LICENSE) for the MCP server.

## 🔗 Links

- [Claude Context GitHub](https://github.com/zilliztech/claude-context)
- [MILVUS Documentation](https://milvus.io/docs)
- [Ollama Documentation](https://ollama.ai/docs)
- [MCP Protocol](https://modelcontextprotocol.io/)
