#!/bin/bash

# Comprehensive Docker cleanup script
# Preserves containers, images, volumes, and networks related to agentmitra and transva
# Aggressively cleans up everything else to reclaim disk space

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🧹 Starting comprehensive Docker cleanup..."
echo "💾 Checking current disk usage..."
docker system df

# Function to check if a resource is related to agentmitra or transva
is_safe_resource() {
    local resource_name="$1"
    echo "$resource_name" | grep -qiE "(agentmitra|transva)" || return 1
}

# Stop and remove containers not related to agentmitra/transva
echo -e "\n${YELLOW}🔍 Identifying running containers...${NC}"
running_containers=$(docker ps --format "table {{.Names}}\t{{.Image}}" | tail -n +2)

if [ -n "$running_containers" ]; then
    echo -e "${BLUE}Running containers:${NC}"
    echo "$running_containers"

    echo -e "\n${YELLOW}🛑 Stopping containers not related to agentmitra/transva...${NC}"
    while IFS=$'\t' read -r container_name image_name; do
        if ! is_safe_resource "$container_name" && ! is_safe_resource "$image_name"; then
            echo "Stopping container: $container_name"
            docker stop "$container_name" 2>/dev/null || true
        fi
    done <<< "$running_containers"
else
    echo "No running containers found."
fi

# Remove stopped containers not related to agentmitra/transva
echo -e "\n${YELLOW}🗑️  Removing stopped containers not related to agentmitra/transva...${NC}"
all_containers=$(docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | tail -n +2)

if [ -n "$all_containers" ]; then
    while IFS=$'\t' read -r container_name image_name status; do
        if ! is_safe_resource "$container_name" && ! is_safe_resource "$image_name"; then
            echo "Removing container: $container_name ($status)"
            docker rm "$container_name" 2>/dev/null || true
        fi
    done <<< "$all_containers"
else
    echo "No containers found."
fi

# Remove unused images not related to agentmitra/transva
echo -e "\n${YELLOW}🖼️  Removing unused images not related to agentmitra/transva...${NC}"
unused_images=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}" | tail -n +2)

if [ -n "$unused_images" ]; then
    while IFS=$'\t' read -r image_name image_id size; do
        if ! is_safe_resource "$image_name"; then
            echo "Removing image: $image_name ($size)"
            docker rmi "$image_id" 2>/dev/null || true
        fi
    done <<< "$unused_images"
fi

# Remove unused volumes not related to agentmitra/transva
echo -e "\n${YELLOW}💾 Removing unused volumes not related to agentmitra/transva...${NC}"
unused_volumes=$(docker volume ls --format "{{.Name}}" 2>/dev/null || true)

if [ -n "$unused_volumes" ]; then
    for volume_name in $unused_volumes; do
        if ! is_safe_resource "$volume_name"; then
            echo "Removing volume: $volume_name"
            docker volume rm "$volume_name" 2>/dev/null || true
        fi
    done
fi

# Remove unused networks not related to agentmitra/transva
echo -e "\n${YELLOW}🌐 Removing unused networks not related to agentmitra/transva...${NC}"
unused_networks=$(docker network ls --format "{{.Name}}" | grep -v -E "(bridge|host|none)" || true)

if [ -n "$unused_networks" ]; then
    for network_name in $unused_networks; do
        if ! is_safe_resource "$network_name"; then
            echo "Removing network: $network_name"
            docker network rm "$network_name" 2>/dev/null || true
        fi
    done
fi

# Clean up build cache
echo -e "\n${YELLOW}🔧 Removing Docker build cache...${NC}"
docker builder prune -a -f

# Remove dangling resources
echo -e "\n${YELLOW}🧽 Removing dangling resources...${NC}"
docker system prune -f

echo -e "\n${GREEN}✅ Docker cleanup completed!${NC}"
echo "💾 Final disk usage:"
docker system df

echo -e "\n${BLUE}📋 Summary of preserved resources:${NC}"
echo "Containers:"
docker ps -a --format "table {{.Names}}\t{{.Image}}" | grep -iE "(agentmitra|transva)" || echo "  None found"
echo "Images:"
docker images --format "table {{.Repository}}:{{.Tag}}" | grep -iE "(agentmitra|transva)" || echo "  None found"
echo "Volumes:"
docker volume ls --format "{{.Name}}" | grep -iE "(agentmitra|transva)" || echo "  None found"
echo "Networks:"
docker network ls --format "{{.Name}}" | grep -iE "(agentmitra|transva)" || echo "  None found"
