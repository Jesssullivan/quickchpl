// quickchpl: Property System Unit Tests
// Tests for property definition and test runner

module PropertyTests {
  use quickchpl;  // Import main module for quickCheck
  use List;

  config const numTests = 50;

  // Helper procs for property tests (intentionally ignore formal)
  @chplcheck.ignore("UnusedFormal")
  proc alwaysTrue(x: int) { return true; }

  @chplcheck.ignore("UnusedFormal")
  proc alwaysFalse(x: int) { return false; }

  proc main() {
    writeln("quickchpl Property System Unit Tests");
    writeln("=" * 50);
    writeln();

    var passed = 0;
    var failed = 0;

    // Test basic property that always passes
    writeln("Testing Basic Property (always passes):");
    {
      var gen = intGen(-100, 100);
      var prop = property("integers exist", gen, alwaysTrue);

      var result = check(prop, numTests);

      if result.passed {
        writeln("  ✓ Property passed as expected");
        passed += 1;
      } else {
        writeln("  ✗ Property should have passed");
        failed += 1;
      }

      if result.numTests == numTests {
        writeln("  ✓ Ran correct number of tests (", numTests, ")");
        passed += 1;
      } else {
        writeln("  ✗ Wrong test count: ", result.numTests);
        failed += 1;
      }
    }
    writeln();

    // Test property that always fails
    writeln("Testing Basic Property (always fails):");
    {
      var gen = intGen(1, 100);
      var prop = property(
        "all positive numbers are negative",
        gen,
        proc(x: int) { return x < 0; }
      );

      var result = check(prop, numTests);

      if !result.passed {
        writeln("  ✓ Property failed as expected");
        passed += 1;
      } else {
        writeln("  ✗ Property should have failed");
        failed += 1;
      }

      if result.numFailed > 0 {
        writeln("  ✓ Detected failures");
        passed += 1;
      } else {
        writeln("  ✗ Should have detected failures");
        failed += 1;
      }

      if result.failureInfo.size > 0 {
        writeln("  ✓ Captured counterexample: ", result.failureInfo);
        passed += 1;
      } else {
        writeln("  ✗ Should have captured counterexample");
        failed += 1;
      }
    }
    writeln();

    // Test implication function
    writeln("Testing Implication Function (implies):");
    {
      // If x > 0 then x + 1 > x
      // This is vacuously true for x <= 0
      var gen = intGen(-100, 100);
      var prop = property(
        "positive numbers can be incremented",
        gen,
        proc(x: int) { return implies(x > 0, x + 1 > x); }
      );

      var result = check(prop, numTests);

      if result.passed {
        writeln("  ✓ Implication property passed");
        passed += 1;
      } else {
        writeln("  ✗ Implication property should pass");
        failed += 1;
      }
    }
    writeln();

    // Test forAll convenience function
    writeln("Testing forAll convenience function:");
    {
      var gen = intGen(-100, 100);
      var result = forAll(gen, proc(x: int) { return x + 0 == x; }, numTests);

      if result.passed {
        writeln("  ✓ forAll returned passing result");
        passed += 1;
      } else {
        writeln("  ✗ forAll should have passed");
        failed += 1;
      }
    }
    writeln();

    // Test quickCheck convenience function
    writeln("Testing quickCheck convenience function:");
    {
      var gen = intGen(-100, 100);
      var quickResult = quickCheck(gen, proc(x: int) { return x * 1 == x; });

      if quickResult {
        writeln("  ✓ quickCheck returned true");
        passed += 1;
      } else {
        writeln("  ✗ quickCheck should have returned true");
        failed += 1;
      }

      var failResult = quickCheck(intGen(1, 100),
        proc(x: int) { return x < 0; });
      if !failResult {
        writeln("  ✓ quickCheck correctly returns false for failing property");
        passed += 1;
      } else {
        writeln("  ✗ quickCheck should have returned false");
        failed += 1;
      }
    }
    writeln();

    // Test property with tuple generator
    writeln("Testing Property with Tuple Generator:");
    {
      var gen = tupleGen(intGen(-50, 50), intGen(-50, 50));
      var prop = property(
        "addition is commutative",
        gen,
        proc(pair: (int, int)) {
          return pair(0) + pair(1) == pair(1) + pair(0);
        }
      );

      var result = check(prop, numTests);

      if result.passed {
        writeln("  ✓ Tuple property passed");
        passed += 1;
      } else {
        writeln("  ✗ Tuple property should pass");
        failed += 1;
      }
    }
    writeln();

    // Test property with string generator
    writeln("Testing Property with String Generator:");
    {
      var gen = stringGen(0, 20);
      var prop = property(
        "string length is non-negative",
        gen,
        proc(s: string) { return s.size >= 0; }
      );

      var result = check(prop, numTests);

      if result.passed {
        writeln("  ✓ String property passed");
        passed += 1;
      } else {
        writeln("  ✗ String property should pass");
        failed += 1;
      }
    }
    writeln();

    // Test TestResult structure
    writeln("Testing TestResult Structure:");
    {
      var gen = intGen(0, 10);
      var prop = property("test property", gen,
        proc(x: int) { return x >= 0; });
      var result = check(prop, 25);

      if result.propertyName == "test property" {
        writeln("  ✓ Property name captured correctly");
        passed += 1;
      } else {
        writeln("  ✗ Property name not captured");
        failed += 1;
      }

      if result.duration >= 0.0 {
        writeln("  ✓ Duration recorded (", result.duration, " sec)");
        passed += 1;
      } else {
        writeln("  ✗ Duration should be non-negative");
        failed += 1;
      }
    }
    writeln();

    // Test allPassed helper
    writeln("Testing allPassed helper:");
    {
      var results: list(TestResult);

      var r1 = new TestResult(passed=true, numTests=10,
        numPassed=10, numFailed=0, propertyName="p1");
      var r2 = new TestResult(passed=true, numTests=10,
        numPassed=10, numFailed=0, propertyName="p2");
      results.pushBack(r1);
      results.pushBack(r2);

      if allPassed(results) {
        writeln("  ✓ allPassed returns true when all pass");
        passed += 1;
      } else {
        writeln("  ✗ allPassed should return true");
        failed += 1;
      }

      var r3 = new TestResult(passed=false, numTests=10,
        numPassed=5, numFailed=5, propertyName="p3");
      results.pushBack(r3);

      if !allPassed(results) {
        writeln("  ✓ allPassed returns false when any fails");
        passed += 1;
      } else {
        writeln("  ✗ allPassed should return false");
        failed += 1;
      }
    }
    writeln();

    // Summary
    writeln("=" * 50);
    writeln("Summary: ", passed, " passed, ", failed, " failed");
    if failed == 0 {
      writeln("All property tests passed! ✓");
    } else {
      writeln("Some tests failed! ✗");
      halt(1);
    }
  }
}
