#!/bin/bash

# Claude Context MCP - Linux Setup Script
# This script sets up MILVUS and Ollama locally using Docker

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}Claude Context MCP - Local Setup${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

# Check if Docker is installed
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo -e "${RED}Please install Docker first:${NC}"
    echo -e "${RED}  Ubuntu/Debian: sudo apt-get install docker.io docker-compose${NC}"
    echo -e "${RED}  Fedora: sudo dnf install docker docker-compose${NC}"
    exit 1
fi

# Check for docker-compose or docker compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Docker Compose is not installed!${NC}"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  Node.js is not installed!${NC}"
    echo -e "${YELLOW}Please install Node.js (version 20.x or 22.x)${NC}"
    echo -e "${YELLOW}You can continue with Docker setup, but you'll need Node.js for the MCP server.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js $NODE_VERSION detected${NC}"
fi

echo -e "${GREEN}✅ Docker detected${NC}"
echo ""

# Check if user is in docker group (Linux specific)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! groups | grep -q docker; then
        echo -e "${YELLOW}⚠️  Your user is not in the docker group${NC}"
        echo -e "${YELLOW}You may need to run commands with sudo or add yourself to docker group:${NC}"
        echo -e "${YELLOW}  sudo usermod -aG docker \$USER${NC}"
        echo -e "${YELLOW}  Then log out and back in${NC}"
        echo ""
    fi
fi

# Check if containers are already running
echo -e "${YELLOW}[2/6] Checking existing containers...${NC}"
EXISTING_CONTAINERS=$(docker ps -a --filter "name=milvus" --filter "name=ollama" --format "{{.Names}}" 2>/dev/null || true)
if [ ! -z "$EXISTING_CONTAINERS" ]; then
    echo -e "${YELLOW}⚠️  Found existing containers:${NC}"
    echo "$EXISTING_CONTAINERS" | while read container; do
        echo -e "${YELLOW}   - $container${NC}"
    done
    read -p "Remove existing containers? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Stopping and removing existing containers...${NC}"
        $COMPOSE_CMD down -v
    fi
fi

# Start Docker containers
echo ""
echo -e "${YELLOW}[3/6] Starting Docker containers...${NC}"
echo -e "${CYAN}This may take a few minutes on first run...${NC}"

$COMPOSE_CMD up -d

echo -e "${GREEN}✅ Docker containers started${NC}"
echo ""

# Wait for services to be healthy
echo -e "${YELLOW}[4/6] Waiting for services to be ready...${NC}"
echo -e "${CYAN}⏳ This may take 30-60 seconds...${NC}"

MAX_WAIT=120
WAITED=0
INTERVAL=5

while [ $WAITED -lt $MAX_WAIT ]; do
    sleep $INTERVAL
    WAITED=$((WAITED + INTERVAL))
    
    # Check MILVUS
    MILVUS_HEALTHY=$(docker inspect --format='{{.State.Health.Status}}' milvus-standalone 2>/dev/null || echo "unknown")
    
    # Check Ollama
    OLLAMA_HEALTHY=$(docker inspect --format='{{.State.Health.Status}}' ollama 2>/dev/null || echo "unknown")
    
    echo -e "${CYAN}⏳ [$WAITED/$MAX_WAIT seconds] MILVUS: $MILVUS_HEALTHY | Ollama: $OLLAMA_HEALTHY${NC}"
    
    if [ "$MILVUS_HEALTHY" = "healthy" ] && [ "$OLLAMA_HEALTHY" = "healthy" ]; then
        echo -e "${GREEN}✅ All services are healthy!${NC}"
        break
    fi
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "${YELLOW}⚠️  Services took longer than expected to start${NC}"
    echo -e "${YELLOW}Check logs with: $COMPOSE_CMD logs -f${NC}"
fi

echo ""

# Download Ollama model
echo -e "${YELLOW}[5/6] Downloading nomic-embed-text model...${NC}"
echo -e "${CYAN}⏳ This will download ~274MB...${NC}"

if docker exec ollama ollama pull nomic-embed-text; then
    echo -e "${GREEN}✅ Model downloaded successfully${NC}"
else
    echo -e "${RED}❌ Failed to download model!${NC}"
    echo -e "${YELLOW}You can try manually later with: docker exec ollama ollama pull nomic-embed-text${NC}"
fi

echo ""

# Verify setup
echo -e "${YELLOW}[6/6] Verifying setup...${NC}"

# Test MILVUS
if curl -s -f http://127.0.0.1:9091/healthz > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MILVUS is accessible at 127.0.0.1:19530${NC}"
else
    echo -e "${YELLOW}⚠️  MILVUS health check failed (this might be okay if it just started)${NC}"
fi

# Test Ollama
if curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    MODELS=$(curl -s http://127.0.0.1:11434/api/tags | grep -o '"nomic-embed-text[^"]*"' || true)
    if [ ! -z "$MODELS" ]; then
        echo -e "${GREEN}✅ Ollama is accessible at http://127.0.0.1:11434 with nomic-embed-text model${NC}"
    else
        echo -e "${YELLOW}⚠️  Ollama is running but nomic-embed-text model not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Ollama health check failed${NC}"
fi

echo ""
echo -e "${CYAN}=====================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "${NC}1. Configure VS Code - See VSCODE_SETUP.md${NC}"
echo -e "${NC}2. Start using the MCP - See USAGE.md${NC}"
echo ""
echo -e "${CYAN}Useful commands:${NC}"
echo -e "${NC}  View logs:       $COMPOSE_CMD logs -f${NC}"
echo -e "${NC}  Stop services:   $COMPOSE_CMD down${NC}"
echo -e "${NC}  Restart:         $COMPOSE_CMD restart${NC}"
echo ""
echo -e "${CYAN}Services running at:${NC}"
echo -e "${NC}  MILVUS:  127.0.0.1:19530${NC}"
echo -e "${NC}  Ollama:  http://127.0.0.1:11434${NC}"
echo -e "${NC}  MinIO:   http://127.0.0.1:9001 (minioadmin/minioadmin)${NC}"
echo ""
