#!/bin/bash

# Video Summarizer Evaluation - Docker Setup Script
# This script sets up and runs the application using Docker

echo "🐳 Video Summarizer Evaluation - Docker Setup"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker installation
print_status "Checking Docker installation..."

if ! command_exists docker; then
    print_error "Docker is not installed. Please install Docker from https://docker.com/"
    exit 1
fi

if ! command_exists docker-compose; then
    print_error "Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

print_success "Docker $(docker --version) found"
print_success "Docker Compose $(docker-compose --version) found"

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker daemon is not running. Please start Docker."
    exit 1
fi

print_success "Docker daemon is running"

# Setup environment files
print_status "Setting up environment files..."

# Python AI .env
if [ ! -f "backend/python-ai/.env" ]; then
    cp backend/python-ai/.env.example backend/python-ai/.env
    print_success "Created backend/python-ai/.env"
fi

# Node API .env
if [ ! -f "backend/node-api/.env" ]; then
    cp backend/node-api/.env.example backend/node-api/.env
    
    # Update for Docker environment
    sed -i.bak 's|mongodb://localhost:27017|mongodb://mongodb:27017|g' backend/node-api/.env
    sed -i.bak 's|http://localhost:5000|http://ai-service:5000|g' backend/node-api/.env
    sed -i.bak 's|redis://localhost:6379|redis://redis:6379|g' backend/node-api/.env
    rm backend/node-api/.env.bak 2>/dev/null || true
    
    print_success "Created and configured backend/node-api/.env for Docker"
fi

# Frontend .env
if [ ! -f "frontend/.env" ]; then
    echo "REACT_APP_API_URL=http://localhost:5001/api" > frontend/.env
    print_success "Created frontend/.env"
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p backend/node-api/uploads/{videos,thumbnails}
mkdir -p backend/python-ai/temp
mkdir -p logs

# Docker operations menu
echo ""
echo "🐳 Docker Operations:"
echo "===================="
echo "1. Build and start all services"
echo "2. Start existing services"
echo "3. Stop all services"
echo "4. Rebuild services"
echo "5. View logs"
echo "6. Clean up Docker resources"
echo "7. Development mode (with hot reload)"
echo ""

read -p "Select operation (1-7): " docker_operation

case $docker_operation in
    1)
        print_status "Building and starting all services..."
        docker-compose up --build -d
        ;;
    2)
        print_status "Starting existing services..."
        docker-compose up -d
        ;;
    3)
        print_status "Stopping all services..."
        docker-compose down
        print_success "All services stopped"
        exit 0
        ;;
    4)
        print_status "Rebuilding services..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        ;;
    5)
        print_status "Viewing logs..."
        docker-compose logs -f
        exit 0
        ;;
    6)
        print_status "Cleaning up Docker resources..."
        docker-compose down -v --remove-orphans
        docker system prune -f
        docker volume prune -f
        print_success "Docker cleanup completed"
        exit 0
        ;;
    7)
        print_status "Starting in development mode..."
        # Override for development
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build
        exit 0
        ;;
    *)
        print_error "Invalid option selected"
        exit 1
        ;;
esac

# Wait for services to start
print_status "Waiting for services to start..."
sleep 30

# Check service health
check_service_health() {
    local service_name="$1"
    local url="$2"
    local max_attempts=30
    local attempt=1
    
    print_status "Checking $service_name health..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            print_success "$service_name is healthy"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name health check failed"
    return 1
}

# Health checks
echo ""
print_status "Performing health checks..."

check_service_health "AI Service" "http://localhost:5000/health"
check_service_health "API Service" "http://localhost:5001/health"

# Check if frontend is accessible
if curl -s "http://localhost:3000" >/dev/null 2>&1; then
    print_success "Frontend is accessible"
else
    print_warning "Frontend may still be starting up"
fi

# Show service status
echo ""
print_status "Service Status:"
docker-compose ps

echo ""
print_success "🎉 Docker setup completed!"
echo ""
echo "🌐 Access Points:"
echo "   Frontend:    http://localhost:3000"
echo "   API:         http://localhost:5001"
echo "   AI Service:  http://localhost:5000"
echo "   MongoDB:     localhost:27017"
echo "   Redis:       localhost:6379"
echo ""
echo "📊 Useful Commands:"
echo "   View logs:           docker-compose logs -f"
echo "   Stop services:       docker-compose down"
echo "   Restart service:     docker-compose restart <service-name>"
echo "   Shell into service:  docker-compose exec <service-name> /bin/bash"
echo ""
echo "🔧 Services:"
echo "   - mongodb (Database)"
echo "   - redis (Cache)"
echo "   - ai-service (Python AI)"
echo "   - api (Node.js API)"
echo "   - frontend (React App)"
echo "   - nginx (Reverse Proxy)"
echo ""

# Optional: Run tests
if [ "$docker_operation" = "1" ] || [ "$docker_operation" = "4" ]; then
    echo ""
    if read -p "Run tests to verify setup? (y/N): " -n 1 -r; then
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Running tests..."
            
            # Test AI service
            if docker-compose exec ai-service python test_api.py; then
                print_success "AI service tests passed"
            else
                print_warning "AI service tests failed"
            fi
            
            # Test API service
            if docker-compose exec api npm test; then
                print_success "API service tests passed"
            else
                print_warning "API service tests failed"
            fi
        fi
    fi
fi

print_success "Setup complete! Your application is running with Docker. 🐳"
