---
title: Patterns Module API
description: "Ready-to-use property predicates. Algebraic: isCommutative, isAssociative, hasIdentity. Functional: isIdempotent, isInvolution, isRoundTrip. Ordering: isReflexive, isTransitive."
---

# Patterns Module

The `Patterns` module provides ready-to-use predicates for common property patterns.

## Algebraic Properties

### isCommutative()

Test commutativity: `a op b = b op a`

```chapel
var addCommutes = property(
  "addition commutes",
  tupleGen(intGen(), intGen()),
  lambda((a, b): (int, int)) {
    return isCommutative(a, b, lambda(x: int, y: int) { return x + y; });
  }
);
```

### isAssociative()

Test associativity: `(a op b) op c = a op (b op c)`

```chapel
var mulAssociates = property(
  "multiplication associates",
  tupleGen(intGen(-100, 100), intGen(-100, 100), intGen(-100, 100)),
  lambda((a, b, c): (int, int, int)) {
    return isAssociative(a, b, c, lambda(x: int, y: int) { return x * y; });
  }
);
```

### hasIdentity()

Test identity element: `a op e = a` and `e op a = a`

```chapel
var zeroIdentity = property(
  "zero is additive identity",
  intGen(),
  lambda(a: int) {
    return hasIdentity(a, 0, lambda(x: int, y: int) { return x + y; });
  }
);
```

### hasInverse()

Test inverse: `a op inv(a) = e` and `inv(a) op a = e`

```chapel
var negationInverse = property(
  "negation is additive inverse",
  intGen(),
  lambda(a: int) {
    return hasInverse(a, lambda(x: int) { return -x; }, 0,
                      lambda(x: int, y: int) { return x + y; });
  }
);
```

### isDistributive()

Test distributivity: `a * (b + c) = (a * b) + (a * c)`

```chapel
var mulDistributes = property(
  "multiplication distributes over addition",
  tupleGen(intGen(-10, 10), intGen(-10, 10), intGen(-10, 10)),
  lambda((a, b, c): (int, int, int)) {
    return isDistributive(a, b, c,
                          lambda(x: int, y: int) { return x * y; },
                          lambda(x: int, y: int) { return x + y; });
  }
);
```

## Functional Properties

### isIdempotent()

Test idempotence: `f(f(x)) = f(x)`

```chapel
var absIdempotent = property(
  "abs is idempotent",
  intGen(),
  lambda(x: int) {
    return isIdempotent(x, lambda(n: int) { return abs(n); });
  }
);
```

### isInvolution()

Test involution: `f(f(x)) = x`

```chapel
var negateInvolution = property(
  "negation is an involution",
  intGen(),
  lambda(x: int) {
    return isInvolution(x, lambda(n: int) { return -n; });
  }
);
```

### isMonotonic()

Test monotonicity: `a <= b` implies `f(a) <= f(b)`

```chapel
var absMonotonic = property(
  "abs is monotonic for non-negative",
  tupleGen(intGen(0, 1000), intGen(0, 1000)),
  lambda((a, b): (int, int)) {
    return isMonotonic(a, b, lambda(x: int) { return x * 2; },
                       lambda(x: int, y: int) { return x <= y; });
  }
);
```

### isHomomorphism()

Test homomorphism: `f(a opS b) = f(a) opT f(b)`

```chapel
var lengthHomomorphism = property(
  "length is a homomorphism from string concat to int add",
  tupleGen(stringGen(10), stringGen(10)),
  lambda((a, b): (string, string)) {
    return isHomomorphism(a, b,
                          lambda(s: string) { return s.size; },
                          lambda(s1: string, s2: string) { return s1 + s2; },
                          lambda(n1: int, n2: int) { return n1 + n2; });
  }
);
```

## Round-Trip Properties

### isRoundTrip()

Test round-trip: `decode(encode(x)) = x`

```chapel
var jsonRoundTrip = property(
  "JSON round-trip",
  intGen(),
  lambda(x: int) {
    return isRoundTrip(x,
                       lambda(n: int) { return n:string; },
                       lambda(s: string) { return s:int; });
  }
);
```

## Ordering Properties

### isReflexive()

Test reflexivity: `a <= a`

```chapel
var leqReflexive = property(
  "less-than-or-equal is reflexive",
  intGen(),
  lambda(a: int) {
    return isReflexive(a, lambda(x: int, y: int) { return x <= y; });
  }
);
```

### isAntisymmetric()

Test antisymmetry: `a <= b` and `b <= a` implies `a = b`

```chapel
var leqAntisymmetric = property(
  "less-than-or-equal is antisymmetric",
  tupleGen(intGen(), intGen()),
  lambda((a, b): (int, int)) {
    return isAntisymmetric(a, b, lambda(x: int, y: int) { return x <= y; });
  }
);
```

### isTransitive()

Test transitivity: `a <= b` and `b <= c` implies `a <= c`

```chapel
var leqTransitive = property(
  "less-than-or-equal is transitive",
  tupleGen(intGen(), intGen(), intGen()),
  lambda((a, b, c): (int, int, int)) {
    return isTransitive(a, b, c, lambda(x: int, y: int) { return x <= y; });
  }
);
```

### isTotal()

Test totality: `a <= b` or `b <= a`

```chapel
var leqTotal = property(
  "less-than-or-equal is total",
  tupleGen(intGen(), intGen()),
  lambda((a, b): (int, int)) {
    return isTotal(a, b, lambda(x: int, y: int) { return x <= y; });
  }
);
```

## Logic Helpers

### implies()

Logical implication for conditional properties:

```chapel
// If x > 0 then x * 2 > 0
var positiveDouble = property(
  "doubling positive stays positive",
  intGen(),
  lambda(x: int) {
    return implies(x > 0, x * 2 > 0);
  }
);
```

### impl()

Shorthand for `implies`:

```chapel
return impl(condition, conclusion);
```

## Integer-Specific Patterns

Ready-to-use predicates for common integer operations:

```chapel
intAddCommutative(a, b)      // a + b = b + a
intAddAssociative(a, b, c)   // (a + b) + c = a + (b + c)
intAddIdentity(a)            // a + 0 = a
intMulCommutative(a, b)      // a * b = b * a
intMulAssociative(a, b, c)   // (a * b) * c = a * (b * c)
intMulIdentity(a)            // a * 1 = a
intDistributive(a, b, c)     // a * (b + c) = a * b + a * c
maxCommutative(a, b)         // max(a,b) = max(b,a)
maxAssociative(a, b, c)      // max(max(a,b),c) = max(a,max(b,c))
maxIdempotent(a)             // max(a,a) = a
minCommutative(a, b)         // min(a,b) = min(b,a)
minAssociative(a, b, c)      // etc.
minIdempotent(a)
```

## See Also

- [Properties](properties.md) - Using patterns in properties
- [Algebraic Examples](../examples/algebraic.md) - More algebraic property examples
