# quickchpl

**Simple Property-Based Testing for Chapel**

[![Chapel](https://img.shields.io/badge/Chapel-2.6%2B-blue)](https://chapel-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitLab](https://img.shields.io/badge/GitLab-tinyland%2Fquickchpl-orange)](https://gitlab.com/tinyland/projects/quickchpl)

Inspired by QuickCheck and my father ^w^


Manual installation:
```bash
# clone
export CHPL_MODULE_PATH=$CHPL_MODULE_PATH:$PWD/quickchpl/src
```


```chapel
use quickchpl;

proc main() {
  // Test that addition is commutative
  var gen = tupleGen(intGen(-100, 100), intGen(-100, 100));
  var prop = property(
    "addition is commutative",
    gen,
    proc((a, b): (int, int)) { return a + b == b + a; }
  );

  var result = check(prop);
  if result.passed {
    writeln("✓ ", prop.name, " passed ", result.numTests, " tests");
  } else {
    writeln("✗ ", prop.name, " FAILED");
    writeln("  Counterexample: ", result.failureInfo);
  }
}
```

Compile and run:
```bash
chpl my_test.chpl -M path/to/quickchpl/src
./my_test
```

Output:
```
✓ addition is commutative passed 100 tests
```

## Generators

### Primitive Generators

```chapel
// Integers
var intG = intGen(-100, 100);           // Range [-100, 100]
var natG = natGen(1000);                 // Natural numbers [0, 1000]
var posG = positiveIntGen(1000);         // Positive [1, 1000]

// Real numbers
var realG = realGen(0.0, 1.0);           // Uniform [0, 1)
var normalG = realGen(0.0, 1.0, Distribution.Normal);

// Booleans
var boolG = boolGen(0.5);                // 50% true probability

// Strings
var strG = stringGen(0, 50);             // Length 0-50, alphanumeric
var alphaG = alphaGen(5, 10);            // Alphabetic only
```

### Composite Generators

```chapel
// Tuples
var pairG = tupleGen(intGen(), stringGen());
var tripleG = tupleGen(intGen(), intGen(), intGen());

// Lists
var listG = listGen(intGen(), 0, 10);    // List of 0-10 integers

// Fixed values
var constG = constantGen(42);
```

### Generator Combinators

```chapel
// Transform output
var doubledG = map(intGen(), proc(x: int) { return x * 2; });

// Filter values
var evenG = filter(intGen(), proc(x: int) { return x % 2 == 0; });

// Combine generators
var zippedG = zip(intGen(), stringGen());

// Random choice
var choiceG = oneOf(intGen(0, 10), intGen(100, 200));

// Weighted choice
var weightedG = frequency(9, intGen(0, 10), 1, intGen(1000, 2000));
```

## Properties

### Basic Properties

```chapel
var prop = property(
  "absolute value is non-negative",
  intGen(),
  proc(x: int) { return abs(x) >= 0; }
);

var result = check(prop);
assert(result.passed);
```

### Conditional Properties (Implication)

```chapel
// Property only checked when condition is true
var prop = property(
  "division by non-zero",
  tupleGen(intGen(), intGen()),
  proc((a, b): (int, int)) {
    return (b != 0) ==> (a / b * b == a - a % b);
  }
);
```

### Convenience Functions

```chapel
// Quick one-liner check
assert(quickCheck(intGen(), proc(x: int) { return x + 0 == x; }));

// forAll syntax
var result = forAll(intGen(), proc(x: int) { return x * 1 == x; });
```

## Property Patterns

The `Patterns` module provides reusable property templates:

### Algebraic Patterns

```chapel
use quickchpl.Patterns;

// Test algebraic properties of addition
var gen = intGen(-100, 100);

var commProp = commutativeProperty("addition", gen,
  proc(a: int, b: int) { return a + b; });

var assocProp = associativeProperty("addition", gen,
  proc(a: int, b: int) { return a + b; });

var idProp = identityProperty("addition", gen,
  proc(a: int, b: int) { return a + b; }, 0);
```

### Functional Patterns

```chapel
// Idempotence: f(f(x)) = f(x)
var idempProp = idempotentProperty("abs", intGen(), abs);

// Involution: f(f(x)) = x
var involudProp = involutionProperty("negate", intGen(),
  proc(x: int) { return -x; });

// Round-trip: decode(encode(x)) = x
var roundTripProp = roundTripProperty("int<->string", intGen(),
  proc(x: int) { return x:string; },
  proc(s: string) { return s:int; }
);
```

## Shrinking

When a property fails, quickchpl automatically shrinks the counterexample to find the minimal failing case:

```chapel
// Property fails for x >= 50
var prop = property(
  "x is small",
  intGen(0, 1000),
  proc(x: int) { return x < 50; }
);

var result = check(prop);
// result.failureInfo might be "847"
// result.shrunkInfo will be "50" (minimal failing case)
```

### Shrinking Strategies

- **Integers**: Binary search towards 0
- **Reals**: Try 0, truncated, rounded values
- **Strings**: Try empty, remove chars, simplify to 'a'
- **Lists**: Try empty, remove elements, shrink elements
- **Tuples**: Shrink each component


### GitLab CI

```yaml
include:
  - remote: 'https://gitlab.com/tinyland/projects/quickchpl/-/raw/main/ci/.gitlab-ci.yml'

property_tests:
  extends: .property_test_template
  script:
    - chpl tests/my_properties.chpl -M quickchpl/src -o /tmp/props
    - /tmp/props --numTests=1000
```

### GitHub Actions

```yaml
- name: Run property tests
  run: |
    chpl tests/my_properties.chpl -M quickchpl/src -o /tmp/props
    /tmp/props --numTests=1000
```


## Configuration

```bash
./my_tests --numTests=1000 --maxShrinkSteps=500 --verbose=true
```

...Or in code:

```chapel
var runner = new PropertyRunner(
  numTests = 1000,
  maxShrinkSteps = 500,
  verboseMode = true
);
var result = runner.check(prop);
```



## API 

### Core Types

| Type | Description |
|------|-------------|
| `IntGenerator` | Generates random integers |
| `RealGenerator` | Generates random real numbers |
| `BoolGenerator` | Generates random booleans |
| `StringGenerator` | Generates random strings |
| `Property` | Defines a property to test |
| `PropertyRunner` | Executes property tests |
| `TestResult` | Contains test results |

### Functions

| Function | Description |
|----------|-------------|
| `intGen(min, max)` | Create integer generator |
| `property(name, gen, pred)` | Define a property |
| `check(prop)` | Run property test |
| `quickCheck(gen, pred)` | One-liner property check |
| `shrink(value)` | Generate shrink candidates |



### Todos & Future work:
- [x] Integrate with Chapel Mason package repo (in progress)
- [ ] Integrate Outbot Harness 
- [x] Integrate with (and `[ ]` publish) sister projects, `chapel-k8s-mail`, `chapel-git`, `tinymachines`, `mariolex`)
- [x] Add IDE and LLM friendly text and code completions (docs in the works)
- [x] Provide public demo (`aoc-2025` **done! one is good for now**)


