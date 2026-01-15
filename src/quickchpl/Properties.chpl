/*
  Properties Module
  =================

  Property definition, execution, and result handling for
  property-based testing.

  This module provides the core framework for defining and running properties.
  A property combines a generator with a predicate function, and the framework
  automatically generates test cases to verify the property holds.

  **Core Types:**

  - :record:`TestResult` - Results from running a property
  - :record:`Property` - Definition of a testable property
  - :record:`PropertyRunner` - Configurable test executor

  **Core Functions:**

  - :proc:`property` - Create a property from generator and predicate
  - :proc:`check` - Run a property and get results
  - :proc:`forAll` - Alternative syntax for property checking
  - :proc:`assertProperty` - Assert property holds or halt

  Example::

    use Properties;
    use Generators;

    // Define a property
    var prop = property("addition is commutative",
                        tupleGen(intGen(), intGen()),
                        lambda((a, b): (int, int)) { return a + b == b + a; });

    // Run the property
    var result = check(prop);
    writeln(result.passed);  // true
*/
module Properties {
  use Random;
  use List;
  use Time;
  use IO;

  /*
    Configuration Constants
    -----------------------

    Default settings for property testing. Override via command line.
  */

  /* Default number of test cases per property. */
  config const defaultNumTests = 100;

  /* Default maximum shrinking iterations. */
  config const defaultMaxShrinkSteps = 1000;

  /* Default timeout for shrinking (seconds). */
  config const defaultShrinkTimeout = 30.0;

  /* Default verbose mode setting. */
  config const defaultVerbose = false;

  /* Default parallel execution setting. */
  config const defaultParallel = false;

  /* Default random seed. */
  config const defaultSeed = -1;

  /*
    Test Result
    -----------

    Comprehensive result from running a property test.
  */

  /*
    Result of property testing.

    Contains all information about a property test run, including
    pass/fail status, test counts, timing, and counterexample info.

    :var passed: Whether all tests passed
    :var numTests: Total number of tests run
    :var numPassed: Number of passing tests
    :var numFailed: Number of failing tests
    :var propertyName: Name of the tested property
    :var failureInfo: String representation of first counterexample
    :var shrunkInfo: String representation of minimized counterexample
    :var shrinkSteps: Number of shrinking iterations performed
    :var duration: Execution time in seconds
  */
  record TestResult {
    var passed: bool;
    var numTests: int;
    var numPassed: int;
    var numFailed: int;
    var propertyName: string;
    var failureInfo: string;
    var shrunkInfo: string;
    var shrinkSteps: int;
    var duration: real;

    /*
      Create an empty test result (default: passing).
    */
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

    /*
      Create a test result with all fields specified.

      :arg passed: Whether all tests passed
      :arg numTests: Total tests run
      :arg numPassed: Passing test count
      :arg numFailed: Failing test count
      :arg propertyName: Name of property
      :arg failureInfo: First counterexample (if any)
      :arg shrunkInfo: Minimized counterexample (if any)
      :arg shrinkSteps: Shrinking iterations
      :arg duration: Execution time
    */
    proc init(passed: bool, numTests: int, numPassed: int,
              numFailed: int, propertyName: string,
              failureInfo: string = "", shrunkInfo: string = "",
              shrinkSteps: int = 0, duration: real = 0.0) {
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

  /*
    Property Record
    ---------------

    Definition of a testable property.
  */

  /*
    A property to be tested.

    Combines a name, generator, and predicate function.
    The predicate should return true for all valid inputs.

    :type GenType: Type of the generator
    :var name: Human-readable property name
    :var generator: Generator for test values
    :var predicateFn: Function returning bool for each test case
  */
  record Property {
    type GenType;
    var name: string;
    var generator: GenType;
    var predicateFn;

    /*
      Create a property.

      :arg name: Human-readable name for the property
      :arg generator: Generator for test values
      :arg predicateFn: Predicate function to test
    */
    proc init(name: string, generator, predicateFn) {
      this.GenType = generator.type;
      this.name = name;
      this.generator = generator;
      this.predicateFn = predicateFn;
    }
  }

  /*
    Create a property from a generator and predicate.

    :arg name: Human-readable property name
    :arg gen: Generator for test values
    :arg pred: Predicate function returning bool
    :returns: New Property ready for testing

    Example::

      var prop = property("x + 0 = x",
                          intGen(),
                          lambda(x: int) { return x + 0 == x; });
  */
  proc property(name: string, gen, pred) {
    return new Property(name, gen, pred);
  }

  /*
    Property Runner
    ---------------

    Configurable test executor with shrinking support.
  */

  /*
    Configurable property test runner.

    Executes property tests with customizable settings for
    test count, shrinking, verbosity, and parallelism.

    :var numTests: Number of test cases to generate
    :var maxShrinkSteps: Maximum shrinking iterations
    :var shrinkTimeout: Timeout for shrinking (seconds)
    :var verboseMode: Show each test case
    :var parallelMode: Run tests in parallel
    :var rngSeed: Random seed for reproducibility
  */
  record PropertyRunner {
    var numTests: int;
    var maxShrinkSteps: int;
    var shrinkTimeout: real;
    var verboseMode: bool;
    var parallelMode: bool;
    var rngSeed: int;

    /*
      Create a property runner with custom settings.

      :arg numTests: Test cases to generate (default: 100)
      :arg maxShrinkSteps: Max shrink iterations (default: 1000)
      :arg shrinkTimeout: Shrink timeout seconds (default: 30.0)
      :arg verboseMode: Show each test (default: false)
      :arg parallelMode: Parallel execution (default: false)
      :arg rngSeed: Random seed (default: -1 for random)
    */
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

    /*
      Run a property test.

      Generates test cases, runs the predicate, and reports results.
      Stops on first failure unless verboseMode is true.

      :arg prop: Property to test
      :returns: TestResult with pass/fail status and details
    */
    proc ref check(ref prop: Property(?)): TestResult {
      const startTime = timeSinceEpoch().totalSeconds();

      var passed = 0;
      var failed = 0;
      var firstFailure: string = "";
      var hasFailure = false;

      // Run tests sequentially (parallel requires careful handling)
      for i in 1..numTests {
        const testCase = prop.generator.next();

        try {
          if prop.predicateFn(testCase) {
            passed += 1;
            if verboseMode then writeln("  Test ", i, ": PASS");
          } else {
            failed += 1;
            if !hasFailure {
              try { firstFailure = "%?".format(testCase); }
              catch { firstFailure = "<value>"; }
              hasFailure = true;
            }
            if verboseMode then writeln("  Test ", i, ": FAIL - ", testCase);
            // Stop on first failure unless exhaustive mode
            if !verboseMode then break;
          }
        } catch e {
          failed += 1;
          if !hasFailure {
            try {
              firstFailure = "%? (exception: %s)".format(testCase,
                                                          e.message());
            }
            catch {
              firstFailure = "<value> (exception: " + e.message() + ")";
            }
            hasFailure = true;
          }
          if verboseMode then
            writeln("  Test ", i, ": EXCEPTION - ", e.message());
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

  /*
    Run a property with default configuration.

    :arg prop: Property to test
    :returns: TestResult with pass/fail status

    Example::

      var result = check(prop);
      if !result.passed {
        writeln("Failed: ", result.failureInfo);
      }
  */
  proc check(ref prop: Property(?)): TestResult {
    var runner = new PropertyRunner();
    return runner.check(prop);
  }

  /*
    Run a property with custom test count.

    :arg prop: Property to test
    :arg n: Number of test cases
    :returns: TestResult with pass/fail status
  */
  proc check(ref prop: Property(?), n: int): TestResult {
    var runner = new PropertyRunner(numTests = n);
    return runner.check(prop);
  }

  /*
    forAll - Alternative Property Syntax
    ------------------------------------

    More concise syntax for property checking.
  */

  /*
    Check a property using forAll syntax.

    Equivalent to ``check(property("forAll", gen, pred))``.

    :arg gen: Generator for test values
    :arg pred: Predicate function
    :returns: TestResult

    Example::

      var result = forAll(intGen(), lambda(x: int) { return x == x; });
  */
  proc forAll(gen, pred): TestResult {
    var prop = property("forAll", gen, pred);
    return check(prop);
  }

  /*
    Check a property with custom test count.

    :arg gen: Generator for test values
    :arg pred: Predicate function
    :arg n: Number of test cases
    :returns: TestResult
  */
  proc forAll(gen, pred, n: int): TestResult {
    var prop = property("forAll", gen, pred);
    return check(prop, n);
  }

  /*
    Assertion Helpers
    -----------------

    Halt execution if property fails.
  */

  /*
    Assert that a property holds.

    Halts with error message if property fails.

    :arg prop: Property to test
    :throws: Halts if property fails

    Example::

      // Test will halt if property fails
      assertProperty(prop);
  */
  proc assertProperty(ref prop: Property(?)) {
    const result = check(prop);
    if !result.passed {
      halt("Property failed: ", prop.name,
           "\n  Counterexample: ", result.failureInfo,
           "\n  Shrunk: ", result.shrunkInfo);
    }
  }

  /*
    Assert with custom test count.

    :arg prop: Property to test
    :arg n: Number of test cases
    :throws: Halts if property fails
  */
  proc assertProperty(ref prop: Property(?), n: int) {
    const result = check(prop, n);
    if !result.passed {
      halt("Property failed: ", prop.name,
           "\n  Counterexample: ", result.failureInfo,
           "\n  Shrunk: ", result.shrunkInfo);
    }
  }

  /*
    Property Combinators
    --------------------

    Combine multiple properties for complex testing.
  */

  /*
    Combined AND property.

    Represents the conjunction of two properties.
    Both must pass for the combined property to pass.

    :type Prop1Type: Type of first property
    :type Prop2Type: Type of second property
    :var prop1: First property
    :var prop2: Second property
    :var name: Combined name "prop1 AND prop2"
  */
  record AndProperty {
    type Prop1Type;
    type Prop2Type;
    var prop1: Prop1Type;
    var prop2: Prop2Type;
    var name: string;

    /*
      Create an AND combination of two properties.

      :arg prop1: First property
      :arg prop2: Second property
    */
    proc init(prop1, prop2) {
      this.Prop1Type = prop1.type;
      this.Prop2Type = prop2.type;
      this.prop1 = prop1;
      this.prop2 = prop2;
      this.name = prop1.name + " AND " + prop2.name;
    }
  }

  /*
    Run multiple properties and collect all results.

    :arg props: Iterable of properties to test
    :returns: List of TestResult for each property

    Example::

      var results = checkAll([prop1, prop2, prop3]);
      for result in results {
        writeln(result.propertyName, ": ", result.passed);
      }
  */
  proc checkAll(props): list(TestResult) {
    var results: list(TestResult);
    for prop in props {
      results.pushBack(check(prop));
    }
    return results;
  }

  /*
    Check if all results passed.

    :arg results: List of test results
    :returns: true if all results passed, false otherwise

    Example::

      var results = checkAll(props);
      if allPassed(results) {
        writeln("All properties verified!");
      }
  */
  proc allPassed(results: list(TestResult)): bool {
    for result in results {
      if !result.passed then return false;
    }
    return true;
  }
}
