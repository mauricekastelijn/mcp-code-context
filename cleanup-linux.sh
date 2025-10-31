#!/bin/bash

# Claude Context MCP - Linux Cleanup Script
# This script removes all Docker containers, volumes, and optionally models

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}Claude Context MCP - Cleanup${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

echo -e "${YELLOW}⚠️  WARNING: This will remove all data!${NC}"
echo ""
echo -e "${YELLOW}This script will:${NC}"
echo -e "${NC}  - Stop all running containers${NC}"
echo -e "${NC}  - Remove containers${NC}"
echo -e "${NC}  - Remove Docker volumes (all indexed data)${NC}"
echo -e "${NC}  - Optionally remove downloaded models${NC}"
echo ""

read -p "Continue? (yes/no) " -r
echo
if [[ ! $REPLY == "yes" ]]; then
    echo -e "${GREEN}Cleanup cancelled.${NC}"
    exit 0
fi

# Detect compose command
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Docker Compose not found!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[1/3] Stopping containers...${NC}"
$COMPOSE_CMD down

echo ""
echo -e "${YELLOW}[2/3] Removing volumes...${NC}"
$COMPOSE_CMD down -v

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Containers and volumes removed${NC}"
else
    echo -e "${YELLOW}⚠️  Some resources may not have been removed${NC}"
fi

echo ""
echo -e "${GREEN}[3/3] Cleanup complete!${NC}"
echo ""

echo -e "${CYAN}To start fresh, run:${NC}"
echo -e "${NC}  ./setup-linux.sh${NC}"
echo ""
