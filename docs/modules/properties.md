---
title: Properties Module API
description: "API for TestResult, Property, PropertyRunner. Functions: property(), check(), quickCheck(), assertProperty(), forAll(). Config: numTests, maxShrinkSteps."
---

# Properties Module

The `Properties` module provides property definition, execution, and result handling.

## Core Types

### TestResult

Result of checking a property:

```chapel
record TestResult {
  var passed: bool;           // Did all tests pass?
  var numTests: int;          // Number of tests run
  var failureInfo: string;    // Counterexample (if failed)
  var shrunkInfo: string;     // Shrunk counterexample
  var duration: real;         // Execution time (seconds)
}
```

### Property

A named property with a generator and predicate:

```chapel
var prop = property(name, generator, predicate);
```

### PropertyRunner

Configure and run property checks:

```chapel
var runner = new PropertyRunner(
  numTests = 100,           // Tests per property
  maxShrinkSteps = 1000,    // Max shrinking iterations
  shrinkTimeout = 30.0,     // Shrinking timeout (seconds)
  verbose = false,          // Print each test?
  stopOnFailure = true      // Stop after first failure?
);
```

## Functions

### check()

Run a property check with default settings:

```chapel
var result = check(myProperty);
```

### quickCheck()

Quick inline property check:

```chapel
var passed = quickCheck(
  intGen(),
  lambda(x: int) { return x + 0 == x; }
);
```

### assertProperty()

Assert a property passes (throws on failure):

```chapel
assertProperty(myProperty);  // Throws if fails
```

### forAll()

Functional-style property check:

```chapel
forAll(intGen(), lambda(x: int) {
  assert(x + 0 == x);
});
```

## Configuration

### Global Config

```chapel
config const numTests = 100;        // Default test count
config const maxShrinkSteps = 1000; // Max shrink steps
config const shrinkTimeout = 30.0;  // Shrink timeout
config const verbose = false;       // Verbose output
```

Override via command line:

```bash
./mytest --numTests=500 --verbose=true
```

### Per-Runner Config

```chapel
var runner = new PropertyRunner(numTests = 1000);
var result = runner.check(myProperty);
```

## Examples

### Basic Property Check

```chapel
var prop = property(
  "zero identity",
  intGen(),
  lambda(x: int) { return x + 0 == x; }
);

var result = check(prop);
if result.passed {
  writeln("Passed!");
} else {
  writeln("Failed: ", result.failureInfo);
}
```

### Multiple Properties

```chapel
var runner = new PropertyRunner(numTests = 200);

var results: list(TestResult);
results.pushBack(runner.check(prop1));
results.pushBack(runner.check(prop2));
results.pushBack(runner.check(prop3));

var passed = 0, failed = 0;
for r in results {
  if r.passed then passed += 1;
  else failed += 1;
}

printSummary(passed, failed, results.size * 200, totalDuration);
```

### Verbose Mode

```chapel
var runner = new PropertyRunner(verbose = true);
runner.check(prop);

// Output:
// Test 1: (42, 17) -> true
// Test 2: (-5, 3) -> true
// ...
```

## See Also

- [Generators](generators.md) - Create test data
- [Patterns](patterns.md) - Common property patterns
- [Reporters](reporters.md) - Format results
