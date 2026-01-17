---
title: Algebraic Property Examples
description: "Test mathematical structures. Group properties: associativity, identity, inverse. Ring axioms: distributivity. Lattice: min/max absorption. Total order properties."
---

# Algebraic Properties

Testing mathematical properties like associativity, commutativity, and distributivity.

## Group Properties

Test that an operation forms a group:

```chapel title="group_properties.chpl"
use quickchpl;

proc main() {
  writeln("=== Testing Integer Addition as a Group ===\n");

  // Closure (automatic for int + int -> int)

  // Associativity: (a + b) + c = a + (b + c)
  var associative = property(
    "addition is associative",
    tupleGen(intGen(-1000, 1000), intGen(-1000, 1000), intGen(-1000, 1000)),
    lambda((a, b, c): (int, int, int)) {
      return isAssociative(a, b, c, lambda(x: int, y: int) { return x + y; });
    }
  );

  // Identity: a + 0 = a and 0 + a = a
  var identity = property(
    "zero is identity",
    intGen(),
    lambda(a: int) {
      return hasIdentity(a, 0, lambda(x: int, y: int) { return x + y; });
    }
  );

  // Inverse: a + (-a) = 0
  var inverse = property(
    "negation is inverse",
    intGen(),
    lambda(a: int) {
      return hasInverse(a, lambda(x: int) { return -x; }, 0,
                        lambda(x: int, y: int) { return x + y; });
    }
  );

  // Commutativity (abelian group)
  var commutative = property(
    "addition is commutative",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) {
      return isCommutative(a, b, lambda(x: int, y: int) { return x + y; });
    }
  );

  check(associative);
  check(identity);
  check(inverse);
  check(commutative);

  writeln("\n✓ Integer addition forms an abelian group");
}
```

## Ring Properties

Test ring axioms:

```chapel title="ring_properties.chpl"
use quickchpl;

proc main() {
  writeln("=== Testing Integers as a Ring ===\n");

  // Addition is abelian group (tested above)

  // Multiplication is associative
  var mulAssoc = property(
    "multiplication is associative",
    tupleGen(intGen(-100, 100), intGen(-100, 100), intGen(-100, 100)),
    lambda((a, b, c): (int, int, int)) {
      return isAssociative(a, b, c, lambda(x: int, y: int) { return x * y; });
    }
  );

  // Multiplication has identity
  var mulIdentity = property(
    "one is multiplicative identity",
    intGen(),
    lambda(a: int) {
      return hasIdentity(a, 1, lambda(x: int, y: int) { return x * y; });
    }
  );

  // Distributivity
  var leftDistrib = property(
    "left distributivity",
    tupleGen(intGen(-100, 100), intGen(-100, 100), intGen(-100, 100)),
    lambda((a, b, c): (int, int, int)) {
      return isDistributive(a, b, c,
                            lambda(x: int, y: int) { return x * y; },
                            lambda(x: int, y: int) { return x + y; });
    }
  );

  check(mulAssoc);
  check(mulIdentity);
  check(leftDistrib);

  writeln("\n✓ Integers form a ring");
}
```

## Lattice Properties

Test lattice operations (min/max):

```chapel title="lattice_properties.chpl"
use quickchpl;

proc main() {
  writeln("=== Testing Min/Max Lattice ===\n");

  // Max is commutative
  var maxComm = property(
    "max is commutative",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return maxCommutative(a, b); }
  );

  // Max is associative
  var maxAssoc = property(
    "max is associative",
    tupleGen(intGen(), intGen(), intGen()),
    lambda((a, b, c): (int, int, int)) { return maxAssociative(a, b, c); }
  );

  // Max is idempotent
  var maxIdem = property(
    "max is idempotent",
    intGen(),
    lambda(a: int) { return maxIdempotent(a); }
  );

  // Min is commutative
  var minComm = property(
    "min is commutative",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return minCommutative(a, b); }
  );

  // Absorption: max(a, min(a, b)) = a
  var absorption = property(
    "absorption law",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) {
      return isAbsorptive(a, b,
                          lambda(x: int, y: int) { return max(x, y); },
                          lambda(x: int, y: int) { return min(x, y); });
    }
  );

  check(maxComm);
  check(maxAssoc);
  check(maxIdem);
  check(minComm);
  check(absorption);

  writeln("\n✓ Min/Max form a lattice");
}
```

## Ordering Properties

Test ordering relations:

```chapel title="ordering_properties.chpl"
use quickchpl;

proc main() {
  writeln("=== Testing Total Order ===\n");

  const leq = lambda(x: int, y: int) { return x <= y; };

  // Reflexive: a <= a
  var reflexive = property(
    "less-or-equal is reflexive",
    intGen(),
    lambda(a: int) { return isReflexive(a, leq); }
  );

  // Antisymmetric: a <= b and b <= a implies a = b
  var antisymmetric = property(
    "less-or-equal is antisymmetric",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return isAntisymmetric(a, b, leq); }
  );

  // Transitive: a <= b and b <= c implies a <= c
  var transitive = property(
    "less-or-equal is transitive",
    tupleGen(intGen(), intGen(), intGen()),
    lambda((a, b, c): (int, int, int)) { return isTransitive(a, b, c, leq); }
  );

  // Total: a <= b or b <= a
  var total = property(
    "less-or-equal is total",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return isTotal(a, b, leq); }
  );

  check(reflexive);
  check(antisymmetric);
  check(transitive);
  check(total);

  writeln("\n✓ Integer ordering is a total order");
}
```

## Next Steps

- [Custom Generators](custom-generators.md) - Build generators for your types
- [Integration Testing](integration.md) - Test with real-world data
