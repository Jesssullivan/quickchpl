---
title: First Property Test
description: "Step-by-step guide to writing your first property test. Tests string reversal with involution and length preservation properties."
---

# First Property Test

A step-by-step guide to writing your first property test with quickchpl.

## The Scenario

Let's test a simple function that reverses a string. We'll verify two properties:

1. **Involution**: Reversing twice returns the original
2. **Length preservation**: Reversing doesn't change length

## Step 1: The Function Under Test

```chapel title="reverse.chpl"
proc reverse(s: string): string {
  var result = "";
  for i in 0..<s.size by -1 {
    result += s[s.size - 1 - i];
  }
  return result;
}
```

## Step 2: Import quickchpl

```chapel
use quickchpl;
```

## Step 3: Define Properties

### Property 1: Involution

Reversing a string twice should give back the original:

```chapel
var reverseInvolution = property(
  "reverse is an involution",
  stringGen(20),  // Strings up to 20 chars
  lambda(s: string) {
    return reverse(reverse(s)) == s;
  }
);
```

### Property 2: Length Preservation

Reversing shouldn't change the length:

```chapel
var preservesLength = property(
  "reverse preserves length",
  stringGen(20),
  lambda(s: string) {
    return reverse(s).size == s.size;
  }
);
```

## Step 4: Run the Tests

```chapel
writeln("Testing string reverse...\n");

var result1 = check(reverseInvolution);
printResult(result1.passed, "reverse involution", result1.numTests);

var result2 = check(preservesLength);
printResult(result2.passed, "length preservation", result2.numTests);
```

## Complete Example

```chapel title="test_reverse.chpl"
use quickchpl;

// Function under test
proc reverse(s: string): string {
  var result = "";
  for i in 0..<s.size by -1 {
    result += s[s.size - 1 - i];
  }
  return result;
}

proc main() {
  writeln("=== Testing String Reverse ===\n");

  // Property 1: Involution
  var reverseInvolution = property(
    "reverse is an involution",
    stringGen(20),
    lambda(s: string) {
      return reverse(reverse(s)) == s;
    }
  );

  // Property 2: Length preservation
  var preservesLength = property(
    "reverse preserves length",
    stringGen(20),
    lambda(s: string) {
      return reverse(s).size == s.size;
    }
  );

  // Run tests
  var result1 = check(reverseInvolution);
  printResult(result1.passed, "reverse involution", result1.numTests);

  var result2 = check(preservesLength);
  printResult(result2.passed, "length preservation", result2.numTests);

  writeln("\n=== Tests Complete ===");
}
```

## Running the Tests

```bash
chpl test_reverse.chpl -o test_reverse
./test_reverse
```

Expected output:

```
=== Testing String Reverse ===

✓ reverse is an involution passed 100 tests
✓ reverse preserves length passed 100 tests

=== Tests Complete ===
```

## What Happens on Failure?

If a property fails, quickchpl:

1. Reports the failing input
2. Attempts to **shrink** it to find the minimal counterexample

For example, if reverse had a bug with empty strings:

```
✗ reverse is an involution FAILED
  Counterexample: ""
  Shrunk to: ""
```

## Using Patterns

The involution property is so common that quickchpl provides it:

```chapel
// Using the built-in isInvolution pattern
var reverseInvolution = property(
  "reverse is an involution",
  stringGen(20),
  lambda(s: string) {
    return isInvolution(s, lambda(x: string) { return reverse(x); });
  }
);
```

## Next Steps

- [Generators](../concepts/generators.md) - Learn about all generator types
- [Properties](../concepts/properties.md) - Advanced property patterns
- [Shrinking](../concepts/shrinking.md) - Understanding counterexample minimization
