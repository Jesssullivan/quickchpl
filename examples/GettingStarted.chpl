// quickchpl: Getting Started Example
// This example demonstrates basic property-based testing with quickchpl

module GettingStarted {
  use quickchpl;

  proc main() {
    writeln("quickchpl Getting Started Example");
    writeln("=" * 50);
    writeln();

    // Example 1: Simple property - addition is commutative
    writeln("Example 1: Commutativity of addition");
    {
      var gen = tupleGen(intGen(-100, 100), intGen(-100, 100));
      var prop = property(
        "addition is commutative",
        gen,
        proc(args: (int, int)) { const (a, b) = args; return a + b == b + a; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 2: Associativity of multiplication
    writeln("Example 2: Associativity of multiplication");
    {
      var gen = tupleGen(intGen(-10, 10), intGen(-10, 10), intGen(-10, 10));
      var prop = property(
        "multiplication is associative",
        gen,
        proc(args: (int, int, int)) {
          const (a, b, c) = args;
          return (a * b) * c == a * (b * c);
        }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 3: Identity element
    writeln("Example 3: Zero is additive identity");
    {
      var gen = intGen(-1000, 1000);
      var prop = property(
        "zero is additive identity",
        gen,
        proc(x: int) { return x + 0 == x && 0 + x == x; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 4: Absolute value is non-negative
    writeln("Example 4: Absolute value is non-negative");
    {
      var gen = intGen(-1000000, 1000000);
      var prop = property(
        "abs(x) >= 0",
        gen,
        proc(x: int) { return abs(x) >= 0; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 5: String length is non-negative
    writeln("Example 5: String length is non-negative");
    {
      var gen = stringGen(0, 50);
      var prop = property(
        "string length >= 0",
        gen,
        proc(s: string) { return s.size >= 0; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 6: Using generator composition (map)
    writeln("Example 6: Squares are non-negative (using map)");
    {
      // Map transforms integers to their squares
      var squareGen = map(intGen(-100, 100), proc(x: int) { return x * x; });
      var prop = property(
        "squares are non-negative",
        squareGen,
        proc(sq: int) { return sq >= 0; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 7: Using filter for even numbers
    writeln("Example 7: Even numbers are divisible by 2");
    {
      var evenGen = filter(intGen(-100, 100),
                            proc(x: int) { return x % 2 == 0; });
      var prop = property(
        "even numbers divisible by 2",
        evenGen,
        proc(x: int) { return x % 2 == 0; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 8: Property that will fail (for demonstration)
    writeln("Example 8: Demonstrating failure detection");
    {
      var gen = intGen(1, 100);
      var prop = property(
        "all numbers are less than 50 (WILL FAIL)",
        gen,
        proc(x: int) { return x < 50; }
      );

      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests,
                  result.failureInfo, result.shrunkInfo);
    }
    writeln();

    // Example 9: Using quickCheck convenience function
    writeln("Example 9: Using quickCheck convenience function");
    {
      const passed = quickCheck(
        intGen(-100, 100),
        proc(x: int) { return x + (-x) == 0; }
      );
      writeln("  x + (-x) == 0: ", if passed then "PASSED" else "FAILED");
    }
    writeln();

    writeln("=" * 50);
    writeln("Examples complete!");
  }
}
