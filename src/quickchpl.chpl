/*
  quickchpl: Property-Based Testing for Chapel
  =============================================

  A simple, friendly property-based testing (PBT) library combining
  QuickCheck-style property testing with Chapel's unique strengths.

  **Key Features:**

  - Zero-cost abstractions via value types (records)
  - Parallel test execution via forall
  - Type-safe generics with compile-time specialization
  - Intelligent shrinking for minimal counterexamples
  - Zero external dependencies

  **Quick Start:**

  .. code-block:: chapel

     use quickchpl;

     // Define a property
     var prop = property("addition is commutative",
                         tupleGen(intGen(), intGen()),
                         lambda((a, b): (int, int)) { return a + b == b + a; });

     // Check the property
     var result = check(prop);
     if !result.passed {
       writeln("Counterexample: ", result.failureInfo);
     }

  **Modules:**

  - :mod:`Generators` - Random value generators
  - :mod:`Properties` - Property definition and execution
  - :mod:`Shrinkers` - Counterexample minimization
  - :mod:`Reporters` - Test result formatting
  - :mod:`Combinators` - Generator composition
  - :mod:`Patterns` - Common property patterns

  :author: Jess Sullivan <jess@sulliwood.org>
  :version: 1.0.0
  :license: MIT
  :repository: https://github.com/Jesssullivan/chplcheck
*/
module quickchpl {
  /*
    Configuration Constants
    -----------------------

    These constants can be overridden via command-line arguments.

    Example::

      ./mytest --numTests=500 --verbose=true --seed=42
  */

  /* Number of test cases to generate per property. */
  config const numTests = 100;

  /* Maximum shrinking iterations when minimizing counterexamples. */
  config const maxShrinkSteps = 1000;

  /* Timeout in seconds for shrinking operations. */
  config const shrinkTimeout = 30.0;

  /* Enable verbose output showing each test case. */
  config const verbose = false;

  /* Enable parallel test execution (default: serial for reproducibility). */
  config const parallel = false;

  /* Random seed (-1 for random, or positive int for reproducibility). */
  config const seed = -1;

  // Public API: Re-export core modules
  public use Generators;
  public use Properties;
  public use Shrinkers;
  public use Reporters;
  public use Patterns;
  public use Combinators;

  /*
    Version Information
    -------------------

    Compile-time constants for version checking.
  */

  /* Full semantic version string. */
  param VERSION = "1.0.0";

  /* Major version number. */
  param VERSION_MAJOR = 1;

  /* Minor version number. */
  param VERSION_MINOR = 0;

  /* Patch version number. */
  param VERSION_PATCH = 0;

  /*
    Quick property check with default configuration.

    Convenience function for simple property testing. Returns true if
    all generated test cases pass the property.

    :arg gen: Generator for test values
    :arg prop: Predicate function to test
    :returns: true if property holds for all generated values

    Example::

      // Check that 0 is identity for addition
      assert(quickCheck(intGen(), lambda(x: int) { return x + 0 == x; }));
  */
  proc quickCheck(gen, prop): bool {
    var p = property("quickCheck", gen, prop);
    const result = check(p);
    return result.passed;
  }

  /*
    Quick property check with custom test count.

    :arg gen: Generator for test values
    :arg prop: Predicate function to test
    :arg n: Number of test cases to run
    :returns: true if property holds for all generated values

    Example::

      // Run 1000 tests instead of default 100
      assert(quickCheck(intGen(), lambda(x: int) { return x + 0 == x; }, 1000));
  */
  proc quickCheck(gen, prop, n: int): bool {
    var runner = new PropertyRunner(numTests = n);
    var p = property("quickCheck", gen, prop);
    const result = runner.check(p);
    return result.passed;
  }
}
