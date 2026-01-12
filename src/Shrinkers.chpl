// quickchpl: Shrinking Engine
// Provides type-specific shrinking for minimal counterexamples

module Shrinkers {
  use List;

  //============================================================================
  // Shrink Result
  //============================================================================

  record ShrinkResult {
    var original: string;
    var shrunk: string;
    var steps: int;
    var duration: real;

    proc init() {
      this.original = "";
      this.shrunk = "";
      this.steps = 0;
      this.duration = 0.0;
    }

    proc init(original: string, shrunk: string, steps: int, duration: real) {
      this.original = original;
      this.shrunk = shrunk;
      this.steps = steps;
      this.duration = duration;
    }
  }

  //============================================================================
  // Integer Shrinking
  //============================================================================

  // Generate shrink candidates for an integer
  // Strategy: binary search towards 0
  proc shrinkInt(value: int): list(int) {
    var candidates: list(int);

    if value == 0 then return candidates;

    // Always try 0 first (smallest possible)
    candidates.pushBack(0);

    // Binary search towards 0
    var current = value;
    while abs(current) > 1 {
      current = current / 2;
      if current != 0 && !candidates.contains(current) {
        candidates.pushBack(current);
      }
    }

    // Try immediate neighbors
    if value > 0 {
      if value - 1 != 0 && !candidates.contains(value - 1) {
        candidates.pushBack(value - 1);
      }
    } else {
      if value + 1 != 0 && !candidates.contains(value + 1) {
        candidates.pushBack(value + 1);
      }
    }

    return candidates;
  }

  // Shrink an integer failure
  proc shrinkIntFailure(value: int, pred, maxSteps: int = 1000): (int, int) {
    var current = value;
    var steps = 0;

    while steps < maxSteps {
      const candidates = shrinkInt(current);
      var foundSmaller = false;

      for candidate in candidates {
        // If the property still fails with the candidate, shrink further
        if !pred(candidate) {
          current = candidate;
          foundSmaller = true;
          steps += 1;
          break;
        }
      }

      if !foundSmaller then break;
    }

    return (current, steps);
  }

  //============================================================================
  // Real Shrinking
  //============================================================================

  // Generate shrink candidates for a real number
  proc shrinkReal(value: real): list(real) {
    var candidates: list(real);

    if value == 0.0 then return candidates;

    // Try 0
    candidates.pushBack(0.0);

    // Try truncating to integer
    const truncated = value: int: real;
    if truncated != value && truncated != 0.0 {
      candidates.pushBack(truncated);
    }

    // Try rounding
    const rounded = round(value);
    if rounded != value && rounded != 0.0 && !candidates.contains(rounded) {
      candidates.pushBack(rounded);
    }

    // Binary search towards 0
    var current = value;
    while abs(current) > 0.001 {
      current = current / 2.0;
      if !candidates.contains(current) {
        candidates.pushBack(current);
      }
    }

    return candidates;
  }

  //============================================================================
  // Boolean Shrinking
  //============================================================================

  // Generate shrink candidates for a boolean
  // Strategy: false is simpler than true
  proc shrinkBool(value: bool): list(bool) {
    var candidates: list(bool);

    if value == true {
      candidates.pushBack(false);
    }

    return candidates;
  }

  //============================================================================
  // String Shrinking
  //============================================================================

  // Generate shrink candidates for a string
  // Strategy: try empty, remove chars, simplify chars
  proc shrinkString(value: string): list(string) {
    var candidates: list(string);

    if value.size == 0 then return candidates;

    // Try empty string
    candidates.pushBack("");

    // Try removing characters from the end
    for newLen in 1..<value.size {
      const shortened = value[0..<newLen];
      if !candidates.contains(shortened) {
        candidates.pushBack(shortened);
      }
    }

    // Try removing single characters
    for i in 0..<value.size {
      var without = "";
      for j in 0..<value.size {
        if j != i then without += value[j];
      }
      if !candidates.contains(without) {
        candidates.pushBack(without);
      }
    }

    // Try simplifying characters to 'a'
    for i in 0..<value.size {
      if value[i] != "a" {
        var simplified = value[0..<i] + "a" + value[i+1..];
        if !candidates.contains(simplified) {
          candidates.pushBack(simplified);
        }
      }
    }

    return candidates;
  }

  //============================================================================
  // List Shrinking
  //============================================================================

  // Generate shrink candidates for a list of integers
  proc shrinkIntList(value: list(int)): list(list(int)) {
    var candidates: list(list(int));

    if value.size == 0 then return candidates;

    // Try empty list
    var empty: list(int);
    candidates.pushBack(empty);

    // Try removing elements from the end
    for newSize in 1..<value.size {
      var shortened: list(int);
      for i in 0..<newSize {
        shortened.pushBack(value[i]);
      }
      candidates.pushBack(shortened);
    }

    // Try removing single elements
    for i in 0..<value.size {
      var without: list(int);
      for j in 0..<value.size {
        if j != i then without.pushBack(value[j]);
      }
      candidates.pushBack(without);
    }

    // Try shrinking individual elements
    for i in 0..<value.size {
      const elemCandidates = shrinkInt(value[i]);
      for shrunkElem in elemCandidates {
        var modified: list(int);
        for j in 0..<value.size {
          if j == i then modified.pushBack(shrunkElem);
          else modified.pushBack(value[j]);
        }
        candidates.pushBack(modified);
      }
    }

    return candidates;
  }

  //============================================================================
  // Tuple Shrinking
  //============================================================================

  // Shrink a 2-tuple of integers
  proc shrinkIntTuple2(value: (int, int)): list((int, int)) {
    var candidates: list((int, int));

    const (a, b) = value;

    // Shrink first element
    for shrunkA in shrinkInt(a) {
      candidates.pushBack((shrunkA, b));
    }

    // Shrink second element
    for shrunkB in shrinkInt(b) {
      candidates.pushBack((a, shrunkB));
    }

    // Shrink both
    for shrunkA in shrinkInt(a) {
      for shrunkB in shrinkInt(b) {
        candidates.pushBack((shrunkA, shrunkB));
      }
    }

    return candidates;
  }

  // Shrink a 3-tuple of integers
  proc shrinkIntTuple3(value: (int, int, int)): list((int, int, int)) {
    var candidates: list((int, int, int));

    const (a, b, c) = value;

    // Shrink each element individually
    for shrunkA in shrinkInt(a) {
      candidates.pushBack((shrunkA, b, c));
    }
    for shrunkB in shrinkInt(b) {
      candidates.pushBack((a, shrunkB, c));
    }
    for shrunkC in shrinkInt(c) {
      candidates.pushBack((a, b, shrunkC));
    }

    return candidates;
  }

  //============================================================================
  // Generic Shrink Dispatcher
  //============================================================================

  // Shrink an integer
  proc shrink(value: int): list(int) {
    return shrinkInt(value);
  }

  // Shrink a real
  proc shrink(value: real): list(real) {
    return shrinkReal(value);
  }

  // Shrink a bool
  proc shrink(value: bool): list(bool) {
    return shrinkBool(value);
  }

  // Shrink a string
  proc shrink(value: string): list(string) {
    return shrinkString(value);
  }

  // Shrink a list of ints
  proc shrink(value: list(int)): list(list(int)) {
    return shrinkIntList(value);
  }

  // Shrink a 2-tuple of ints
  proc shrink(value: (int, int)): list((int, int)) {
    return shrinkIntTuple2(value);
  }

  // Shrink a 3-tuple of ints
  proc shrink(value: (int, int, int)): list((int, int, int)) {
    return shrinkIntTuple3(value);
  }
}
