#!/bin/bash

# Start all services for development

echo "🚀 Starting Video Summarizer Evaluation System"
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
else
    IS_WINDOWS=false
fi

# Function to cleanup on exit
cleanup() {
    echo ""
    print_status "🛑 Shutting down services..."
    
    # Kill all background jobs
    jobs -p | xargs -r kill 2>/dev/null
    
    # Additional cleanup for Windows
    if [ "$IS_WINDOWS" = true ]; then
        taskkill //F //IM python.exe 2>/dev/null || true
        taskkill //F //IM node.exe 2>/dev/null || true
    fi
    
    print_success "All services stopped!"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM EXIT

# Check if services are already running
check_port() {
    local port=$1
    local service=$2
    
    if command -v lsof >/dev/null 2>&1; then
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_error "$service is already running on port $port"
            return 1
        fi
    elif command -v netstat >/dev/null 2>&1; then
        if netstat -an | grep ":$port " | grep LISTEN >/dev/null 2>&1; then
            print_error "$service is already running on port $port"
            return 1
        fi
    fi
    return 0
}

# Check ports
print_status "Checking if ports are available..."
check_port 5000 "AI Service" || exit 1
check_port 5001 "API Service" || exit 1
check_port 3000 "Frontend" || exit 1

# Create logs directory
mkdir -p logs

# Start Python AI Service
print_status "📡 Starting Python AI Service on port 5000..."
cd backend/python-ai

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_error "Virtual environment not found. Please run ./scripts/install.sh first."
    exit 1
fi

# Activate virtual environment
if [ "$IS_WINDOWS" = true ]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# Start AI service in background
python app.py > ../../logs/ai-service.log 2>&1 &
AI_PID=$!
cd ../..

# Wait for AI service to start
print_status "Waiting for AI Service to start..."
sleep 5

# Check if AI service is running
if ! kill -0 $AI_PID 2>/dev/null; then
    print_error "Failed to start AI Service. Check logs/ai-service.log"
    exit 1
fi

# Test AI service health
if command -v curl >/dev/null 2>&1; then
    if curl -s http://localhost:5000/health >/dev/null 2>&1; then
        print_success "AI Service is running on http://localhost:5000"
    else
        print_error "AI Service health check failed"
        exit 1
    fi
else
    print_success "AI Service started (health check skipped - curl not available)"
fi

# Start Node.js API
print_status "🔧 Starting Node.js API on port 5001..."
cd backend/node-api

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    print_error "Node modules not found. Please run ./scripts/install.sh first."
    exit 1
fi

# Start API service in background
npm run dev > ../../logs/api-service.log 2>&1 &
API_PID=$!
cd ../..

# Wait for API service to start
print_status "Waiting for API Service to start..."
sleep 5

# Check if API service is running
if ! kill -0 $API_PID 2>/dev/null; then
    print_error "Failed to start API Service. Check logs/api-service.log"
    exit 1
fi

# Test API service health
if command -v curl >/dev/null 2>&1; then
    if curl -s http://localhost:5001/health >/dev/null 2>&1; then
        print_success "API Service is running on http://localhost:5001"
    else
        print_error "API Service health check failed"
        exit 1
    fi
else
    print_success "API Service started (health check skipped - curl not available)"
fi

# Start Frontend
print_status "🌐 Starting Frontend on port 3000..."
cd frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    print_error "Frontend node modules not found. Please run ./scripts/install.sh first."
    exit 1
fi

# Start frontend in background
npm start > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Wait for frontend to start
print_status "Waiting for Frontend to start..."
sleep 10

# Check if frontend is running
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    print_error "Failed to start Frontend. Check logs/frontend.log"
    exit 1
fi

print_success "Frontend is starting on http://localhost:3000"

echo ""
echo "✅ All services started successfully!"
echo "====================================="
echo ""
echo "🌐 Access Points:"
echo "   Frontend:    http://localhost:3000"
echo "   API:         http://localhost:5001"
echo "   AI Service:  http://localhost:5000"
echo ""
echo "📊 Service Status:"
echo "   AI Service PID:  $AI_PID"
echo "   API Service PID: $API_PID"
echo "   Frontend PID:    $FRONTEND_PID"
echo ""
echo "📝 Logs:"
echo "   AI Service:  logs/ai-service.log"
echo "   API Service: logs/api-service.log"
echo "   Frontend:    logs/frontend.log"
echo ""
echo "🛑 To stop all services, press Ctrl+C"
echo ""

# Wait for user interrupt
while true; do
    sleep 1
    
    # Check if any service has died
    if ! kill -0 $AI_PID 2>/dev/null; then
        print_error "AI Service has stopped unexpectedly"
        break
    fi
    
    if ! kill -0 $API_PID 2>/dev/null; then
        print_error "API Service has stopped unexpectedly"
        break
    fi
    
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        print_error "Frontend has stopped unexpectedly"
        break
    fi
done
