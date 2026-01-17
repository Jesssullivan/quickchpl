---
title: Properties Concept
description: "Properties are functions returning bool for all inputs. Use property(), check(), quickCheck(). Patterns: isCommutative, isAssociative, isIdempotent."
---

# Properties

Properties define invariants that should hold for all valid inputs.

## What is a Property?

A property is a function that:

1. Takes randomly generated input
2. Returns `true` if the property holds
3. Returns `false` if the property is violated

```chapel
// A property is just a function: Input -> bool
lambda(x: int) { return x + 0 == x; }
```

## Defining Properties

### Basic Syntax

```chapel
var myProperty = property(
  "descriptive name",      // Name (appears in test output)
  generator,               // Generator for test data
  predicate                // Function returning bool
);
```

### Example Properties

```chapel
use quickchpl;

// Property with single input
var zeroIdentity = property(
  "zero is additive identity",
  intGen(),
  lambda(x: int) { return x + 0 == x; }
);

// Property with multiple inputs
var addCommutes = property(
  "addition commutes",
  tupleGen(intGen(), intGen()),
  lambda((a, b): (int, int)) { return a + b == b + a; }
);

// Conditional property (with precondition)
var divisionProperty = property(
  "multiplication undoes division",
  tupleGen(intGen(), intGen(1, 100)),  // Avoid division by zero
  lambda((a, b): (int, int)) {
    return (a / b) * b + (a % b) == a;
  }
);
```

## Property Patterns

quickchpl provides common patterns in the `Patterns` module:

| Pattern | Description | Example |
|---------|-------------|---------|
| `isCommutative` | a op b = b op a | Addition, multiplication |
| `isAssociative` | (a op b) op c = a op (b op c) | Addition, string concat |
| `hasIdentity` | a op e = a | Zero for addition |
| `isIdempotent` | f(f(x)) = f(x) | `abs`, `sort` |
| `isInvolution` | f(f(x)) = x | `negate`, `reverse` |
| `isRoundTrip` | decode(encode(x)) = x | Serialization |

See [Patterns](../modules/patterns.md) for the full list.

## Running Properties

### Single Property

```chapel
var result = check(myProperty);

if result.passed {
  writeln("Passed ", result.numTests, " tests");
} else {
  writeln("Failed: ", result.failureInfo);
}
```

### Custom Test Count

```chapel
var runner = new PropertyRunner(numTests = 1000);
var result = runner.check(myProperty);
```

### Quick Inline Check

```chapel
// No need to name the property
assert(quickCheck(intGen(), lambda(x: int) { return x == x; }));
```

## Conditional Properties

Sometimes properties only make sense for certain inputs:

```chapel
// Using implication
var sqrtProperty = property(
  "sqrt is inverse of square for non-negative",
  realGen(-100.0, 100.0),
  lambda(x: real) {
    return implies(x >= 0, abs(sqrt(x * x) - abs(x)) < 0.0001);
  }
);
```

The `implies` function makes the property vacuously true when the condition is false.

## Next Steps

- [Shrinking](shrinking.md) - Understanding counterexample minimization
- [Patterns](../modules/patterns.md) - Ready-to-use property patterns
- [Examples](../examples/basic.md) - More examples
