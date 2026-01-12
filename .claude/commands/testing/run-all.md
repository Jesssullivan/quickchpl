Run comprehensive test suite for ChapelCheck.

Execute:
```bash
# Run all tests
echo "=== Running Unit Tests ===" && mason test tests/unit/ && \
echo "=== Running Property Tests ===" && mason test tests/properties/ && \
echo "=== Building Examples ===" && mason build --example && \
echo "=== Running Example: GettingStarted ===" && mason run --example GettingStarted && \
echo "=== All Tests Complete ==="
```

This comprehensive test run includes:
1. Unit tests for individual modules
2. Property-based self-tests
3. Example builds and executions
