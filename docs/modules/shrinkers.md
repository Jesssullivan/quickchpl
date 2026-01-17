---
title: Shrinkers Module API
description: "API for ShrinkResult and shrinking functions. shrinkInt(), shrinkReal(), shrinkBool(), shrinkString(), shrinkIntList(). Configure maxShrinkSteps, shrinkTimeout."
---

# Shrinkers Module

The `Shrinkers` module provides counterexample minimization.

## Purpose

When a property fails, the input that caused the failure might be complex:

```
Counterexample: [847392, -12847, 9283, 0, -472, ...]
```

Shrinking finds a simpler input that still fails:

```
Shrunk to: [101]
```

## Core Types

### ShrinkResult

```chapel
record ShrinkResult {
  var original: string;   // Original failing value
  var shrunk: string;     // Minimized failing value
  var steps: int;         // Shrinking iterations
  var duration: real;     // Time spent shrinking
}
```

## Shrinking Functions

### Generic shrink()

Type-dispatched shrinking:

```chapel
var candidates = shrink(42);         // List of smaller ints
var candidates = shrink(3.14);       // List of smaller reals
var candidates = shrink("hello");    // List of smaller strings
```

### Type-Specific Shrinkers

#### Integers

```chapel
var candidates = shrinkInt(100);
// Returns: [0, 50, 25, 12, 6, 3, 1, 99]
```

Strategy:
1. Try 0 (smallest possible)
2. Binary search towards 0
3. Try immediate neighbors

#### Real Numbers

```chapel
var candidates = shrinkReal(3.14159);
// Returns: [0.0, 3.0, 1.57, 0.785, ...]
```

Strategy:
1. Try 0.0
2. Truncate to integer
3. Round to nearest integer
4. Binary search towards 0

#### Booleans

```chapel
var candidates = shrinkBool(true);
// Returns: [false]

var candidates = shrinkBool(false);
// Returns: [] (empty - false is minimal)
```

#### Strings

```chapel
var candidates = shrinkString("hello");
// Returns: ["", "h", "he", "hel", "hell", "ello", "hllo", ...]
```

Strategy:
1. Try empty string
2. Remove characters from end
3. Remove single characters
4. Simplify characters to 'a'

#### Lists

```chapel
var candidates = shrinkIntList(myList);
```

Strategy:
1. Try empty list
2. Remove elements from end
3. Remove single elements
4. Shrink individual elements

#### Tuples

```chapel
var candidates = shrinkIntTuple2((10, 20));
// Returns: [(0, 20), (5, 20), (10, 0), (10, 10), (0, 0), ...]
```

Strategy: Shrink each component independently and in combination.

## Shrinking with Predicate

Find minimal failing input:

```chapel
var (minimal, steps) = shrinkIntFailure(
  1000,                                    // Initial failing value
  lambda(x: int) { return x < 50; },      // Predicate
  1000                                     // Max steps
);
// minimal = 50 (smallest value where predicate returns false)
```

## Configuration

### Max Shrink Steps

```chapel
config const maxShrinkSteps = 1000;
```

### Shrink Timeout

```chapel
config const shrinkTimeout = 30.0;  // seconds
```

### Disable Shrinking

```chapel
var runner = new PropertyRunner(shrinkEnabled = false);
```

## See Also

- [Properties](properties.md) - Running property tests
- [Shrinking Concept](../concepts/shrinking.md) - Conceptual overview
