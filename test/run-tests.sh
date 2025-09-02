#!/bin/bash

# Harpo Circuits Test Runner Script
# This script runs all circuit tests with proper setup and reporting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Harpo Circuits Test Suite${NC}"
echo "=================================="

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠️  Installing dependencies...${NC}"
    npm install
fi

# Create test results directory
mkdir -p test-results

# Function to run test category
run_test_category() {
    local category=$1
    local description=$2
    local timeout=$3
    
    echo -e "\n${BLUE}🧪 Running $description tests...${NC}"
    echo "-----------------------------------"
    
    if npm run test:$category 2>&1 | tee test-results/$category-results.log; then
        echo -e "${GREEN}✅ $description tests passed${NC}"
    else
        echo -e "${RED}❌ $description tests failed${NC}"
        echo "Check test-results/$category-results.log for details"
        return 1
    fi
}

# Function to compile circuits
compile_circuits() {
    echo -e "\n${BLUE}🔧 Compiling test circuits...${NC}"
    echo "-----------------------------------"
    
    # Compile utility circuits
    if [ -d "test/circuits/utility" ]; then
        for circuit in test/circuits/utility/*.circom; do
            if [ -f "$circuit" ]; then
                echo "Compiling $(basename $circuit)..."
                circom "$circuit" --r1cs --wasm --sym -o test/circuits/utility/ || echo "Warning: Failed to compile $circuit"
            fi
        done
    fi
    
    # Compile core circuits
    if [ -d "test/circuits/core" ]; then
        for circuit in test/circuits/core/*.circom; do
            if [ -f "$circuit" ]; then
                echo "Compiling $(basename $circuit)..."
                circom "$circuit" --r1cs --wasm --sym -o test/circuits/core/ || echo "Warning: Failed to compile $circuit"
            fi
        done
    fi
    
    # Compile integration circuits
    if [ -d "test/circuits/integration" ]; then
        for circuit in test/circuits/integration/*.circom; do
            if [ -f "$circuit" ]; then
                echo "Compiling $(basename $circuit)..."
                circom "$circuit" --r1cs --wasm --sym -o test/circuits/integration/ || echo "Warning: Failed to compile $circuit"
            fi
        done
    fi
    
    echo -e "${GREEN}✅ Circuit compilation completed${NC}"
}

# Function to check dependencies
check_dependencies() {
    echo -e "\n${BLUE}🔍 Checking dependencies...${NC}"
    echo "-----------------------------------"
    
    if ! command -v circom &> /dev/null; then
        echo -e "${RED}❌ circom not found. Please install circom first.${NC}"
        echo "Visit: https://docs.circom.io/getting-started/installation/"
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js not found. Please install Node.js first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All dependencies found${NC}"
}

# Main execution
main() {
    local test_type=${1:-"all"}
    local failed_tests=0
    
    check_dependencies
    
    if [ "$test_type" = "compile" ]; then
        compile_circuits
        exit 0
    fi
    
    # Compile circuits before testing
    compile_circuits
    
    case $test_type in
        "unit")
            run_test_category "" "Unit" 60000 || ((failed_tests++))
            ;;
        "integration")
            run_test_category "integration" "Integration" 120000 || ((failed_tests++))
            ;;
        "performance")
            run_test_category "performance" "Performance" 300000 || ((failed_tests++))
            ;;
        "all")
            echo -e "\n${BLUE}🎯 Running complete test suite...${NC}"
            run_test_category "" "Unit" 60000 || ((failed_tests++))
            run_test_category "integration" "Integration" 120000 || ((failed_tests++))
            ;;
        *)
            echo -e "${RED}❌ Unknown test type: $test_type${NC}"
            echo "Usage: $0 [unit|integration|performance|all|compile]"
            exit 1
            ;;
    esac
    
    # Summary
    echo -e "\n${BLUE}📊 Test Summary${NC}"
    echo "=================================="
    
    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
        exit 0
    else
        echo -e "${RED}💥 $failed_tests test categories failed${NC}"
        echo "Check individual test results in test-results/ directory"
        exit 1
    fi
}

# Handle script arguments
if [ "$#" -eq 0 ]; then
    main "all"
else
    main "$1"
fi