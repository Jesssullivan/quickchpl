// quickchpl: Generator Unit Tests
// Tests for the generator framework

module GeneratorTests {
  use Generators;
  use Combinators;
  use List;

  config const numTests = 100;
  config const seed = 42;  // Fixed seed for reproducibility

  proc main() {
    writeln("quickchpl Generator Unit Tests");
    writeln("=" * 50);
    writeln();

    var passed = 0;
    var failed = 0;

    // Test IntGenerator
    writeln("Testing IntGenerator:");
    {
      var gen = intGen(-100, 100, seed);
      var inRange = true;
      var sawDifferent = false;
      var first = gen.next();

      for i in 1..numTests {
        const value = gen.next();
        if value < -100 || value > 100 then inRange = false;
        if value != first then sawDifferent = true;
      }

      if inRange {
        writeln("  ✓ Values in range [-100, 100]");
        passed += 1;
      } else {
        writeln("  ✗ Values out of range!");
        failed += 1;
      }

      if sawDifferent {
        writeln("  ✓ Generates different values");
        passed += 1;
      } else {
        writeln("  ✗ Always generates same value!");
        failed += 1;
      }
    }
    writeln();

    // Test RealGenerator
    writeln("Testing RealGenerator:");
    {
      var gen = realGen(0.0, 1.0, Distribution.Uniform, seed);
      var inRange = true;

      for i in 1..numTests {
        const value = gen.next();
        if value < 0.0 || value >= 1.0 then inRange = false;
      }

      if inRange {
        writeln("  ✓ Values in range [0.0, 1.0)");
        passed += 1;
      } else {
        writeln("  ✗ Values out of range!");
        failed += 1;
      }
    }
    writeln();

    // Test BoolGenerator
    writeln("Testing BoolGenerator:");
    {
      var gen = boolGen(0.5, seed);
      var trueCount = 0;
      var falseCount = 0;

      for i in 1..1000 {
        if gen.next() then trueCount += 1;
        else falseCount += 1;
      }

      // With p=0.5, expect roughly 50% each (allow 30-70%)
      const trueRatio = trueCount: real / 1000.0;
      if trueRatio >= 0.3 && trueRatio <= 0.7 {
        writeln("  ✓ Reasonable true/false distribution (", trueCount, "/", falseCount, ")");
        passed += 1;
      } else {
        writeln("  ✗ Biased distribution (", trueCount, "/", falseCount, ")");
        failed += 1;
      }
    }
    writeln();

    // Test StringGenerator
    writeln("Testing StringGenerator:");
    {
      var gen = stringGen(5, 10, "abc", seed);
      var validLength = true;
      var validChars = true;

      for i in 1..numTests {
        const value = gen.next();
        if value.size < 5 || value.size > 10 then validLength = false;
        for c in value {
          if c != "a" && c != "b" && c != "c" then validChars = false;
        }
      }

      if validLength {
        writeln("  ✓ String lengths in range [5, 10]");
        passed += 1;
      } else {
        writeln("  ✗ String lengths out of range!");
        failed += 1;
      }

      if validChars {
        writeln("  ✓ String contains only specified chars");
        passed += 1;
      } else {
        writeln("  ✗ String contains invalid chars!");
        failed += 1;
      }
    }
    writeln();

    // Test TupleGenerator
    writeln("Testing TupleGenerator:");
    {
      var gen = tupleGen(intGen(0, 10, seed), intGen(100, 200, seed + 1));
      var valid = true;

      for i in 1..numTests {
        const (a, b) = gen.next();
        if a < 0 || a > 10 then valid = false;
        if b < 100 || b > 200 then valid = false;
      }

      if valid {
        writeln("  ✓ Tuple elements in expected ranges");
        passed += 1;
      } else {
        writeln("  ✗ Tuple elements out of range!");
        failed += 1;
      }
    }
    writeln();

    // Test ListGenerator
    writeln("Testing ListGenerator:");
    {
      var gen = listGen(intGen(0, 10, seed), 3, 7, seed);
      var validSizes = true;

      for i in 1..numTests {
        const lst = gen.next();
        if lst.size < 3 || lst.size > 7 then validSizes = false;
      }

      if validSizes {
        writeln("  ✓ List sizes in range [3, 7]");
        passed += 1;
      } else {
        writeln("  ✗ List sizes out of range!");
        failed += 1;
      }
    }
    writeln();

    // Test ConstantGenerator
    writeln("Testing ConstantGenerator:");
    {
      var gen = constantGen(42);
      var allSame = true;

      for i in 1..numTests {
        if gen.next() != 42 then allSame = false;
      }

      if allSame {
        writeln("  ✓ Always returns constant value");
        passed += 1;
      } else {
        writeln("  ✗ Returns different values!");
        failed += 1;
      }
    }
    writeln();

    // Test map combinator
    writeln("Testing map combinator:");
    {
      var baseGen = intGen(1, 10, seed);
      var doubledGen = map(baseGen, proc(x: int) { return x * 2; });
      var allEven = true;

      for i in 1..numTests {
        const value = doubledGen.next();
        if value % 2 != 0 then allEven = false;
      }

      if allEven {
        writeln("  ✓ map correctly doubles values");
        passed += 1;
      } else {
        writeln("  ✗ map produces odd values!");
        failed += 1;
      }
    }
    writeln();

    // Test filter combinator
    writeln("Testing filter combinator:");
    {
      var baseGen = intGen(-100, 100, seed);
      var positiveGen = filter(baseGen, proc(x: int) { return x > 0; });
      var allPositive = true;

      for i in 1..numTests {
        const value = positiveGen.next();
        if value <= 0 then allPositive = false;
      }

      if allPositive {
        writeln("  ✓ filter correctly selects positive values");
        passed += 1;
      } else {
        writeln("  ✗ filter produces non-positive values!");
        failed += 1;
      }
    }
    writeln();

    // Test zip combinator
    writeln("Testing zipGen combinator:");
    {
      var gen1 = intGen(0, 10, seed);
      var gen2 = stringGen(1, 3, "x", seed);
      var zippedGen = zipGen(gen1, gen2);
      var valid = true;

      for i in 1..numTests {
        const (n, s) = zippedGen.next();
        if n < 0 || n > 10 then valid = false;
        if s.size < 1 || s.size > 3 then valid = false;
      }

      if valid {
        writeln("  ✓ zip correctly combines generators");
        passed += 1;
      } else {
        writeln("  ✗ zip produces invalid values!");
        failed += 1;
      }
    }
    writeln();

    // Summary
    writeln("=" * 50);
    writeln("Summary: ", passed, " passed, ", failed, " failed");
    if failed == 0 {
      writeln("All generator tests passed! ✓");
    } else {
      writeln("Some tests failed! ✗");
      halt(1);
    }
  }
}
