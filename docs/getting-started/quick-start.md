---
title: Quick Start
description: "5-minute introduction to quickchpl. Learn generators, properties, and basic testing patterns. Includes reference table for common operations."
---

# Quick Start

Get up and running with quickchpl in 5 minutes.

## The Basics

Property-based testing is about defining **properties** that should hold for **all valid inputs**, then letting the framework generate random test cases.

```mermaid
flowchart LR
    G[Generator] -->|random values| P[Property]
    P -->|true/false| R[Result]
    R -->|if false| S[Shrink]
    S -->|minimal input| F[Failure Report]
```

## Your First Property

```chapel title="first_property.chpl"
use quickchpl;

// Property: Adding zero doesn't change a number
var zeroIdentity = property(
  "zero is additive identity",
  intGen(),                              // Generate random integers
  lambda(x: int) { return x + 0 == x; }  // Property to check
);

// Run 100 tests
var result = check(zeroIdentity);

if result.passed {
  writeln("✓ Passed ", result.numTests, " tests");
} else {
  writeln("✗ Failed: ", result.failureInfo);
}
```

## Testing Multiple Inputs

Use `tupleGen` to test properties with multiple inputs:

```chapel title="commutativity.chpl"
use quickchpl;

// Property: Addition is commutative
var addCommutes = property(
  "addition commutes",
  tupleGen(intGen(), intGen()),
  lambda((a, b): (int, int)) { return a + b == b + a; }
);

var result = check(addCommutes);
printResult(result.passed, "addition commutes", result.numTests);
```

## Using Patterns

quickchpl provides ready-to-use patterns for common properties:

```chapel title="patterns_demo.chpl"
use quickchpl;

// Test associativity of multiplication
var mulAssoc = property(
  "multiplication associates",
  tupleGen(intGen(-100, 100), intGen(-100, 100), intGen(-100, 100)),
  lambda((a, b, c): (int, int, int)) {
    return isAssociative(a, b, c, lambda(x: int, y: int) { return x * y; });
  }
);

check(mulAssoc);
```

## Quick Reference

| Task | Code |
|------|------|
| Generate integers | `intGen()` or `intGen(min, max)` |
| Generate reals | `realGen()` or `realGen(min, max)` |
| Generate booleans | `boolGen()` |
| Generate strings | `stringGen()` or `stringGen(maxLen)` |
| Generate tuples | `tupleGen(gen1, gen2, ...)` |
| Run 100 tests | `check(property)` |
| Run N tests | `PropertyRunner(numTests=N).check(property)` |
| Quick inline check | `quickCheck(gen, predicate)` |

## Next Steps

- [First Property Test](first-test.md) - Detailed walkthrough
- [Generators](../concepts/generators.md) - All generator types
- [Patterns](../modules/patterns.md) - Ready-to-use property patterns
