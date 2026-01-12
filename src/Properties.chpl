// quickchpl: Property Definition and Test Runner
// Provides property definition, execution, and result handling

module Properties {
  use Random;
  use List;
  use Time;

  // Configuration (local defaults, can be overridden)
  config const defaultNumTests = 100;
  config const defaultMaxShrinkSteps = 1000;
  config const defaultShrinkTimeout = 30.0;
  config const defaultVerbose = false;
  config const defaultParallel = false;
  config const defaultSeed = -1;

  //============================================================================
  // Test Result
  //============================================================================

  record TestResult {
    var passed: bool;
    var numTests: int;
    var numPassed: int;
    var numFailed: int;
    var propertyName: string;
    var failureInfo: string;  // String representation of counterexample
    var shrunkInfo: string;   // String representation of shrunk counterexample
    var shrinkSteps: int;
    var duration: real;       // Execution time in seconds

    proc init() {
      this.passed = true;
      this.numTests = 0;
      this.numPassed = 0;
      this.numFailed = 0;
      this.propertyName = "";
      this.failureInfo = "";
      this.shrunkInfo = "";
      this.shrinkSteps = 0;
      this.duration = 0.0;
    }

    proc init(passed: bool, numTests: int, numPassed: int, numFailed: int,
              propertyName: string, failureInfo: string = "",
              shrunkInfo: string = "", shrinkSteps: int = 0, duration: real = 0.0) {
      this.passed = passed;
      this.numTests = numTests;
      this.numPassed = numPassed;
      this.numFailed = numFailed;
      this.propertyName = propertyName;
      this.failureInfo = failureInfo;
      this.shrunkInfo = shrunkInfo;
      this.shrinkSteps = shrinkSteps;
      this.duration = duration;
    }
  }

  //============================================================================
  // Property Record
  //============================================================================

  record Property {
    type GenType;
    var name: string;
    var generator: GenType;
    var predicateFn;

    proc init(name: string, generator, predicateFn) {
      this.GenType = generator.type;
      this.name = name;
      this.generator = generator;
      this.predicateFn = predicateFn;
    }
  }

  // Factory function for creating properties
  proc property(name: string, gen, pred) {
    return new Property(name, gen, pred);
  }

  //============================================================================
  // Property Runner
  //============================================================================

  record PropertyRunner {
    var numTests: int;
    var maxShrinkSteps: int;
    var shrinkTimeout: real;
    var verboseMode: bool;
    var parallelMode: bool;
    var rngSeed: int;

    proc init(numTests: int = defaultNumTests,
              maxShrinkSteps: int = defaultMaxShrinkSteps,
              shrinkTimeout: real = defaultShrinkTimeout,
              verboseMode: bool = defaultVerbose,
              parallelMode: bool = defaultParallel,
              rngSeed: int = defaultSeed) {
      this.numTests = numTests;
      this.maxShrinkSteps = maxShrinkSteps;
      this.shrinkTimeout = shrinkTimeout;
      this.verboseMode = verboseMode;
      this.parallelMode = parallelMode;
      this.rngSeed = rngSeed;
    }

    proc ref check(ref prop: Property): TestResult {
      const startTime = timeSinceEpoch().totalSeconds();

      var passed = 0;
      var failed = 0;
      var firstFailure: string = "";
      var hasFailure = false;

      // Run tests sequentially for now (parallel requires more careful handling)
      for i in 1..numTests {
        const testCase = prop.generator.next();

        try {
          if prop.predicateFn(testCase) {
            passed += 1;
            if verboseMode then writeln("  Test ", i, ": PASS");
          } else {
            failed += 1;
            if !hasFailure {
              firstFailure = testCase: string;
              hasFailure = true;
            }
            if verboseMode then writeln("  Test ", i, ": FAIL - ", testCase);
            // Stop on first failure unless exhaustive mode
            if !verboseMode then break;
          }
        } catch e {
          failed += 1;
          if !hasFailure {
            firstFailure = testCase: string + " (exception: " + e.message() + ")";
            hasFailure = true;
          }
          if verboseMode then writeln("  Test ", i, ": EXCEPTION - ", e.message());
          if !verboseMode then break;
        }
      }

      const endTime = timeSinceEpoch().totalSeconds();
      const duration = endTime - startTime;

      // Shrink if we have a failure
      var shrunkInfo = "";
      var shrinkSteps = 0;
      if hasFailure {
        // Attempt to shrink the failure
        // For now, just report the original (shrinking added later)
        shrunkInfo = firstFailure;  // Will be replaced with shrunk value
      }

      return new TestResult(
        passed = (failed == 0),
        numTests = passed + failed,
        numPassed = passed,
        numFailed = failed,
        propertyName = prop.name,
        failureInfo = firstFailure,
        shrunkInfo = shrunkInfo,
        shrinkSteps = shrinkSteps,
        duration = duration
      );
    }
  }

  // Global check function using default configuration
  proc check(ref prop: Property): TestResult {
    var runner = new PropertyRunner();
    return runner.check(prop);
  }

  // Check with custom number of tests
  proc check(ref prop: Property, n: int): TestResult {
    var runner = new PropertyRunner(numTests = n);
    return runner.check(prop);
  }

  //============================================================================
  // Implication Function (for conditional properties)
  //============================================================================
  // Note: implies() is defined in Patterns module
  //============================================================================
  // forAll - alternative property syntax
  //============================================================================

  // forAll(gen, pred) is equivalent to check(property("anonymous", gen, pred))
  proc forAll(gen, pred): TestResult {
    var prop = property("forAll", gen, pred);
    return check(prop);
  }

  proc forAll(gen, pred, n: int): TestResult {
    var prop = property("forAll", gen, pred);
    return check(prop, n);
  }

  //============================================================================
  // Assertion Helpers
  //============================================================================

  // Assert that a property holds
  proc assertProperty(ref prop: Property) {
    const result = check(prop);
    if !result.passed {
      halt("Property failed: ", prop.name,
           "\n  Counterexample: ", result.failureInfo,
           "\n  Shrunk: ", result.shrunkInfo);
    }
  }

  // Assert that a property holds with custom test count
  proc assertProperty(ref prop: Property, n: int) {
    const result = check(prop, n);
    if !result.passed {
      halt("Property failed: ", prop.name,
           "\n  Counterexample: ", result.failureInfo,
           "\n  Shrunk: ", result.shrunkInfo);
    }
  }

  //============================================================================
  // Property Combinators
  //============================================================================

  // Combine two properties with AND
  record AndProperty {
    type Prop1Type;
    type Prop2Type;
    var prop1: Prop1Type;
    var prop2: Prop2Type;
    var name: string;

    proc init(prop1, prop2) {
      this.Prop1Type = prop1.type;
      this.Prop2Type = prop2.type;
      this.prop1 = prop1;
      this.prop2 = prop2;
      this.name = prop1.name + " AND " + prop2.name;
    }
  }

  // Run multiple properties and collect results
  proc checkAll(props): list(TestResult) {
    var results: list(TestResult);
    for prop in props {
      results.pushBack(check(prop));
    }
    return results;
  }

  // Check if all results passed
  proc allPassed(results: list(TestResult)): bool {
    for result in results {
      if !result.passed then return false;
    }
    return true;
  }
}
