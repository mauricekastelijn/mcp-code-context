#!/bin/bash

# Verification Script for Claude Context MCP Setup
# This script checks if everything is configured correctly

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}Setup Verification${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

ALL_PASSED=true

# Check 1: Docker
echo -e "${YELLOW}[1/8] Checking Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker is installed${NC}"
    DOCKER_VERSION=$(docker --version)
    echo -e "${GRAY}   $DOCKER_VERSION${NC}"
else
    echo -e "${RED}❌ Docker is not installed${NC}"
    ALL_PASSED=false
fi

# Check 2: Docker Compose
echo ""
echo -e "${YELLOW}[2/8] Checking Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✅ Docker Compose is installed${NC}"
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GRAY}   $COMPOSE_VERSION${NC}"
elif docker compose version &> /dev/null; then
    echo -e "${GREEN}✅ Docker Compose (v2) is installed${NC}"
else
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    ALL_PASSED=false
fi

# Check 3: Node.js
echo ""
echo -e "${YELLOW}[3/8] Checking Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    
    if [ "$MAJOR_VERSION" -ge 20 ] && [ "$MAJOR_VERSION" -lt 24 ]; then
        echo -e "${GREEN}✅ Node.js $NODE_VERSION is installed (compatible)${NC}"
        echo -e "${GRAY}   Path: $(which node)${NC}"
    else
        echo -e "${YELLOW}⚠️  Node.js $NODE_VERSION is installed but may not be compatible${NC}"
        echo -e "${GRAY}   Required: >= 20.0.0 and < 24.0.0${NC}"
        ALL_PASSED=false
    fi
else
    echo -e "${RED}❌ Node.js is not installed${NC}"
    ALL_PASSED=false
fi

# Check 4: Containers Running
echo ""
echo -e "${YELLOW}[4/8] Checking Docker containers...${NC}"
CONTAINERS=$(docker ps --filter "name=milvus" --filter "name=ollama" --format "{{.Names}}" 2>/dev/null)

if [ ! -z "$CONTAINERS" ]; then
    echo -e "${GREEN}✅ Containers are running:${NC}"
    echo "$CONTAINERS" | while read container; do
        echo -e "${GRAY}   - $container${NC}"
    done
else
    echo -e "${YELLOW}⚠️  No containers are running${NC}"
    echo -e "${GRAY}   Run: ./setup-linux.sh${NC}"
fi

# Check 5: MILVUS Health
echo ""
echo -e "${YELLOW}[5/8] Checking MILVUS...${NC}"
if curl -s -f http://127.0.0.1:9091/healthz > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MILVUS is healthy and accessible${NC}"
    echo -e "${GRAY}   Address: 127.0.0.1:19530${NC}"
else
    echo -e "${RED}❌ MILVUS is not accessible${NC}"
    echo -e "${GRAY}   Ensure containers are running${NC}"
fi

# Check 6: Ollama Health
echo ""
echo -e "${YELLOW}[6/8] Checking Ollama...${NC}"
if curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Ollama is healthy and accessible${NC}"
    echo -e "${GRAY}   Address: http://127.0.0.1:11434${NC}"
    
    # Check 7: Ollama Model
    echo ""
    echo -e "${YELLOW}[7/8] Checking Ollama model...${NC}"
    MODELS=$(curl -s http://127.0.0.1:11434/api/tags)
    if echo "$MODELS" | grep -q "nomic-embed-text"; then
        echo -e "${GREEN}✅ nomic-embed-text model is available${NC}"
        MODEL_NAME=$(echo "$MODELS" | grep -o '"name":"[^"]*nomic-embed-text[^"]*"' | head -1 | cut -d'"' -f4)
        echo -e "${GRAY}   Model: $MODEL_NAME${NC}"
    else
        echo -e "${RED}❌ nomic-embed-text model not found${NC}"
        echo -e "${GRAY}   Run: docker exec ollama ollama pull nomic-embed-text${NC}"
        ALL_PASSED=false
    fi
else
    echo -e "${RED}❌ Ollama is not accessible${NC}"
    echo -e "${GRAY}   Ensure containers are running${NC}"
    echo ""
    echo -e "${YELLOW}[7/8] Checking Ollama model...${NC}"
    echo -e "${GRAY}⊘  Skipped (Ollama not accessible)${NC}"
fi

# Check 8: VS Code Configuration
echo ""
echo -e "${YELLOW}[8/8] Checking VS Code configuration...${NC}"
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"

# Try alternate locations
if [ ! -f "$VSCODE_SETTINGS" ]; then
    VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
fi

if [ -f "$VSCODE_SETTINGS" ]; then
    echo -e "${GREEN}✅ VS Code settings.json exists${NC}"
    echo -e "${GRAY}   Path: $VSCODE_SETTINGS${NC}"
    
    if grep -q "claude-context" "$VSCODE_SETTINGS"; then
        echo -e "${GREEN}✅ MCP server configuration found${NC}"
    else
        echo -e "${YELLOW}⚠️  MCP server not configured in settings.json${NC}"
        echo -e "${GRAY}   See: VSCODE_SETUP.md${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  VS Code settings.json not found${NC}"
    echo -e "${GRAY}   Path: $VSCODE_SETTINGS${NC}"
    echo -e "${GRAY}   This is normal if you haven't configured VS Code yet${NC}"
fi

# Summary
echo ""
echo -e "${CYAN}=====================================${NC}"
if [ "$ALL_PASSED" = true ]; then
    echo -e "${GREEN}✅ All Critical Checks Passed!${NC}"
else
    echo -e "${YELLOW}⚠️  Some Issues Found${NC}"
fi
echo -e "${CYAN}=====================================${NC}"
echo ""

if [ "$ALL_PASSED" != true ]; then
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "${NC}1. Fix any issues marked with ❌${NC}"
    echo -e "${NC}2. Run this script again to verify${NC}"
    echo -e "${NC}3. See TROUBLESHOOTING.md for help${NC}"
else
    echo -e "${CYAN}Your setup looks good! Next steps:${NC}"
    echo -e "${NC}1. Configure VS Code (if not done) - See VSCODE_SETUP.md${NC}"
    echo -e "${NC}2. Index your first codebase - See USAGE.md${NC}"
    echo -e "${NC}3. Start using semantic code search!${NC}"
fi

echo ""
