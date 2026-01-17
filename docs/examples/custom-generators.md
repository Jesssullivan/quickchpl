---
title: Custom Generator Examples
description: "Build generators for custom types. User records, realistic emails, weighted status, recursive trees, dates, JSON structures using map, tupleGen, frequency."
---

# Custom Generators

Build generators for your own data types.

## Using Combinators

The easiest way to create custom generators is with combinators:

```chapel title="user_generator.chpl"
use quickchpl;

record User {
  var id: int;
  var name: string;
  var email: string;
  var active: bool;
}

// Create a User generator using map and tupleGen
var userGen = map(
  tupleGen(
    intGen(1, 100000),       // id
    stringGen(20),           // name
    stringGen(30),           // email (simplified)
    boolGen()                // active
  ),
  lambda((id, name, email, active): (int, string, string, bool)) {
    return new User(id, name, email, active);
  }
);

proc main() {
  // Generate some users
  for i in 1..5 {
    var user = userGen.generate();
    writeln("User ", i, ": ", user);
  }

  // Property test with users
  var uniqueIds = property(
    "generated users have positive IDs",
    userGen,
    lambda(u: User) { return u.id > 0; }
  );

  check(uniqueIds);
}
```

## Realistic Email Generator

```chapel title="email_generator.chpl"
use quickchpl;

// Generate realistic-looking emails
var emailGen = map(
  tupleGen(
    suchThat(stringGen(10), lambda(s: string) { return s.size > 0; }),
    elements(["gmail.com", "yahoo.com", "outlook.com", "example.org"])
  ),
  lambda((user, domain): (string, string)) {
    // Clean up username (letters only for simplicity)
    var clean = "";
    for c in user {
      if (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") {
        clean += c.toLower();
      }
    }
    if clean.size == 0 then clean = "user";
    return clean + "@" + domain;
  }
);

proc main() {
  for i in 1..10 {
    writeln(emailGen.generate());
  }
}
```

## Weighted Choice Generator

```chapel title="status_generator.chpl"
use quickchpl;

enum Status { Active, Pending, Suspended, Deleted }

// Realistic distribution: most users are active
var statusGen = frequency([
  (70, constant(Status.Active)),     // 70%
  (15, constant(Status.Pending)),    // 15%
  (10, constant(Status.Suspended)),  // 10%
  (5, constant(Status.Deleted))      // 5%
]);

proc main() {
  var counts: [Status] int;

  for i in 1..1000 {
    counts[statusGen.generate()] += 1;
  }

  for s in Status {
    writeln(s, ": ", counts[s], " (", counts[s] / 10.0, "%)");
  }
}
```

## Recursive Data Structure

```chapel title="tree_generator.chpl"
use quickchpl;

class TreeNode {
  var value: int;
  var left: owned TreeNode?;
  var right: owned TreeNode?;
}

// Generate trees with controlled depth
proc treeGen(maxDepth: int = 5): TreeNode? {
  if maxDepth <= 0 then return nil;

  // 30% chance of being a leaf at each level
  if boolGen(0.3).generate() then return nil;

  var node = new TreeNode(intGen().generate());

  if maxDepth > 1 {
    node.left = treeGen(maxDepth - 1);
    node.right = treeGen(maxDepth - 1);
  }

  return node;
}

proc treeSize(node: TreeNode?): int {
  if node == nil then return 0;
  return 1 + treeSize(node!.left) + treeSize(node!.right);
}

proc main() {
  for i in 1..5 {
    var tree = treeGen(4);
    writeln("Tree ", i, " size: ", treeSize(tree));
  }
}
```

## Date/Time Generator

```chapel title="date_generator.chpl"
use quickchpl;

record Date {
  var year: int;
  var month: int;
  var day: int;
}

proc isValidDate(d: Date): bool {
  if d.month < 1 || d.month > 12 then return false;
  if d.day < 1 then return false;

  const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  var maxDays = daysInMonth[d.month - 1];

  // Leap year check
  if d.month == 2 && (d.year % 4 == 0 && (d.year % 100 != 0 || d.year % 400 == 0)) {
    maxDays = 29;
  }

  return d.day <= maxDays;
}

// Generate valid dates
var dateGen = suchThat(
  map(
    tupleGen(intGen(1900, 2100), intGen(1, 12), intGen(1, 31)),
    lambda((y, m, d): (int, int, int)) { return new Date(y, m, d); }
  ),
  lambda(d: Date) { return isValidDate(d); }
);

proc main() {
  var validDates = property(
    "generated dates are valid",
    dateGen,
    lambda(d: Date) { return isValidDate(d); }
  );

  check(validDates);

  writeln("\nSample dates:");
  for i in 1..5 {
    writeln(dateGen.generate());
  }
}
```

## JSON-like Structure

```chapel title="json_generator.chpl"
use quickchpl;

// Simplified JSON value generator
enum JsonType { Null, Bool, Number, Str, Array, Object }

var jsonTypeGen = frequency([
  (10, constant(JsonType.Null)),
  (20, constant(JsonType.Bool)),
  (30, constant(JsonType.Number)),
  (30, constant(JsonType.Str)),
  (5, constant(JsonType.Array)),
  (5, constant(JsonType.Object))
]);

proc generateJsonValue(depth: int = 3): string {
  if depth <= 0 {
    // At max depth, only generate primitives
    return oneOf(
      constant("null"),
      map(boolGen(), lambda(b: bool) { return b:string; }),
      map(intGen(-1000, 1000), lambda(n: int) { return n:string; })
    ).generate();
  }

  var typ = jsonTypeGen.generate();

  select typ {
    when JsonType.Null do return "null";
    when JsonType.Bool do return boolGen().generate():string;
    when JsonType.Number do return intGen(-1000, 1000).generate():string;
    when JsonType.Str do return "\"" + stringGen(10).generate() + "\"";
    when JsonType.Array {
      var size = intGen(0, 3).generate();
      var items: string;
      for i in 0..<size {
        if i > 0 then items += ", ";
        items += generateJsonValue(depth - 1);
      }
      return "[" + items + "]";
    }
    when JsonType.Object {
      var size = intGen(0, 3).generate();
      var pairs: string;
      for i in 0..<size {
        if i > 0 then pairs += ", ";
        var key = stringGen(8).generate();
        pairs += "\"" + key + "\": " + generateJsonValue(depth - 1);
      }
      return "{" + pairs + "}";
    }
  }
  return "null";
}

proc main() {
  writeln("Generated JSON values:");
  for i in 1..5 {
    writeln(generateJsonValue(2));
  }
}
```

## Next Steps

- [Integration Testing](integration.md) - Test with external systems
- [Patterns](../modules/patterns.md) - Common property patterns
