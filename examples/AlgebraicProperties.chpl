// quickchpl: Algebraic Properties Example
// Demonstrates testing algebraic laws using the Patterns predicates

module AlgebraicProperties {
  use quickchpl;

  proc main() {
    writeln("quickchpl Algebraic Properties Example");
    writeln("=" * 50);
    writeln();

    // Test properties of integer addition
    writeln("Testing Integer Addition Properties:");
    writeln("-" * 40);

    {
      var gen = tupleGen(intGen(-100, 100), intGen(-100, 100));

      // Commutativity: a + b = b + a
      var commProp = property("integer addition is commutative", gen,
        proc(args: (int, int)) { const (a, b) = args; return intAddCommutative(a, b); });
      var result1 = check(commProp);
      printResult(result1.passed, commProp.name, result1.numTests);

      // Associativity: (a + b) + c = a + (b + c)
      var gen3 = tupleGen(intGen(-100, 100), intGen(-100, 100), intGen(-100, 100));
      var assocProp = property("integer addition is associative", gen3,
        proc(args: (int, int, int)) { const (a, b, c) = args; return intAddAssociative(a, b, c); });
      var result2 = check(assocProp);
      printResult(result2.passed, assocProp.name, result2.numTests);

      // Identity: a + 0 = a
      var gen1 = intGen(-100, 100);
      var idProp = property("zero is additive identity", gen1,
        proc(a: int) { return intAddIdentity(a); });
      var result3 = check(idProp);
      printResult(result3.passed, idProp.name, result3.numTests);
    }
    writeln();

    // Test properties of integer multiplication
    writeln("Testing Integer Multiplication Properties:");
    writeln("-" * 40);

    {
      var gen = tupleGen(intGen(-10, 10), intGen(-10, 10));

      // Commutativity: a * b = b * a
      var commProp = property("integer multiplication is commutative", gen,
        proc(args: (int, int)) { const (a, b) = args; return intMulCommutative(a, b); });
      var result1 = check(commProp);
      printResult(result1.passed, commProp.name, result1.numTests);

      // Associativity: (a * b) * c = a * (b * c)
      var gen3 = tupleGen(intGen(-10, 10), intGen(-10, 10), intGen(-10, 10));
      var assocProp = property("integer multiplication is associative", gen3,
        proc(args: (int, int, int)) { const (a, b, c) = args; return intMulAssociative(a, b, c); });
      var result2 = check(assocProp);
      printResult(result2.passed, assocProp.name, result2.numTests);

      // Identity: a * 1 = a
      var gen1 = intGen(-10, 10);
      var idProp = property("one is multiplicative identity", gen1,
        proc(a: int) { return intMulIdentity(a); });
      var result3 = check(idProp);
      printResult(result3.passed, idProp.name, result3.numTests);
    }
    writeln();

    // Test distributivity: a * (b + c) = a * b + a * c
    writeln("Testing Distributivity:");
    writeln("-" * 40);

    {
      var gen3 = tupleGen(intGen(-10, 10), intGen(-10, 10), intGen(-10, 10));

      var distProp = property("multiplication distributes over addition", gen3,
        proc(args: (int, int, int)) { const (a, b, c) = args; return intDistributive(a, b, c); });
      var result = check(distProp);
      printResult(result.passed, distProp.name, result.numTests);
    }
    writeln();

    // Test max/min properties (forms a lattice)
    writeln("Testing Max/Min Lattice Properties:");
    writeln("-" * 40);

    {
      var gen = tupleGen(intGen(-100, 100), intGen(-100, 100));

      // max is commutative
      var maxCommProp = property("max is commutative", gen,
        proc(args: (int, int)) { const (a, b) = args; return maxCommutative(a, b); });
      var result1 = check(maxCommProp);
      printResult(result1.passed, maxCommProp.name, result1.numTests);

      // max is associative
      var gen3 = tupleGen(intGen(-100, 100), intGen(-100, 100), intGen(-100, 100));
      var maxAssocProp = property("max is associative", gen3,
        proc(args: (int, int, int)) { const (a, b, c) = args; return maxAssociative(a, b, c); });
      var result2 = check(maxAssocProp);
      printResult(result2.passed, maxAssocProp.name, result2.numTests);

      // min is commutative
      var minCommProp = property("min is commutative", gen,
        proc(args: (int, int)) { const (a, b) = args; return minCommutative(a, b); });
      var result3 = check(minCommProp);
      printResult(result3.passed, minCommProp.name, result3.numTests);

      // Idempotence: max(a, a) = a
      var gen1 = intGen(-100, 100);
      var idempProp = property("max is idempotent", gen1,
        proc(a: int) { return maxIdempotent(a); });
      var result4 = check(idempProp);
      printResult(result4.passed, idempProp.name, result4.numTests);
    }
    writeln();

    writeln("=" * 50);
    writeln("Algebraic properties testing complete!");
  }
}
