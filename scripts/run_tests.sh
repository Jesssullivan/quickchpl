#!/bin/bash
# quickchpl test runner script
# Usage: ./scripts/run_tests.sh [--fast] [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$PROJECT_DIR/src"
TEST_DIR="$PROJECT_DIR/tests"
EXAMPLES_DIR="$PROJECT_DIR/examples"

# Parse arguments
FAST=""
VERBOSE=""
for arg in "$@"; do
    case $arg in
        --fast)
            FAST="--fast"
            ;;
        --verbose)
            VERBOSE="--verbose=true"
            ;;
    esac
done

echo "=================================================="
echo "quickchpl Test Suite"
echo "=================================================="
echo ""

# Check Chapel is installed
if ! command -v chpl &> /dev/null; then
    echo "Error: Chapel compiler (chpl) not found"
    echo "Please install Chapel: https://chapel-lang.org/"
    exit 1
fi

echo "Chapel version: $(chpl --version | head -1)"
echo ""

# Create temp directory for binaries
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Run unit tests
echo "Running Unit Tests..."
echo "--------------------------------------------------"

echo "  Generator Tests..."
chpl $FAST "$TEST_DIR/unit/GeneratorTests.chpl" "$SRC_DIR"/*.chpl -o "$TMP_DIR/generator_tests"
"$TMP_DIR/generator_tests" $VERBOSE
echo ""

echo "  Shrinker Tests..."
chpl $FAST "$TEST_DIR/unit/ShrinkerTests.chpl" "$SRC_DIR"/*.chpl -o "$TMP_DIR/shrinker_tests"
"$TMP_DIR/shrinker_tests" $VERBOSE
echo ""

echo "  Property Tests..."
chpl $FAST "$TEST_DIR/unit/PropertyTests.chpl" "$SRC_DIR"/*.chpl -o "$TMP_DIR/property_tests"
"$TMP_DIR/property_tests" $VERBOSE
echo ""

# Run examples
echo "Running Examples..."
echo "--------------------------------------------------"

echo "  Getting Started..."
chpl $FAST "$EXAMPLES_DIR/GettingStarted.chpl" "$SRC_DIR"/*.chpl -o "$TMP_DIR/getting_started"
"$TMP_DIR/getting_started" $VERBOSE
echo ""

echo "  Algebraic Properties..."
chpl $FAST "$EXAMPLES_DIR/AlgebraicProperties.chpl" "$SRC_DIR"/*.chpl -o "$TMP_DIR/algebraic"
"$TMP_DIR/algebraic" $VERBOSE
echo ""

echo "  Custom Generators..."
chpl $FAST "$EXAMPLES_DIR/CustomGenerators.chpl" "$SRC_DIR"/*.chpl -o "$TMP_DIR/custom_gen"
"$TMP_DIR/custom_gen" $VERBOSE
echo ""

echo "=================================================="
echo "All tests completed successfully!"
echo "=================================================="
