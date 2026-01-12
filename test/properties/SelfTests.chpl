// quickchpl: Self-Tests
// quickchpl testing itself using property-based testing!

module SelfTests {
  use Generators;
  use Combinators;
  use Properties;
  use Shrinkers;
  use Patterns;
  use List;

  proc main() {
    writeln("quickchpl Self-Tests (PBT on PBT!)");
    writeln("=" * 50);
    writeln();

    var passed = 0;
    var failed = 0;

    // Property 1: Generators produce values in range
    writeln("Property 1: IntGenerator produces values in range");
    {
      var gen = intGen(0, 100);
      var prop = property(
        "intGen(0,100) produces values in [0,100]",
        gen,
        proc(x: int) { return x >= 0 && x <= 100; }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 2: String generator produces correct lengths
    writeln("Property 2: StringGenerator produces correct lengths");
    {
      var gen = stringGen(5, 15);
      var prop = property(
        "stringGen(5,15) produces lengths in [5,15]",
        gen,
        proc(s: string) { return s.size >= 5 && s.size <= 15; }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 3: map preserves generator semantics
    writeln("Property 3: map combinator works correctly");
    {
      var baseGen = intGen(1, 100);
      var mappedGen = map(baseGen, proc(x: int) { return x * 2; });
      var prop = property(
        "map(x*2) produces even numbers",
        mappedGen,
        proc(x: int) { return x % 2 == 0 && x >= 2 && x <= 200; }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 4: filter only produces matching values
    writeln("Property 4: filter combinator works correctly");
    {
      var baseGen = intGen(-100, 100);
      var filteredGen = filter(baseGen, proc(x: int) { return x > 0; });
      var prop = property(
        "filter(x>0) produces positive numbers",
        filteredGen,
        proc(x: int) { return x > 0; }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 5: zipGen produces pairs
    writeln("Property 5: zipGen combinator works correctly");
    {
      var gen1 = intGen(0, 50);
      var gen2 = intGen(100, 150);
      var zippedGen = zipGen(gen1, gen2);
      var prop = property(
        "zip produces valid pairs",
        zippedGen,
        proc(pair: (int, int)) {
          return pair(0) >= 0 && pair(0) <= 50 && pair(1) >= 100 && pair(1) <= 150;
        }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 6: shrinkInt always produces smaller values
    writeln("Property 6: shrinkInt produces smaller values");
    {
      var gen = intGen(10, 1000);
      var prop = property(
        "shrinkInt(x) contains values smaller than x",
        gen,
        proc(x: int) {
          const candidates = shrinkInt(x);
          for c in candidates {
            if abs(c) < abs(x) then return true;
          }
          return candidates.size == 0;  // Only valid if no candidates
        }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 7: shrinkInt(0) returns empty list
    writeln("Property 7: shrinkInt(0) returns empty list");
    {
      var gen = constantGen(0);
      var prop = property(
        "shrinkInt(0) is empty",
        gen,
        proc(x: int) {
          return shrinkInt(x).size == 0;
        }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 8: Implication function works
    writeln("Property 8: Implication function semantics");
    {
      var gen = tupleGen(boolGen(), boolGen());
      var prop = property(
        "false implies anything is true",
        gen,
        proc(pair: (bool, bool)) {
          const cond = pair(0);
          const concl = pair(1);
          // If cond is false, implication should be true
          if !cond then return implies(cond, concl) == true;
          // If cond is true, implication equals conclusion
          else return implies(cond, concl) == concl;
        }
      );
      var result = check(prop);
      if result.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: ", result.failureInfo);
        failed += 1;
      }
    }
    writeln();

    // Property 9: TestResult correctly tracks pass/fail
    writeln("Property 9: check() correctly reports results");
    {
      // A property that always passes should report passed=true
      var passingGen = intGen(-100, 100);
      var passingProp = property("always true", passingGen, proc(x: int) { return true; });
      var passingResult = check(passingProp, 50);

      // A property that always fails should report passed=false
      var failingGen = intGen(1, 100);
      var failingProp = property("always false", failingGen, proc(x: int) { return false; });
      var failingResult = check(failingProp, 50);

      if passingResult.passed && !failingResult.passed {
        writeln("  ✓ PASSED");
        passed += 1;
      } else {
        writeln("  ✗ FAILED: passingResult.passed=", passingResult.passed,
                ", failingResult.passed=", failingResult.passed);
        failed += 1;
      }
    }
    writeln();

    // Property 10: List generator produces correct sizes
    // NOTE: Commented out due to Chapel generic lambda limitation
    // TODO: Fix when Chapel supports generic captures in lambdas
    writeln("Property 10: ListGenerator (SKIPPED - generic lambda limitation)");
    // {
    //   var gen = listGen(intGen(0, 10), 3, 8);
    //   var prop = property(
    //     "listGen(3,8) produces sizes in [3,8]",
    //     gen,
    //     proc(lst: list(int)) { return lst.size >= 3 && lst.size <= 8; }
    //   );
    //   var result = check(prop);
    //   if result.passed {
    //     writeln("  ✓ PASSED");
    //     passed += 1;
    //   } else {
    //     writeln("  ✗ FAILED: ", result.failureInfo);
    //     failed += 1;
    //   }
    // }
    writeln();

    // Summary
    writeln("=" * 50);
    writeln("Self-Test Summary: ", passed, " passed, ", failed, " failed");
    if failed == 0 {
      writeln("All self-tests passed! quickchpl is working correctly. ✓");
    } else {
      writeln("Some self-tests failed! ✗");
      halt(1);
    }
  }
}
