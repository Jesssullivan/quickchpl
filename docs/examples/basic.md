---
title: Basic Examples
description: "Simple quickchpl examples. Test arithmetic identity, commutativity, double negation. String concatenation tests. Quick inline tests with quickCheck()."
---

# Basic Examples

Simple examples to get started with quickchpl.

## Hello Property Testing

```chapel title="hello_property.chpl"
use quickchpl;

proc main() {
  // The simplest property: x equals itself
  var reflexive = property(
    "equality is reflexive",
    intGen(),
    lambda(x: int) { return x == x; }
  );

  var result = check(reflexive);
  writeln(if result.passed then "✓ All tests passed!" else "✗ Tests failed");
}
```

## Testing Arithmetic

```chapel title="arithmetic.chpl"
use quickchpl;

proc main() {
  // Zero identity
  var zeroIdentity = property(
    "zero is additive identity",
    intGen(),
    lambda(x: int) { return x + 0 == x; }
  );

  // One identity
  var oneIdentity = property(
    "one is multiplicative identity",
    intGen(),
    lambda(x: int) { return x * 1 == x; }
  );

  // Double negation
  var doubleNegation = property(
    "double negation returns original",
    intGen(),
    lambda(x: int) { return -(-x) == x; }
  );

  check(zeroIdentity);
  check(oneIdentity);
  check(doubleNegation);
}
```

## Testing with Multiple Inputs

```chapel title="multiple_inputs.chpl"
use quickchpl;

proc main() {
  // Addition commutes
  var addCommutes = property(
    "addition is commutative",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return a + b == b + a; }
  );

  // Multiplication commutes
  var mulCommutes = property(
    "multiplication is commutative",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return a * b == b * a; }
  );

  check(addCommutes);
  check(mulCommutes);
}
```

## Testing Strings

```chapel title="string_tests.chpl"
use quickchpl;

proc main() {
  // Empty string is identity for concatenation
  var emptyIdentity = property(
    "empty string is concat identity",
    stringGen(20),
    lambda(s: string) { return s + "" == s && "" + s == s; }
  );

  // Concatenation length
  var concatLength = property(
    "concat length is sum of lengths",
    tupleGen(stringGen(20), stringGen(20)),
    lambda((a, b): (string, string)) {
      return (a + b).size == a.size + b.size;
    }
  );

  check(emptyIdentity);
  check(concatLength);
}
```

## Quick Inline Tests

```chapel title="quick_tests.chpl"
use quickchpl;

proc main() {
  // Use quickCheck for simple inline tests
  assert(quickCheck(intGen(), lambda(x: int) { return x + 0 == x; }));
  assert(quickCheck(intGen(), lambda(x: int) { return x * 1 == x; }));
  assert(quickCheck(boolGen(), lambda(b: bool) { return b || !b; }));

  writeln("All quick checks passed!");
}
```

## Running More Tests

```chapel title="many_tests.chpl"
use quickchpl;

proc main() {
  var prop = property(
    "addition commutes",
    tupleGen(intGen(), intGen()),
    lambda((a, b): (int, int)) { return a + b == b + a; }
  );

  // Run 1000 tests instead of default 100
  var runner = new PropertyRunner(numTests = 1000);
  var result = runner.check(prop);

  writeln("Ran ", result.numTests, " tests in ", result.duration, " seconds");
}
```

## Next Steps

- [Algebraic Properties](algebraic.md) - Testing mathematical laws
- [Custom Generators](custom-generators.md) - Building custom generators
