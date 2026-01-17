---
title: Generators Module API
description: "API for IntGenerator, RealGenerator, BoolGenerator, StringGenerator, TupleGenerator, ListGenerator. Factory functions: intGen(), realGen(), boolGen(), stringGen()."
---

# Generators Module

The `Generators` module provides type-safe, composable random value generators.

## Basic Generators

### IntGenerator

Generate random integers:

```chapel
var gen = intGen();          // Full int range
var gen = intGen(-100, 100); // Bounded range
var value = gen.generate();  // Get a random integer
```

### RealGenerator

Generate random real numbers:

```chapel
var gen = realGen();           // 0.0 to 1.0
var gen = realGen(-10.0, 10.0); // Custom range
```

### BoolGenerator

Generate random booleans:

```chapel
var gen = boolGen();          // 50/50 true/false
var gen = boolGen(0.8);       // 80% chance of true
```

### StringGenerator

Generate random strings:

```chapel
var gen = stringGen();        // Default max length
var gen = stringGen(20);      // Max 20 characters
var gen = stringGen(5, 10);   // 5-10 characters
```

## Composite Generators

### TupleGenerator

Generate tuples of values:

```chapel
var gen = tupleGen(intGen(), intGen());
var (a, b) = gen.generate();

var gen3 = tupleGen(intGen(), realGen(), boolGen());
var (x, y, z) = gen3.generate();
```

### ListGenerator

Generate lists of values:

```chapel
var gen = listGen(intGen());        // Lists of integers
var gen = listGen(intGen(), 10);    // Max 10 elements
var gen = listGen(intGen(), 5, 10); // 5-10 elements
```

## Generator API

All generators implement:

```chapel
proc generate(): T;           // Generate a random value
proc generate(seed: int): T;  // Generate with specific seed
```

## Examples

### Testing with Integers

```chapel
var prop = property(
  "addition commutes",
  tupleGen(intGen(), intGen()),
  lambda((a, b): (int, int)) { return a + b == b + a; }
);
```

### Testing with Strings

```chapel
var prop = property(
  "concat associativity",
  tupleGen(stringGen(10), stringGen(10), stringGen(10)),
  lambda((a, b, c): (string, string, string)) {
    return (a + b) + c == a + (b + c);
  }
);
```

### Testing with Lists

```chapel
var prop = property(
  "reverse preserves length",
  listGen(intGen(), 20),
  lambda(lst: list(int)) {
    return lst.size == reverse(lst).size;
  }
);
```

## See Also

- [Combinators](combinators.md) - Compose and transform generators
- [Properties](properties.md) - Use generators in property tests
