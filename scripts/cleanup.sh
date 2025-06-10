#!/bin/bash

# Video Summarizer Evaluation - Cleanup Script
# This script removes all dependencies and cleans up the development environment

set -e  # Exit on any error

echo "🧹 Video Summarizer Evaluation - Cleanup Script"
echo "==============================================="

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

# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
else
    IS_WINDOWS=false
fi

# Function to ask for confirmation
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    while true; do
        read -p "$message $prompt: " choice
        case "$choice" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) 
                if [ "$default" = "y" ]; then
                    return 0
                else
                    return 1
                fi
                ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Stop all running services
print_status "Stopping all running services..."

# Kill processes by port
kill_by_port() {
    local port=$1
    local service_name="$2"
    
    if command -v lsof >/dev/null 2>&1; then
        local pids=$(lsof -ti:$port 2>/dev/null || true)
        if [ -n "$pids" ]; then
            echo "Stopping $service_name on port $port..."
            echo "$pids" | xargs kill -9 2>/dev/null || true
        fi
    elif [ "$IS_WINDOWS" = true ]; then
        # Windows-specific process killing
        for /f "tokens=5" %%a in ('netstat -aon ^| findstr :$port') do taskkill /f /pid %%a 2>nul || true
    fi
}

kill_by_port 3000 "Frontend"
kill_by_port 5001 "API Service"
kill_by_port 5000 "AI Service"

# Additional cleanup for common Node.js and Python processes
if [ "$IS_WINDOWS" = true ]; then
    taskkill //F //IM node.exe 2>/dev/null || true
    taskkill //F //IM python.exe 2>/dev/null || true
else
    pkill -f "node.*start" 2>/dev/null || true
    pkill -f "python.*app.py" 2>/dev/null || true
fi

print_success "Services stopped"

# Cleanup options
echo ""
echo "🗂️  Cleanup Options:"
echo "==================="
echo "1. Light cleanup (node_modules, Python cache)"
echo "2. Medium cleanup (+ Python virtual environment)"
echo "3. Full cleanup (+ logs, uploads, all generated files)"
echo "4. Nuclear cleanup (+ .env files, complete reset)"
echo "5. Custom cleanup (choose what to clean)"
echo ""

read -p "Select cleanup level (1-5): " cleanup_level

case $cleanup_level in
    1)
        print_status "Performing light cleanup..."
        CLEAN_NODE_MODULES=true
        CLEAN_PYTHON_CACHE=true
        ;;
    2)
        print_status "Performing medium cleanup..."
        CLEAN_NODE_MODULES=true
        CLEAN_PYTHON_CACHE=true
        CLEAN_VENV=true
        ;;
    3)
        print_status "Performing full cleanup..."
        CLEAN_NODE_MODULES=true
        CLEAN_PYTHON_CACHE=true
        CLEAN_VENV=true
        CLEAN_LOGS=true
        CLEAN_UPLOADS=true
        CLEAN_BUILD=true
        ;;
    4)
        print_status "Performing nuclear cleanup..."
        CLEAN_NODE_MODULES=true
        CLEAN_PYTHON_CACHE=true
        CLEAN_VENV=true
        CLEAN_LOGS=true
        CLEAN_UPLOADS=true
        CLEAN_BUILD=true
        CLEAN_ENV=true
        ;;
    5)
        print_status "Custom cleanup selected..."
        confirm "Clean node_modules directories?" && CLEAN_NODE_MODULES=true
        confirm "Clean Python cache and __pycache__?" && CLEAN_PYTHON_CACHE=true
        confirm "Remove Python virtual environment?" && CLEAN_VENV=true
        confirm "Remove logs?" && CLEAN_LOGS=true
        confirm "Remove uploads?" && CLEAN_UPLOADS=true
        confirm "Remove build directories?" && CLEAN_BUILD=true
        confirm "Remove .env files?" && CLEAN_ENV=true
        ;;
    *)
        print_error "Invalid option selected"
        exit 1
        ;;
esac

# Perform cleanup based on selections
total_freed=0

# Clean node_modules
if [ "$CLEAN_NODE_MODULES" = true ]; then
    print_status "Removing node_modules directories..."
    
    # Root node_modules
    if [ -d "node_modules" ]; then
        size=$(du -sm node_modules 2>/dev/null | cut -f1 || echo "0")
        rm -rf node_modules
        total_freed=$((total_freed + size))
        print_success "Removed root node_modules (~${size}MB)"
    fi
    
    # Frontend node_modules
    if [ -d "frontend/node_modules" ]; then
        size=$(du -sm frontend/node_modules 2>/dev/null | cut -f1 || echo "0")
        rm -rf frontend/node_modules
        total_freed=$((total_freed + size))
        print_success "Removed frontend/node_modules (~${size}MB)"
    fi
    
    # Backend API node_modules
    if [ -d "backend/node-api/node_modules" ]; then
        size=$(du -sm backend/node-api/node_modules 2>/dev/null | cut -f1 || echo "0")
        rm -rf backend/node-api/node_modules
        total_freed=$((total_freed + size))
        print_success "Removed backend/node-api/node_modules (~${size}MB)"
    fi
    
    # Clean npm cache
    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force 2>/dev/null || true
        print_success "Cleaned npm cache"
    fi
fi

# Clean Python cache
if [ "$CLEAN_PYTHON_CACHE" = true ]; then
    print_status "Removing Python cache files..."
    
    # Remove __pycache__ directories
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    
    # Remove .pyc files
    find . -name "*.pyc" -delete 2>/dev/null || true
    
    # Remove .pyo files
    find . -name "*.pyo" -delete 2>/dev/null || true
    
    # Remove .pytest_cache
    find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
    
    print_success "Removed Python cache files"
fi

# Clean Python virtual environment
if [ "$CLEAN_VENV" = true ]; then
    print_status "Removing Python virtual environment..."
    
    if [ -d "backend/python-ai/venv" ]; then
        size=$(du -sm backend/python-ai/venv 2>/dev/null | cut -f1 || echo "0")
        rm -rf backend/python-ai/venv
        total_freed=$((total_freed + size))
        print_success "Removed Python virtual environment (~${size}MB)"
    fi
    
    # Clean pip cache
    if command -v pip >/dev/null 2>&1; then
        pip cache purge 2>/dev/null || true
        print_success "Cleaned pip cache"
    fi
fi

# Clean logs
if [ "$CLEAN_LOGS" = true ]; then
    print_status "Removing log files..."
    
    if [ -d "logs" ]; then
        rm -rf logs/*
        print_success "Removed log files"
    fi
fi

# Clean uploads
if [ "$CLEAN_UPLOADS" = true ]; then
    print_status "Removing uploaded files..."
    
    if [ -d "backend/node-api/uploads" ]; then
        # Keep directory structure but remove files
        find backend/node-api/uploads -type f -delete 2>/dev/null || true
        print_success "Removed uploaded files"
    fi
    
    # Clean temp files
    if [ -d "backend/python-ai/temp" ]; then
        rm -rf backend/python-ai/temp/*
        print_success "Removed temporary files"
    fi
fi

# Clean build directories
if [ "$CLEAN_BUILD" = true ]; then
    print_status "Removing build directories..."
    
    # Frontend build
    if [ -d "frontend/build" ]; then
        size=$(du -sm frontend/build 2>/dev/null | cut -f1 || echo "0")
        rm -rf frontend/build
        total_freed=$((total_freed + size))
        print_success "Removed frontend/build (~${size}MB)"
    fi
    
    # Remove .next (if using Next.js)
    if [ -d "frontend/.next" ]; then
        rm -rf frontend/.next
        print_success "Removed frontend/.next"
    fi
    
    # Remove dist directories
    find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
fi

# Clean .env files
if [ "$CLEAN_ENV" = true ]; then
    print_warning "Removing .env files..."
    
    if confirm "This will remove all .env configuration files. Continue?"; then
        find . -name ".env" -not -name ".env.example" -delete 2>/dev/null || true
        print_success "Removed .env files"
    else
        print_status "Skipped .env file removal"
    fi
fi

# Additional cleanup
print_status "Performing additional cleanup..."

# Remove package-lock.json files (optional)
if confirm "Remove package-lock.json files? (They will be regenerated on next install)"; then
    find . -name "package-lock.json" -delete 2>/dev/null || true
    print_success "Removed package-lock.json files"
fi

# Clean OS-specific files
case "$OSTYPE" in
    darwin*)
        # macOS
        find . -name ".DS_Store" -delete 2>/dev/null || true
        print_success "Removed .DS_Store files"
        ;;
    msys*|win32*)
        # Windows
        find . -name "Thumbs.db" -delete 2>/dev/null || true
        find . -name "desktop.ini" -delete 2>/dev/null || true
        print_success "Removed Windows system files"
        ;;
esac

# Remove IDE files (optional)
if confirm "Remove IDE configuration files? (.vscode, .idea, etc.)"; then
    rm -rf .vscode .idea *.code-workspace 2>/dev/null || true
    print_success "Removed IDE configuration files"
fi

# Final summary
echo ""
echo "🎉 Cleanup Complete!"
echo "==================="
echo ""
print_success "Total space freed: ~${total_freed}MB"
echo ""
echo "📋 What was cleaned:"
[ "$CLEAN_NODE_MODULES" = true ] && echo "   ✅ Node.js modules and npm cache"
[ "$CLEAN_PYTHON_CACHE" = true ] && echo "   ✅ Python cache files"
[ "$CLEAN_VENV" = true ] && echo "   ✅ Python virtual environment"
[ "$CLEAN_LOGS" = true ] && echo "   ✅ Log files"
[ "$CLEAN_UPLOADS" = true ] && echo "   ✅ Uploaded files and temp files"
[ "$CLEAN_BUILD" = true ] && echo "   ✅ Build directories"
[ "$CLEAN_ENV" = true ] && echo "   ✅ Environment configuration files"
echo ""
echo "🔄 To reinstall everything:"
echo "   ./scripts/install.sh"
echo ""
echo "🚀 To start fresh development:"
echo "   1. Run: ./scripts/install.sh"
echo "   2. Configure .env files"
echo "   3. Run: ./scripts/start.sh"
echo ""
print_success "System cleaned successfully! 🧹"
