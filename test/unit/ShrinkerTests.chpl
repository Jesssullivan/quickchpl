// quickchpl: Shrinker Unit Tests
// Tests for the shrinking engine

module ShrinkerTests {
  use quickchpl;
  use List;

  proc main() {
    writeln("quickchpl Shrinker Unit Tests");
    writeln("=" * 50);
    writeln();

    var passed = 0;
    var failed = 0;

    // Test integer shrinking
    writeln("Testing Integer Shrinking:");
    {
      // Shrinking 100 should include 0, 50, 25, etc.
      const candidates = shrinkInt(100);
      var has0 = false;
      var hasBinarySearch = false;

      for c in candidates {
        if c == 0 then has0 = true;
        if c == 50 then hasBinarySearch = true;
      }

      if has0 {
        writeln("  ✓ shrinkInt(100) includes 0");
        passed += 1;
      } else {
        writeln("  ✗ shrinkInt(100) should include 0");
        failed += 1;
      }

      if hasBinarySearch {
        writeln("  ✓ shrinkInt(100) includes 50 (binary search)");
        passed += 1;
      } else {
        writeln("  ✗ shrinkInt(100) should include 50");
        failed += 1;
      }

      // Shrinking 0 should return empty list
      const zeroShrinks = shrinkInt(0);
      if zeroShrinks.size == 0 {
        writeln("  ✓ shrinkInt(0) returns empty list");
        passed += 1;
      } else {
        writeln("  ✗ shrinkInt(0) should return empty list");
        failed += 1;
      }

      // Negative numbers
      const negCandidates = shrinkInt(-50);
      var hasNeg0 = false;
      for c in negCandidates {
        if c == 0 then hasNeg0 = true;
      }
      if hasNeg0 {
        writeln("  ✓ shrinkInt(-50) includes 0");
        passed += 1;
      } else {
        writeln("  ✗ shrinkInt(-50) should include 0");
        failed += 1;
      }
    }
    writeln();

    // Test real shrinking
    writeln("Testing Real Shrinking:");
    {
      const candidates = shrinkReal(3.14159);
      var has0 = false;
      var hasTruncated = false;

      for c in candidates {
        if c == 0.0 then has0 = true;
        if c == 3.0 then hasTruncated = true;
      }

      if has0 {
        writeln("  ✓ shrinkReal(3.14159) includes 0.0");
        passed += 1;
      } else {
        writeln("  ✗ shrinkReal(3.14159) should include 0.0");
        failed += 1;
      }

      if hasTruncated {
        writeln("  ✓ shrinkReal(3.14159) includes 3.0 (truncated)");
        passed += 1;
      } else {
        writeln("  ✗ shrinkReal(3.14159) should include 3.0");
        failed += 1;
      }
    }
    writeln();

    // Test boolean shrinking
    writeln("Testing Boolean Shrinking:");
    {
      const trueShrinks = shrinkBool(true);
      var hasFalse = false;
      for c in trueShrinks {
        if c == false then hasFalse = true;
      }

      if hasFalse {
        writeln("  ✓ shrinkBool(true) includes false");
        passed += 1;
      } else {
        writeln("  ✗ shrinkBool(true) should include false");
        failed += 1;
      }

      const falseShrinks = shrinkBool(false);
      if falseShrinks.size == 0 {
        writeln("  ✓ shrinkBool(false) returns empty list");
        passed += 1;
      } else {
        writeln("  ✗ shrinkBool(false) should return empty list");
        failed += 1;
      }
    }
    writeln();

    // Test string shrinking
    writeln("Testing String Shrinking:");
    {
      const candidates = shrinkString("hello");
      var hasEmpty = false;
      var hasPrefix = false;
      var hasSimplified = false;

      for c in candidates {
        if c == "" then hasEmpty = true;
        if c == "hell" then hasPrefix = true;
        if c == "aello" then hasSimplified = true;
      }

      if hasEmpty {
        writeln("  ✓ shrinkString(\"hello\") includes empty string");
        passed += 1;
      } else {
        writeln("  ✗ shrinkString(\"hello\") should include empty string");
        failed += 1;
      }

      if hasPrefix {
        writeln("  ✓ shrinkString(\"hello\") includes \"hell\" (prefix)");
        passed += 1;
      } else {
        writeln("  ✗ shrinkString(\"hello\") should include \"hell\"");
        failed += 1;
      }
    }
    writeln();

    // Test list shrinking
    writeln("Testing List Shrinking:");
    {
      var lst: list(int);
      lst.pushBack(10);
      lst.pushBack(20);
      lst.pushBack(30);

      const candidates = shrinkIntList(lst);
      var hasEmpty = false;
      var hasShorter = false;

      for c in candidates {
        if c.size == 0 then hasEmpty = true;
        if c.size == 2 then hasShorter = true;
      }

      if hasEmpty {
        writeln("  ✓ shrinkIntList([10,20,30]) includes empty list");
        passed += 1;
      } else {
        writeln("  ✗ shrinkIntList([10,20,30]) should include empty list");
        failed += 1;
      }

      if hasShorter {
        writeln("  ✓ shrinkIntList([10,20,30]) includes 2-element lists");
        passed += 1;
      } else {
        writeln("  ✗ shrinkIntList([10,20,30]) should include 2-element lists");
        failed += 1;
      }
    }
    writeln();

    // Test tuple shrinking
    writeln("Testing Tuple Shrinking:");
    {
      const candidates = shrinkIntTuple2((100, 200));
      var has0First = false;
      var has0Second = false;

      for (a, b) in candidates {
        if a == 0 then has0First = true;
        if b == 0 then has0Second = true;
      }

      if has0First {
        writeln("  ✓ shrinkIntTuple2((100,200)) includes (0, ...)");
        passed += 1;
      } else {
        writeln("  ✗ shrinkIntTuple2((100,200)) should include (0, ...)");
        failed += 1;
      }

      if has0Second {
        writeln("  ✓ shrinkIntTuple2((100,200)) includes (..., 0)");
        passed += 1;
      } else {
        writeln("  ✗ shrinkIntTuple2((100,200)) should include (..., 0)");
        failed += 1;
      }
    }
    writeln();

    // Test shrinking integration with property
    writeln("Testing Shrinking Integration:");
    {
      // Property that fails for numbers >= 10
      // Should shrink to 10
      const (shrunk, steps) = shrinkIntFailure(100, proc(x: int) { return x < 10; });

      if shrunk == 10 {
        writeln("  ✓ Shrinks 100 to 10 (minimal failing case)");
        passed += 1;
      } else {
        writeln("  ✗ Expected 10, got ", shrunk);
        failed += 1;
      }

      writeln("  (Shrinking took ", steps, " steps)");
    }
    writeln();

    // Summary
    writeln("=" * 50);
    writeln("Summary: ", passed, " passed, ", failed, " failed");
    if failed == 0 {
      writeln("All shrinker tests passed! ✓");
    } else {
      writeln("Some tests failed! ✗");
      halt(1);
    }
  }
}
