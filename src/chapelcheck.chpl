// quickchpl: Property-Based Testing for Chapel
// https://gitlab.com/tinyland/projects/quickchpl
//
// A comprehensive, production-grade property-based testing (PBT) library
// combining QuickCheck-style property testing with Chapel's unique strengths:
// - Zero-cost abstractions via value types (records)
// - Parallel test execution via forall
// - Type-safe generics with compile-time specialization
// - Intelligent shrinking for minimal counterexamples

module quickchpl {
  // Configuration via Chapel idioms (command-line configurable)
  config const numTests = 100;
  config const maxShrinkSteps = 1000;
  config const shrinkTimeout = 30.0;  // seconds
  config const verbose = false;
  config const parallel = false;  // Default to serial for reproducibility
  config const seed = -1;  // -1 = random seed

  // Public API: Re-export core modules
  public use Generators;
  public use Properties;
  public use Shrinkers;
  public use Reporters;
  public use Patterns;
  public use Combinators;

  // Version information
  param VERSION = "1.0.0";
  param VERSION_MAJOR = 1;
  param VERSION_MINOR = 0;
  param VERSION_PATCH = 0;

  // Convenience function for quick property checking
  // Usage: assert(quickCheck(intGen(), (x) => x + 0 == x));
  proc quickCheck(gen, prop): bool {
    const result = check(property("quickCheck", gen, prop));
    return result.passed;
  }

  // Convenience function with custom test count
  proc quickCheck(gen, prop, n: int): bool {
    var runner = new PropertyRunner(numTests = n);
    const result = runner.check(property("quickCheck", gen, prop));
    return result.passed;
  }
}
