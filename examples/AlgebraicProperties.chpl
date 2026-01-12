// quickchpl: Algebraic Properties Example
// Demonstrates testing algebraic laws using the Patterns library

module AlgebraicProperties {
  use Generators;
  use Combinators;
  use Properties;
  use Reporters;
  use Patterns;

  proc main() {
    writeln("quickchpl Algebraic Properties Example");
    writeln("=" * 50);
    writeln();

    // Test properties of integer addition
    writeln("Testing Integer Addition Properties:");
    writeln("-" * 40);

    {
      var gen = intGen(-100, 100);

      // Commutativity: a + b = b + a
      var commProp = commutativeProperty("integer addition", gen,
        proc(a: int, b: int) { return a + b; });
      var result1 = check(commProp);
      printResult(result1.passed, commProp.name, result1.numTests);

      // Associativity: (a + b) + c = a + (b + c)
      var assocProp = associativeProperty("integer addition", gen,
        proc(a: int, b: int) { return a + b; });
      var result2 = check(assocProp);
      printResult(result2.passed, assocProp.name, result2.numTests);

      // Identity: a + 0 = a
      var idProp = identityProperty("integer addition", gen,
        proc(a: int, b: int) { return a + b; }, 0);
      var result3 = check(idProp);
      printResult(result3.passed, idProp.name, result3.numTests);
    }
    writeln();

    // Test properties of integer multiplication
    writeln("Testing Integer Multiplication Properties:");
    writeln("-" * 40);

    {
      var gen = intGen(-10, 10);  // Smaller range to avoid overflow

      // Commutativity: a * b = b * a
      var commProp = commutativeProperty("integer multiplication", gen,
        proc(a: int, b: int) { return a * b; });
      var result1 = check(commProp);
      printResult(result1.passed, commProp.name, result1.numTests);

      // Associativity: (a * b) * c = a * (b * c)
      var assocProp = associativeProperty("integer multiplication", gen,
        proc(a: int, b: int) { return a * b; });
      var result2 = check(assocProp);
      printResult(result2.passed, assocProp.name, result2.numTests);

      // Identity: a * 1 = a
      var idProp = identityProperty("integer multiplication", gen,
        proc(a: int, b: int) { return a * b; }, 1);
      var result3 = check(idProp);
      printResult(result3.passed, idProp.name, result3.numTests);
    }
    writeln();

    // Test distributivity: a * (b + c) = a * b + a * c
    writeln("Testing Distributivity:");
    writeln("-" * 40);

    {
      var gen = intGen(-10, 10);

      var distProp = distributiveProperty("multiplication over addition", gen,
        proc(a: int, b: int) { return a * b; },
        proc(a: int, b: int) { return a + b; });
      var result = check(distProp);
      printResult(result.passed, distProp.name, result.numTests);
    }
    writeln();

    // Test max/min properties (forms a lattice)
    writeln("Testing Max/Min Lattice Properties:");
    writeln("-" * 40);

    {
      var gen = intGen(-100, 100);

      // max is commutative
      var maxCommProp = commutativeProperty("max", gen,
        proc(a: int, b: int) { return max(a, b); });
      var result1 = check(maxCommProp);
      printResult(result1.passed, maxCommProp.name, result1.numTests);

      // max is associative
      var maxAssocProp = associativeProperty("max", gen,
        proc(a: int, b: int) { return max(a, b); });
      var result2 = check(maxAssocProp);
      printResult(result2.passed, maxAssocProp.name, result2.numTests);

      // min is commutative
      var minCommProp = commutativeProperty("min", gen,
        proc(a: int, b: int) { return min(a, b); });
      var result3 = check(minCommProp);
      printResult(result3.passed, minCommProp.name, result3.numTests);

      // Idempotence: max(a, a) = a
      var idempProp = idempotentProperty("max(x, x)", gen,
        proc(x: int) { return max(x, x); });
      var result4 = check(idempProp);
      printResult(result4.passed, idempProp.name, result4.numTests);
    }
    writeln();

    writeln("=" * 50);
    writeln("Algebraic properties testing complete!");
  }
}
