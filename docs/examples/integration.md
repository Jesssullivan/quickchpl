---
title: Integration Testing Examples
description: "Test real-world scenarios. CSV parser round-trips, sorting algorithm properties, hash function determinism, state machine transitions. CI/CD integration with TAP/JUnit."
---

# Integration Testing

Using quickchpl to test real-world scenarios and integrations.

## Testing Data Parsers

```chapel title="parser_test.chpl"
use quickchpl;

// Simple CSV parser
proc parseCSVLine(line: string): list(string) {
  var fields: list(string);
  var current = "";

  for c in line {
    if c == "," {
      fields.pushBack(current);
      current = "";
    } else {
      current += c;
    }
  }
  fields.pushBack(current);

  return fields;
}

proc formatCSVLine(fields: list(string)): string {
  var result = "";
  for (i, f) in zip(0.., fields) {
    if i > 0 then result += ",";
    result += f;
  }
  return result;
}

proc main() {
  // Generator for CSV-safe strings (no commas)
  var safeStringGen = suchThat(
    stringGen(20),
    lambda(s: string) { return !s.find(","); }
  );

  // Generator for CSV lines
  var csvLineGen = map(
    listGen(safeStringGen, 1, 5),
    lambda(fields: list(string)) { return formatCSVLine(fields); }
  );

  // Round-trip property
  var roundTrip = property(
    "CSV parse/format round-trip",
    csvLineGen,
    lambda(line: string) {
      var parsed = parseCSVLine(line);
      var formatted = formatCSVLine(parsed);
      return formatted == line;
    }
  );

  check(roundTrip);
}
```

## Testing Sorting Algorithms

```chapel title="sort_test.chpl"
use quickchpl;
use Sort;

proc main() {
  // Sorted output is same length
  var preservesLength = property(
    "sort preserves length",
    listGen(intGen(), 0, 100),
    lambda(lst: list(int)) {
      var arr = lst.toArray();
      sort(arr);
      return arr.size == lst.size;
    }
  );

  // Sorted output is actually sorted
  var isSorted = property(
    "sort produces sorted output",
    listGen(intGen(), 0, 100),
    lambda(lst: list(int)) {
      var arr = lst.toArray();
      sort(arr);
      for i in 0..<arr.size-1 {
        if arr[i] > arr[i+1] then return false;
      }
      return true;
    }
  );

  // Sorting is idempotent
  var idempotent = property(
    "sorting is idempotent",
    listGen(intGen(), 0, 100),
    lambda(lst: list(int)) {
      var arr1 = lst.toArray();
      sort(arr1);
      var arr2 = arr1;  // Copy
      sort(arr2);
      return arr1.equals(arr2);
    }
  );

  // Sorted output contains same elements
  var sameElements = property(
    "sort preserves elements",
    listGen(intGen(-100, 100), 0, 50),
    lambda(lst: list(int)) {
      var original = lst.toArray();
      var sorted = lst.toArray();
      sort(sorted);
      sort(original);  // Sort original too for comparison
      return original.equals(sorted);
    }
  );

  check(preservesLength);
  check(isSorted);
  check(idempotent);
  check(sameElements);
}
```

## Testing Hash Functions

```chapel title="hash_test.chpl"
use quickchpl;

proc simpleHash(s: string): int {
  var hash = 0;
  for c in s {
    hash = hash * 31 + c.toByte():int;
  }
  return hash;
}

proc main() {
  // Deterministic: same input -> same output
  var deterministic = property(
    "hash is deterministic",
    stringGen(50),
    lambda(s: string) {
      return simpleHash(s) == simpleHash(s);
    }
  );

  // Equal inputs have equal hashes
  var equalInputs = property(
    "equal strings have equal hashes",
    stringGen(50),
    lambda(s: string) {
      var copy = s;
      return simpleHash(s) == simpleHash(copy);
    }
  );

  check(deterministic);
  check(equalInputs);
}
```

## Testing State Machines

```chapel title="state_machine_test.chpl"
use quickchpl;

enum State { Idle, Running, Paused, Stopped }
enum Event { Start, Pause, Resume, Stop }

proc transition(state: State, event: Event): State {
  select (state, event) {
    when (State.Idle, Event.Start) do return State.Running;
    when (State.Running, Event.Pause) do return State.Paused;
    when (State.Running, Event.Stop) do return State.Stopped;
    when (State.Paused, Event.Resume) do return State.Running;
    when (State.Paused, Event.Stop) do return State.Stopped;
    otherwise do return state;  // Invalid transition stays in same state
  }
}

proc main() {
  var eventGen = elements([Event.Start, Event.Pause, Event.Resume, Event.Stop]);

  // Stopped is absorbing (can't leave)
  var stoppedAbsorbing = property(
    "stopped is absorbing state",
    eventGen,
    lambda(e: Event) {
      return transition(State.Stopped, e) == State.Stopped;
    }
  );

  // Can always stop from running or paused
  var canAlwaysStop = property(
    "can stop from running or paused",
    elements([State.Running, State.Paused]),
    lambda(s: State) {
      return transition(s, Event.Stop) == State.Stopped;
    }
  );

  check(stoppedAbsorbing);
  check(canAlwaysStop);
}
```

## Testing with External Data

```chapel title="external_data_test.chpl"
use quickchpl;
use IO;

// Test with data from files
proc loadTestCases(filename: string): list((int, int, int)) {
  var cases: list((int, int, int));

  try {
    var f = open(filename, ioMode.r);
    var reader = f.reader();

    var a, b, expected: int;
    while reader.read(a, b, expected) {
      cases.pushBack((a, b, expected));
    }
  } catch {
    writeln("Warning: Could not load test cases from ", filename);
  }

  return cases;
}

proc main() {
  // Generate test cases and verify against known good implementation
  var additionCorrect = property(
    "addition matches expected",
    tupleGen(intGen(-1000, 1000), intGen(-1000, 1000)),
    lambda((a, b): (int, int)) {
      var result = a + b;
      var expected = a + b;  // In real test, use reference implementation
      return result == expected;
    }
  );

  check(additionCorrect);
}
```

## CI/CD Integration

Run quickchpl tests in continuous integration:

```yaml title=".github/workflows/test.yml"
name: Property Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - uses: actions/checkout@v4

      - name: Run property tests
        run: |
          chpl tests/properties/*.chpl src/*.chpl -o run_tests
          ./run_tests --numTests=500

      - name: Generate TAP report
        run: |
          ./run_tests --output=tap > test-results.tap

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test-results.tap
```

## Next Steps

- [Reporters](../modules/reporters.md) - CI-friendly output formats
- [Patterns](../modules/patterns.md) - Common testing patterns
