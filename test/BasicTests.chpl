/*
  Basic unit tests for quickchpl library

  These tests verify the core functionality of the quickchpl
  property-based testing framework using Mason's test infrastructure.
*/
use quickchpl;
use Random;

proc main() {
  writeln("=== quickchpl Library Tests ===\n");

  var passed = 0;
  var failed = 0;

  // Test 1: Integer generator produces values in range
  {
    writeln("Test 1: Integer generator range");
    var gen = intGen(0, 100);
    var allInRange = true;
    for _unused in 1..20 {
      var val = gen.next();
      if val < 0 || val > 100 {
        allInRange = false;
        writeln("  FAIL: Generated ", val, " outside range [0, 100]");
        break;
      }
    }
    if allInRange {
      writeln("  PASS: All values in range");
      passed += 1;
    } else {
      failed += 1;
    }
  }

  // Test 2: Boolean generator produces both true and false
  {
    writeln("\nTest 2: Boolean generator coverage");
    var gen = boolGen();
    var sawTrue = false;
    var sawFalse = false;
    for _unused in 1..50 {
      var val = gen.next();
      if val then sawTrue = true;
      else sawFalse = true;
      if sawTrue && sawFalse then break;
    }
    if sawTrue && sawFalse {
      writeln("  PASS: Generated both true and false");
      passed += 1;
    } else {
      writeln("  FAIL: Didn't generate both values");
      failed += 1;
    }
  }

  // Test 3: Simple property check
  {
    writeln("\nTest 3: Property check - addition commutativity");
    var gen = tupleGen(intGen(-100, 100), intGen(-100, 100));
    var prop = property("addition is commutative", gen,
      proc(args: (int, int)) {
        const (a, b) = args;
        return a + b == b + a;
      });
    var result = check(prop);
    if result.passed {
      writeln("  PASS: Property holds for all test cases");
      passed += 1;
    } else {
      writeln("  FAIL: Found counterexample: ", result.failureInfo);
      failed += 1;
    }
  }

  // Test 4: quickCheck convenience function
  {
    writeln("\nTest 4: quickCheck convenience function");
    var gen = intGen(0, 100);
    var result = quickCheck(gen, proc(x: int) { return x >= 0 && x <= 100; });
    if result {
      writeln("  PASS: quickCheck works correctly");
      passed += 1;
    } else {
      writeln("  FAIL: quickCheck failed unexpectedly");
      failed += 1;
    }
  }

  // Test 5: List generator
  {
    writeln("\nTest 5: List generator");
    var elemGen = intGen(1, 10);
    var gen = listGen(elemGen, minSize=5, maxSize=5);
    var lst = gen.next();
    var correctSize = lst.size == 5;
    var allInRange = true;
    for elem in lst {
      if elem < 1 || elem > 10 {
        allInRange = false;
        break;
      }
    }
    if correctSize && allInRange {
      writeln("  PASS: List generator works correctly");
      passed += 1;
    } else {
      writeln("  FAIL: List generator issue");
      if !correctSize then writeln("    Size: ", lst.size, " != 5");
      if !allInRange then writeln("    Some elements out of range");
      failed += 1;
    }
  }

  // Summary
  writeln("\n=== Test Summary ===");
  writeln("Passed: ", passed);
  writeln("Failed: ", failed);
  writeln("Total:  ", passed + failed);

  if failed == 0 {
    writeln("\n✅ All tests passed!");
    return 0;
  } else {
    writeln("\n❌ Some tests failed");
    return 1;
  }
}
