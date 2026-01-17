---
title: Full API Reference
description: "Complete quickchpl API. All generator types, property functions, shrinker functions, reporter formats, combinator utilities, pattern predicates, and config constants."
---

# API Reference

Complete API documentation for quickchpl.

## Quick Links

| Module | Description |
|--------|-------------|
| [Generators](#generators) | Random value generators |
| [Properties](#properties) | Property definition and execution |
| [Shrinkers](#shrinkers) | Counterexample minimization |
| [Reporters](#reporters) | Result formatting |
| [Combinators](#combinators) | Generator composition |
| [Patterns](#patterns) | Common property patterns |

---

## Generators

### Types

| Type | Description |
|------|-------------|
| `IntGenerator` | Generates random integers |
| `RealGenerator` | Generates random real numbers |
| `BoolGenerator` | Generates random booleans |
| `StringGenerator` | Generates random strings |
| `TupleGenerator` | Generates tuples of values |
| `ListGenerator` | Generates lists of values |

### Factory Functions

```chapel
proc intGen(): IntGenerator
proc intGen(min: int, max: int): IntGenerator
proc realGen(): RealGenerator
proc realGen(min: real, max: real): RealGenerator
proc boolGen(): BoolGenerator
proc boolGen(trueProb: real): BoolGenerator
proc stringGen(): StringGenerator
proc stringGen(maxLen: int): StringGenerator
proc stringGen(minLen: int, maxLen: int): StringGenerator
proc tupleGen(g1, g2): TupleGenerator
proc tupleGen(g1, g2, g3): TupleGenerator
proc listGen(elemGen): ListGenerator
proc listGen(elemGen, maxSize: int): ListGenerator
proc listGen(elemGen, minSize: int, maxSize: int): ListGenerator
```

---

## Properties

### Types

| Type | Description |
|------|-------------|
| `TestResult` | Result of a property check |
| `Property` | A named property with generator and predicate |
| `PropertyRunner` | Configurable property executor |

### TestResult Fields

```chapel
record TestResult {
  var passed: bool;
  var numTests: int;
  var failureInfo: string;
  var shrunkInfo: string;
  var duration: real;
}
```

### Functions

```chapel
proc property(name: string, gen, pred): Property
proc check(prop: Property): TestResult
proc quickCheck(gen, pred): bool
proc quickCheck(gen, pred, n: int): bool
proc assertProperty(prop: Property): void  // throws on failure
proc forAll(gen, pred): void
```

### Configuration Constants

```chapel
config const numTests = 100;
config const maxShrinkSteps = 1000;
config const shrinkTimeout = 30.0;
config const verbose = false;
config const parallel = false;
config const seed = -1;
```

---

## Shrinkers

### Types

| Type | Description |
|------|-------------|
| `ShrinkResult` | Result of shrinking operation |

### Functions

```chapel
proc shrink(value: int): list(int)
proc shrink(value: real): list(real)
proc shrink(value: bool): list(bool)
proc shrink(value: string): list(string)
proc shrink(value: list(int)): list(list(int))
proc shrink(value: (int, int)): list((int, int))
proc shrink(value: (int, int, int)): list((int, int, int))

proc shrinkInt(value: int): list(int)
proc shrinkReal(value: real): list(real)
proc shrinkBool(value: bool): list(bool)
proc shrinkString(value: string): list(string)
proc shrinkIntList(value: list(int)): list(list(int))
proc shrinkIntTuple2(value: (int, int)): list((int, int))
proc shrinkIntTuple3(value: (int, int, int)): list((int, int, int))

proc shrinkIntFailure(value: int, pred, maxSteps: int = 1000): (int, int)
```

---

## Reporters

### Functions

```chapel
// Console
proc formatResult(passed: bool, name: string, numTests: int,
                  failureInfo: string = "", shrunkInfo: string = ""): string
proc printResult(passed: bool, name: string, numTests: int,
                 failureInfo: string = "", shrunkInfo: string = ""): void
proc printSummary(numPassed: int, numFailed: int, totalTests: int, duration: real): void

// TAP
proc formatTAP(results: list((bool, string, int, string))): string
proc writeTAP(filename: string, results: list((bool, string, int, string))): void

// JUnit
proc formatJUnit(suiteName: string, results: list((bool, string, int, string, real))): string
proc writeJUnit(filename: string, suiteName: string,
                results: list((bool, string, int, string, real))): void

// Progress
proc printProgress(testNum: int, passed: bool): void
proc printSpinner(step: int): void

// Colors
proc greenText(s: string): string
proc redText(s: string): string
proc yellowText(s: string): string
proc boldText(s: string): string
proc formatResultColor(passed: bool, name: string, numTests: int,
                       failureInfo: string = "", shrunkInfo: string = ""): string
```

### Enums

```chapel
enum Verbosity { Quiet, Normal, Verbose, Exhaustive }
```

---

## Combinators

### Functions

```chapel
// Transformation
proc map(gen, f): Generator
proc filter(gen, pred): Generator
proc suchThat(gen, pred, maxRetries: int = 100): Generator

// Choice
proc oneOf(gens...): Generator
proc frequency(weighted: [(int, Generator)]): Generator
proc elements(values: [?]): Generator
proc constant(value): Generator

// Sizing
proc resize(gen, scale: real): Generator
proc nonEmpty(gen): Generator
proc sized(f: proc(int): Generator): Generator

// Combination
proc zipGen(g1, g2): Generator
proc flatMap(gen, f): Generator

// Recursion
proc recursive(f: proc(Generator): Generator, maxDepth: int): Generator
```

---

## Patterns

### Algebraic Properties

```chapel
proc isCommutative(a, b, op): bool
proc isAssociative(a, b, c, op): bool
proc hasIdentity(a, e, op): bool
proc hasInverse(a, inv, e, op): bool
proc isDistributive(a, b, c, mult, add): bool
proc isAbsorptive(a, b, meet, join): bool
```

### Functional Properties

```chapel
proc isIdempotent(x, f): bool
proc isInvolution(x, f): bool
proc isHomomorphism(a, b, f, opSource, opTarget): bool
proc isMonotonic(a, b, f, leq): bool
```

### Round-Trip Properties

```chapel
proc isRoundTrip(x, encode, decode): bool
```

### Ordering Properties

```chapel
proc isReflexive(a, leq): bool
proc isAntisymmetric(a, b, leq): bool
proc isTransitive(a, b, c, leq): bool
proc isTotal(a, b, leq): bool
```

### Logic

```chapel
proc implies(condition: bool, conclusion: bool): bool
proc impl(condition: bool, conclusion: bool): bool
```

### Integer-Specific

```chapel
proc intAddCommutative(a: int, b: int): bool
proc intAddAssociative(a: int, b: int, c: int): bool
proc intAddIdentity(a: int): bool
proc intMulCommutative(a: int, b: int): bool
proc intMulAssociative(a: int, b: int, c: int): bool
proc intMulIdentity(a: int): bool
proc intDistributive(a: int, b: int, c: int): bool
proc maxCommutative(a: int, b: int): bool
proc maxAssociative(a: int, b: int, c: int): bool
proc maxIdempotent(a: int): bool
proc minCommutative(a: int, b: int): bool
proc minAssociative(a: int, b: int, c: int): bool
proc minIdempotent(a: int): bool
```

### Collection Properties

```chapel
proc preservesLength(x, f, length): bool
proc areEquivalent(x, f, g): bool
proc areApproxEquivalent(x, f, g, epsilon: real): bool
```

---

## Version Information

```chapel
param VERSION = "1.0.0";
param VERSION_MAJOR = 1;
param VERSION_MINOR = 0;
param VERSION_PATCH = 0;
```
