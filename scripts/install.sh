#!/bin/bash

# Video Summarizer Evaluation - Installation Script
# This script installs all dependencies and sets up the development environment

set -e  # Exit on any error

echo "🚀 Video Summarizer Evaluation - Installation Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running on Windows (Git Bash/WSL)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
    PYTHON_CMD="python"
    PIP_CMD="pip"
else
    IS_WINDOWS=false
    PYTHON_CMD="python3"
    PIP_CMD="pip3"
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Node.js
if ! command_exists node; then
    print_error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18+ is required. Current version: $(node --version)"
    exit 1
fi
print_success "Node.js $(node --version) found"

# Check npm
if ! command_exists npm; then
    print_error "npm is not installed. Please install npm."
    exit 1
fi
print_success "npm $(npm --version) found"

# Check Python
if ! command_exists $PYTHON_CMD; then
    print_error "Python is not installed. Please install Python 3.11+ from https://python.org/"
    exit 1
fi

PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
if ! $PYTHON_CMD -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
    print_error "Python 3.11+ is required. Current version: $($PYTHON_CMD --version)"
    exit 1
fi
print_success "Python $($PYTHON_CMD --version) found"

# Check pip
if ! command_exists $PIP_CMD; then
    print_error "pip is not installed. Please install pip."
    exit 1
fi
print_success "pip $($PIP_CMD --version | cut -d' ' -f2) found"

# Check MongoDB (optional)
if command_exists mongod; then
    print_success "MongoDB found"
else
    print_warning "MongoDB not found. You can install it later or use Docker."
fi

# Check Docker (optional)
if command_exists docker; then
    print_success "Docker found"
else
    print_warning "Docker not found. You can install it later for containerized deployment."
fi

print_success "All prerequisites check passed!"

# Create project directories
print_status "Creating project structure..."
mkdir -p logs
mkdir -p backend/python-ai/temp
mkdir -p backend/node-api/uploads/videos
mkdir -p backend/node-api/uploads/thumbnails

# Install Python AI Service dependencies
print_status "Installing Python AI Service dependencies..."
cd backend/python-ai

# Create virtual environment
print_status "Creating Python virtual environment..."
$PYTHON_CMD -m venv venv

# Activate virtual environment
if [ "$IS_WINDOWS" = true ]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# Upgrade pip
print_status "Upgrading pip..."
$PIP_CMD install --upgrade pip

# Install PyTorch (CPU version for compatibility)
print_status "Installing PyTorch..."
if [ "$IS_WINDOWS" = true ]; then
    $PIP_CMD install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
else
    $PIP_CMD install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
fi

# Install other dependencies
print_status "Installing Python dependencies..."
$PIP_CMD install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating Python AI .env file..."
    cp .env.example .env
    print_success "Created .env file. Please review and update as needed."
fi

print_success "Python AI Service setup complete!"

# Go back to root directory
cd ../..

# Install Node.js API dependencies
print_status "Installing Node.js API dependencies..."
cd backend/node-api

npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating Node.js API .env file..."
    cp .env.example .env
    print_success "Created .env file. Please review and update as needed."
fi

print_success "Node.js API setup complete!"

# Go back to root directory
cd ../..

# Install Frontend dependencies
print_status "Installing Frontend dependencies..."
cd frontend

npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating Frontend .env file..."
    echo "REACT_APP_API_URL=http://localhost:5001/api" > .env
    print_success "Created .env file for frontend."
fi

print_success "Frontend setup complete!"

# Go back to root directory
cd ..

# Install root dependencies (for development scripts)
print_status "Installing root development dependencies..."
npm install

print_success "Root dependencies installed!"

# Create run scripts
print_status "Creating run scripts..."

# Create start script
cat > scripts/start.sh << 'EOF'
#!/bin/bash

# Start all services for development

echo "🚀 Starting Video Summarizer Evaluation System"
echo "=============================================="

# Function to cleanup on exit
cleanup() {
    echo "🛑 Shutting down services..."
    kill $(jobs -p) 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

# Start Python AI Service
echo "📡 Starting Python AI Service..."
cd backend/python-ai
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi
python app.py &
AI_PID=$!
cd ../..

# Wait a moment for AI service to start
sleep 3

# Start Node.js API
echo "🔧 Starting Node.js API..."
cd backend/node-api
npm run dev &
API_PID=$!
cd ../..

# Wait a moment for API to start
sleep 3

# Start Frontend
echo "🌐 Starting Frontend..."
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ All services started!"
echo "📱 Frontend: http://localhost:3000"
echo "🔧 API: http://localhost:5001"
echo "📡 AI Service: http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for all background processes
wait
EOF

chmod +x scripts/start.sh

# Create test script
cat > scripts/test.sh << 'EOF'
#!/bin/bash

echo "🧪 Running Tests"
echo "==============="

# Test Python AI Service
echo "Testing Python AI Service..."
cd backend/python-ai
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi
python test_api.py
cd ../..

# Test Node.js API
echo "Testing Node.js API..."
cd backend/node-api
npm test
cd ../..

# Test Frontend
echo "Testing Frontend..."
cd frontend
npm test -- --watchAll=false
cd ..

echo "✅ All tests completed!"
EOF

chmod +x scripts/test.sh

print_success "Run scripts created!"

# Final setup
print_status "Final setup..."

# Create logs directory
mkdir -p logs

# Create uploads directory structure
mkdir -p backend/node-api/uploads/{videos,thumbnails}

print_success "Installation completed successfully!"

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "📋 Next Steps:"
echo "1. Review and update .env files in:"
echo "   - backend/python-ai/.env"
echo "   - backend/node-api/.env"
echo "   - frontend/.env"
echo ""
echo "2. Start MongoDB (if using local installation):"
echo "   mongod --dbpath ./data/db"
echo ""
echo "3. Start all services:"
echo "   ./scripts/start.sh"
echo ""
echo "4. Run tests:"
echo "   ./scripts/test.sh"
echo ""
echo "🌐 Access Points:"
echo "   Frontend: http://localhost:3000"
echo "   API: http://localhost:5001"
echo "   AI Service: http://localhost:5000"
echo ""
echo "📚 Documentation:"
echo "   - Main README: ./README.md"
echo "   - AI Service: ./backend/python-ai/README.md"
echo ""
print_success "Happy coding! 🚀"
