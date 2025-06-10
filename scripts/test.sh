#!/bin/bash

# Video Summarizer Evaluation - Test Script
# This script runs all tests for the system

echo "🧪 Video Summarizer Evaluation - Test Suite"
echo "==========================================="

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

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    local test_dir="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    print_status "Running $test_name..."
    
    if [ -n "$test_dir" ]; then
        cd "$test_dir"
    fi
    
    if eval "$test_command"; then
        print_success "$test_name passed"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        print_error "$test_name failed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
    
    if [ -n "$test_dir" ]; then
        cd - >/dev/null
    fi
}

# Check if services are running
check_service() {
    local port=$1
    local service_name="$2"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Start services if not running
start_services_if_needed() {
    local need_ai=false
    local need_api=false
    
    print_status "Checking if services are running..."
    
    if ! check_service 5000 "AI Service"; then
        print_warning "AI Service not running, starting it..."
        need_ai=true
    fi
    
    if ! check_service 5001 "API Service"; then
        print_warning "API Service not running, starting it..."
        need_api=true
    fi
    
    if [ "$need_ai" = true ]; then
        print_status "Starting AI Service for testing..."
        cd backend/python-ai
        
        if [ ! -d "venv" ]; then
            print_error "Python virtual environment not found. Please run ./scripts/install.sh first."
            exit 1
        fi
        
        if [ "$IS_WINDOWS" = true ]; then
            source venv/Scripts/activate
        else
            source venv/bin/activate
        fi
        
        python app.py &
        AI_TEST_PID=$!
        cd ../..
        
        # Wait for service to start
        sleep 5
        
        if ! check_service 5000 "AI Service"; then
            print_error "Failed to start AI Service for testing"
            exit 1
        fi
        print_success "AI Service started for testing"
    fi
    
    if [ "$need_api" = true ]; then
        print_status "Starting API Service for testing..."
        cd backend/node-api
        
        if [ ! -d "node_modules" ]; then
            print_error "Node modules not found. Please run ./scripts/install.sh first."
            exit 1
        fi
        
        npm run dev &
        API_TEST_PID=$!
        cd ../..
        
        # Wait for service to start
        sleep 5
        
        if ! check_service 5001 "API Service"; then
            print_error "Failed to start API Service for testing"
            exit 1
        fi
        print_success "API Service started for testing"
    fi
}

# Cleanup function
cleanup_test_services() {
    if [ -n "$AI_TEST_PID" ]; then
        print_status "Stopping test AI Service..."
        kill $AI_TEST_PID 2>/dev/null || true
    fi
    
    if [ -n "$API_TEST_PID" ]; then
        print_status "Stopping test API Service..."
        kill $API_TEST_PID 2>/dev/null || true
    fi
}

# Set up cleanup on exit
trap cleanup_test_services EXIT

# Create test results directory
mkdir -p test-results

echo ""
echo "🔍 Test Categories:"
echo "=================="
echo "1. Unit Tests (Python AI)"
echo "2. Integration Tests (API)"
echo "3. Frontend Tests"
echo "4. End-to-End Tests"
echo "5. All Tests"
echo ""

read -p "Select test category (1-5): " test_category

case $test_category in
    1)
        print_status "Running Python AI Unit Tests..."
        TEST_PYTHON=true
        ;;
    2)
        print_status "Running API Integration Tests..."
        TEST_API=true
        ;;
    3)
        print_status "Running Frontend Tests..."
        TEST_FRONTEND=true
        ;;
    4)
        print_status "Running End-to-End Tests..."
        TEST_E2E=true
        ;;
    5)
        print_status "Running All Tests..."
        TEST_PYTHON=true
        TEST_API=true
        TEST_FRONTEND=true
        TEST_E2E=true
        ;;
    *)
        print_error "Invalid option selected"
        exit 1
        ;;
esac

# Start services if needed for integration tests
if [ "$TEST_API" = true ] || [ "$TEST_E2E" = true ]; then
    start_services_if_needed
fi

echo ""
echo "🧪 Running Tests..."
echo "=================="

# Python AI Tests
if [ "$TEST_PYTHON" = true ]; then
    echo ""
    print_status "🐍 Python AI Service Tests"
    echo "----------------------------"
    
    # Check if virtual environment exists
    if [ ! -d "backend/python-ai/venv" ]; then
        print_error "Python virtual environment not found. Please run ./scripts/install.sh first."
        exit 1
    fi
    
    cd backend/python-ai
    
    # Activate virtual environment
    if [ "$IS_WINDOWS" = true ]; then
        source venv/Scripts/activate
    else
        source venv/bin/activate
    fi
    
    # Test 1: Import test
    run_test "Python imports" "python -c 'from summary_evaluation import SummaryEvaluator; print(\"✅ Imports successful\")'"
    
    # Test 2: Model initialization
    run_test "Model initialization" "python -c 'from summary_evaluation import SummaryEvaluator; evaluator = SummaryEvaluator(); print(\"✅ Model initialized\")'"
    
    # Test 3: Basic evaluation
    run_test "Basic evaluation" "python -c 'from summary_evaluation import SummaryEvaluator; evaluator = SummaryEvaluator(); result = evaluator.evaluate_summary(\"Plants use sunlight\", \"Photosynthesis converts light to energy\"); print(f\"✅ Score: {result[\"similarity_score\"]}\")'"
    
    # Test 4: API endpoints (if service is running)
    if check_service 5000 "AI Service"; then
        run_test "API test script" "python test_api.py"
    else
        print_warning "AI Service not running, skipping API tests"
    fi
    
    cd ../..
fi

# API Integration Tests
if [ "$TEST_API" = true ]; then
    echo ""
    print_status "🔧 Node.js API Tests"
    echo "---------------------"
    
    cd backend/node-api
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        print_error "Node modules not found. Please run ./scripts/install.sh first."
        exit 1
    fi
    
    # Test 1: Dependencies check
    run_test "Dependencies check" "npm list --depth=0"
    
    # Test 2: Linting (if configured)
    if grep -q "lint" package.json; then
        run_test "Code linting" "npm run lint"
    fi
    
    # Test 3: Unit tests (if configured)
    if grep -q "test" package.json; then
        run_test "Unit tests" "npm test"
    fi
    
    # Test 4: API health check
    if check_service 5001 "API Service"; then
        run_test "API health check" "curl -f http://localhost:5001/health"
    fi
    
    cd ../..
fi

# Frontend Tests
if [ "$TEST_FRONTEND" = true ]; then
    echo ""
    print_status "🌐 Frontend Tests"
    echo "-----------------"
    
    cd frontend
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        print_error "Frontend node modules not found. Please run ./scripts/install.sh first."
        exit 1
    fi
    
    # Test 1: Dependencies check
    run_test "Frontend dependencies" "npm list --depth=0"
    
    # Test 2: Build test
    run_test "Frontend build" "npm run build"
    
    # Test 3: Unit tests
    run_test "Frontend unit tests" "npm test -- --watchAll=false --coverage"
    
    # Test 4: Linting (if configured)
    if grep -q "lint" package.json; then
        run_test "Frontend linting" "npm run lint"
    fi
    
    cd ..
fi

# End-to-End Tests
if [ "$TEST_E2E" = true ]; then
    echo ""
    print_status "🔄 End-to-End Tests"
    echo "-------------------"
    
    # Test 1: Full API workflow
    if check_service 5000 "AI Service" && check_service 5001 "API Service"; then
        print_status "Testing full evaluation workflow..."
        
        # Create a test evaluation request
        test_payload='{
            "user_text": "Plants use sunlight to make food through photosynthesis",
            "video_summary": "This video explains how plants convert sunlight into energy through the process of photosynthesis"
        }'
        
        if curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "$test_payload" \
            http://localhost:5000/evaluate-summary | grep -q "similarity_score"; then
            print_success "End-to-end evaluation workflow passed"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            print_error "End-to-end evaluation workflow failed"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    else
        print_warning "Services not running, skipping E2E tests"
    fi
fi

# Generate test report
echo ""
echo "📊 Test Results Summary"
echo "======================"
echo ""
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    print_success "🎉 All tests passed!"
    echo ""
    echo "✅ System is working correctly"
    echo "🚀 Ready for development/deployment"
else
    print_error "❌ Some tests failed"
    echo ""
    echo "🔍 Check the output above for details"
    echo "📝 Review logs in test-results/ directory"
    echo "🛠️  Fix issues and run tests again"
fi

# Save test results
cat > test-results/test-summary.txt << EOF
Video Summarizer Evaluation - Test Results
==========================================
Date: $(date)
Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

Test Categories Run:
$([ "$TEST_PYTHON" = true ] && echo "- Python AI Service Tests")
$([ "$TEST_API" = true ] && echo "- Node.js API Tests")
$([ "$TEST_FRONTEND" = true ] && echo "- Frontend Tests")
$([ "$TEST_E2E" = true ] && echo "- End-to-End Tests")
EOF

print_status "Test results saved to test-results/test-summary.txt"

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
    exit 0
else
    exit 1
fi
