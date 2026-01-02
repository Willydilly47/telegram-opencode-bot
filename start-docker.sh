#!/bin/bash

# Telegram OpenCode Bot - Docker Startup Script
# Usage: ./start-docker.sh [development|production]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="${1:-development}"

echo "🚀 Starting Telegram OpenCode Bot in $MODE mode..."

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Creating .env from template..."
    cp .env.example .env 2>/dev/null || echo "⚠️  Please create .env file manually"
    exit 1
fi

# Load environment variables
set -a
source .env
set +a

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down --remove-orphans 2>/dev/null || true

if [ "$MODE" = "production" ]; then
    echo "🏭 Building production images..."
    docker compose build --no-cache
    
    echo "🚀 Starting production services..."
    docker compose up -d
    
    echo "✅ Production deployment started!"
    echo "📱 Mini App URL: http://localhost:8080"
    echo "🤖 Bot is running in container"
else
    echo "🔧 Starting development environment..."
    
    # Use override file for development
    docker compose -f docker-compose.yml -f docker-compose.override.yml up -d
    
    echo "✅ Development environment started!"
    echo "🌐 Mini App: http://localhost:8080"
    echo "📝 Source files are mounted for live reloading"
    echo ""
    echo "📋 Useful commands:"
    echo "   View logs:  docker compose logs -f bot"
    echo "   Stop:       docker compose down"
    echo "   Restart:    docker compose restart bot"
fi

echo ""
echo "🎉 OpenCode Bot is ready!"
echo "📱 Test in Telegram: @OpenCodeBridgeBot"
echo "🔧 Send /start to begin"
