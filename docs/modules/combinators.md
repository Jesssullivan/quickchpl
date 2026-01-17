---
title: Combinators Module API
description: "Generator composition utilities. map(), filter(), suchThat(), oneOf(), frequency(), elements(), constant(), resize(), nonEmpty(), flatMap(), recursive()."
---

# Combinators Module

The `Combinators` module provides utilities for composing and transforming generators.

## Transforming Generators

### map()

Transform generated values:

```chapel
// Generate even numbers
var evenGen = map(intGen(), lambda(x: int) { return x * 2; });

// Generate positive integers
var positiveGen = map(intGen(), lambda(x: int) { return abs(x) + 1; });
```

### filter()

Filter generated values:

```chapel
// Only positive integers
var positiveGen = filter(intGen(), lambda(x: int) { return x > 0; });

// Only non-empty strings
var nonEmptyGen = filter(stringGen(), lambda(s: string) { return s.size > 0; });
```

!!! warning "Performance"
    `filter()` may retry many times if the predicate rejects most values.
    Consider `suchThat()` with a retry limit instead.

### suchThat()

Filter with retry limit:

```chapel
// Positive integers, max 100 retries
var positiveGen = suchThat(intGen(), lambda(x: int) { return x > 0; }, 100);
```

## Choosing Generators

### oneOf()

Choose uniformly between generators:

```chapel
// Either an int or a real
var numGen = oneOf(intGen(), realGen());

// Choice of three string generators
var stringChoice = oneOf(
  stringGen(5),      // Short strings
  stringGen(50),     // Medium strings
  stringGen(500)     // Long strings
);
```

### frequency()

Weighted random choice:

```chapel
// 70% small, 20% medium, 10% large
var sizedGen = frequency([
  (7, intGen(0, 10)),
  (2, intGen(10, 100)),
  (1, intGen(100, 1000))
]);
```

### elements()

Choose from a fixed list:

```chapel
// Choose from specific values
var colorGen = elements(["red", "green", "blue"]);
var digitGen = elements([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
```

## Sizing Generators

### resize()

Scale generator size:

```chapel
var smallGen = resize(stringGen(), 0.5);   // Half size
var largeGen = resize(stringGen(), 2.0);   // Double size
```

### nonEmpty()

Ensure non-empty collections:

```chapel
var nonEmptyList = nonEmpty(listGen(intGen()));
var nonEmptyString = nonEmpty(stringGen());
```

### sized()

Size-dependent generation:

```chapel
var sizedGen = sized(lambda(size: int) {
  return intGen(0, size);
});
```

## Combining Generators

### zipGen()

Combine generators in sequence:

```chapel
var pairGen = zipGen(intGen(), stringGen());
// Generates (int, string) pairs
```

### flatMap()

Chain generators:

```chapel
// Generate a list, then an element from that list
var listThenElement = flatMap(
  listGen(intGen(), 1, 10),
  lambda(lst: list(int)) {
    return elements(lst.toArray());
  }
);
```

## Recursive Generators

### recursive()

Generate recursive data structures:

```chapel
// Binary tree generator
var treeGen = recursive(lambda(self) {
  return oneOf(
    constant(nil),                    // Leaf
    tupleGen(intGen(), self, self)   // Node with children
  );
}, 5);  // Max depth 5
```

## Examples

### Custom User Generator

```chapel
record User {
  var id: int;
  var name: string;
  var active: bool;
}

var userGen = map(
  tupleGen(intGen(1, 10000), stringGen(20), boolGen()),
  lambda((id, name, active): (int, string, bool)) {
    return new User(id, name, active);
  }
);
```

### Email Generator

```chapel
var emailGen = map(
  tupleGen(stringGen(10), elements(["gmail.com", "yahoo.com", "example.org"])),
  lambda((user, domain): (string, string)) {
    return user + "@" + domain;
  }
);
```

### Weighted Status Generator

```chapel
var statusGen = frequency([
  (8, constant("active")),    // 80% active
  (1, constant("pending")),   // 10% pending
  (1, constant("suspended"))  // 10% suspended
]);
```

## See Also

- [Generators](generators.md) - Basic generators
- [Examples](../examples/custom-generators.md) - More custom generator examples
