---
title: Code Style Guide
description: "Chapel code conventions for quickchpl. Naming: camelCase variables, PascalCase types. 2-space indent, 100 char lines. Doc comments for public APIs."
---

# Code Style Guide

Style conventions for quickchpl development.

## General Principles

1. **Clarity over brevity**: Code should be readable
2. **Consistency**: Follow existing patterns
3. **Documentation**: Public APIs need doc comments
4. **Testing**: New features need tests

## Naming Conventions

### Variables and Functions

```chapel
// camelCase for variables and functions
var testCount = 0;
proc runTests() { }

// Descriptive names
var gen = intGen();          // OK for short scope
var integerGenerator = intGen();  // Better for longer scope
```

### Types and Records

```chapel
// PascalCase for types
record TestResult { }
class PropertyRunner { }
enum Verbosity { }
```

### Constants

```chapel
// UPPER_CASE for constants
const MAX_RETRIES = 100;
param VERSION = "1.0.0";
```

### Module-level

```chapel
// camelCase for config constants
config const numTests = 100;
config const verbose = false;
```

## Formatting

### Indentation

Use 2 spaces:

```chapel
proc example() {
  if condition {
    doSomething();
  }
}
```

### Line Length

Maximum 100 characters. Break long lines:

```chapel
// Break before operators
var result = someVeryLongFunctionName(argument1, argument2)
           + anotherLongExpression;

// Break after commas in function calls
var gen = tupleGen(
  intGen(-1000, 1000),
  stringGen(50),
  boolGen()
);
```

### Braces

Opening brace on same line:

```chapel
proc example() {
  // body
}

if condition {
  // body
} else {
  // body
}
```

### Spacing

```chapel
// Spaces around operators
var x = a + b;
var y = a * b + c;

// No space before parentheses in function calls
doSomething(arg1, arg2);

// Space after comma
tupleGen(intGen(), realGen());

// Space after keywords
if condition { }
for i in range { }
while condition { }
```

## Documentation

### Module Doc Comments

```chapel
/*
  Module Name
  ===========

  Brief description of what the module does.

  **Features:**

  - Feature 1
  - Feature 2

  Example::

    use ModuleName;
    // example code
*/
module ModuleName { }
```

### Function Doc Comments

```chapel
/*
  Brief description of the function.

  Longer description if needed, explaining behavior,
  edge cases, and any important notes.

  :arg param1: Description of first parameter
  :arg param2: Description of second parameter
  :type param2: Optional type info
  :returns: Description of return value

  Example::

    var result = myFunction(1, "test");
*/
proc myFunction(param1: int, param2: string): bool {
  // implementation
}
```

### Inline Comments

```chapel
// Single-line comment for simple explanations

/*
  Multi-line comment for longer explanations
  that span multiple lines.
*/

// TODO: Description of what needs to be done
// FIXME: Description of bug to fix
// NOTE: Important information
```

## Code Organization

### Import Order

```chapel
// Standard library first
use IO;
use List;
use Math;

// Then project modules
use Generators;
use Properties;
```

### Function Order

1. Public API functions
2. Helper functions
3. Private implementation

```chapel
module Example {
  // Public API
  proc publicFunction() { }

  // Helpers (private by default)
  proc helperFunction() { }
}
```

## Chapel-Specific Guidelines

### Avoid Reserved Words

Never use these as identifiers:

- `config`, `domain`, `bytes`, `type`, `index`
- Use alternatives: `cfg`, `testDomain`, `data`, `typeKind`, `idx`

### Use Appropriate Types

```chapel
// Prefer specific types
var count: int = 0;        // Not "var count = 0;"
var ratio: real = 0.5;     // Explicit type

// Use config for tunables
config const maxSize = 100;
```

### Iterator Patterns

```chapel
// Use iterators for sequences
iter generateValues() {
  for i in 1..10 {
    yield i * 2;
  }
}

// Use forall for parallel
forall i in 1..n {
  // parallel work
}
```

### Error Handling

```chapel
// Use try/catch for recoverable errors
try {
  riskyOperation();
} catch e: SomeError {
  handleError(e);
}

// Use halt for unrecoverable errors
if criticalFailure {
  halt("Critical failure: ", details);
}
```

## Testing Guidelines

### Test Names

```chapel
// Descriptive test names
proc testIntGeneratorProducesIntsInRange() { }
proc testShrinkerFindsMinimalCounterexample() { }
```

### Test Structure

```chapel
proc testExample() {
  // Arrange
  var gen = intGen(0, 100);

  // Act
  var value = gen.generate();

  // Assert
  assert(value >= 0 && value <= 100);
}
```

### Property Tests

```chapel
// Test properties, not examples
var prop = property(
  "descriptive property name",
  generator,
  lambda(input) { return propertyHolds(input); }
);
```

## Pull Request Checklist

- [ ] Code follows style guide
- [ ] Doc comments for public APIs
- [ ] Tests for new functionality
- [ ] No compiler warnings
- [ ] Passes `mason build && mason test`
