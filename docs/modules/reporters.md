---
title: Reporters Module API
description: "Output formats: Console, TAP, JUnit XML. Functions: printResult(), formatTAP(), formatJUnit(), writeTAP(), writeJUnit(). ANSI colors: greenText(), redText()."
---

# Reporters Module

The `Reporters` module provides formatted output for test results.

## Output Formats

### Console Output

Human-readable console output:

```chapel
printResult(true, "addition commutes", 100);
// Output: ✓ addition commutes passed 100 tests

printResult(false, "subtraction commutes", 1, "(5, 3)");
// Output: ✗ subtraction commutes FAILED
//         Counterexample: (5, 3)
```

### TAP (Test Anything Protocol)

Machine-readable format for CI integration:

```chapel
var results: list((bool, string, int, string));
results.pushBack((true, "prop1", 100, ""));
results.pushBack((false, "prop2", 1, "(5,3)"));

writeln(formatTAP(results));
// Output:
// TAP version 13
// 1..2
// ok 1 - prop1
// not ok 2 - prop2
//   ---
//   counterexample: (5,3)
//   ...
```

### JUnit XML

XML format for IDEs and CI tools:

```chapel
var results: list((bool, string, int, string, real));
results.pushBack((true, "prop1", 100, "", 0.1));
results.pushBack((false, "prop2", 1, "(5,3)", 0.2));

writeln(formatJUnit("my-tests", results));
// Output:
// <?xml version="1.0" encoding="UTF-8"?>
// <testsuite name="my-tests" tests="2" failures="1" time="0.3">
//   <testcase name="prop1" time="0.1"/>
//   <testcase name="prop2" time="0.2">
//     <failure message="Property failed">
//       Counterexample: (5,3)
//     </failure>
//   </testcase>
// </testsuite>
```

## Functions

### Console Functions

```chapel
// Format as string
var s = formatResult(passed, name, numTests, failureInfo, shrunkInfo);

// Print directly
printResult(passed, name, numTests, failureInfo, shrunkInfo);

// Print summary
printSummary(numPassed, numFailed, totalTests, duration);
```

### TAP Functions

```chapel
// Format as string
var tap = formatTAP(results);

// Write to file
writeTAP("results.tap", results);
```

### JUnit Functions

```chapel
// Format as string
var xml = formatJUnit(suiteName, results);

// Write to file
writeJUnit("results.xml", suiteName, results);
```

### Progress Functions

```chapel
// Print progress indicator (. for pass, F for fail)
printProgress(testNum, passed);

// Print spinner for long-running tests
printSpinner(step);
```

## Color Support

ANSI color codes for terminal output:

```chapel
writeln(greenText("Success!"));   // Green
writeln(redText("Failed!"));      // Red
writeln(yellowText("Warning!"));  // Yellow
writeln(boldText("Important!"));  // Bold
```

### Colored Results

```chapel
var s = formatResultColor(passed, name, numTests, failureInfo, shrunkInfo);
writeln(s);  // Output with ANSI colors
```

## Verbosity Levels

```chapel
enum Verbosity {
  Quiet,      // Only show final summary
  Normal,     // Show failures only
  Verbose,    // Show all tests
  Exhaustive  // Show all, don't stop on failure
}
```

## Examples

### CI Integration with TAP

```chapel
var results: list((bool, string, int, string));

for prop in properties {
  var result = check(prop);
  results.pushBack((result.passed, prop.name, result.numTests, result.failureInfo));
}

writeTAP("test-results.tap", results);
```

### JUnit for Jenkins/GitHub Actions

```chapel
var results: list((bool, string, int, string, real));

for prop in properties {
  var start = getCurrentTime();
  var result = check(prop);
  var duration = getCurrentTime() - start;
  results.pushBack((result.passed, prop.name, result.numTests, result.failureInfo, duration));
}

writeJUnit("test-results.xml", "quickchpl-tests", results);
```

## See Also

- [Properties](properties.md) - Running tests
- [Examples](../examples/basic.md) - Usage examples
