/*
  Shrinkers Module
  ================

  Type-specific shrinking for minimal counterexamples.

  When a property test fails, shrinking attempts to find the smallest
  input that still causes the failure. This makes debugging much easier
  by reducing complex failing inputs to simple, minimal cases.

  **Shrinking Strategies:**

  - Integers: Binary search towards 0
  - Reals: Truncate, round, binary search towards 0
  - Booleans: true shrinks to false
  - Strings: Remove characters, simplify to 'a'
  - Lists: Remove elements, shrink individual elements
  - Tuples: Shrink each component

  **Core Functions:**

  - :proc:`shrink` - Generic dispatcher for type-specific shrinking
  - :proc:`shrinkInt` - Generate shrink candidates for integers
  - :proc:`shrinkReal` - Generate shrink candidates for reals
  - :proc:`shrinkString` - Generate shrink candidates for strings
  - :proc:`shrinkIntList` - Generate shrink candidates for int lists

  Example::

    use Shrinkers;

    // Shrink a failing integer
    var candidates = shrinkInt(42);
    // candidates = [0, 21, 10, 5, 2, 1, 41]
*/
module Shrinkers {
  use List;

  /*
    Shrink Result
    -------------

    Result of a shrinking operation.
  */

  /*
    Result of shrinking a counterexample.

    :var original: Original failing value (as string)
    :var shrunk: Minimized failing value (as string)
    :var steps: Number of shrinking iterations
    :var duration: Time spent shrinking (seconds)
  */
  record ShrinkResult {
    var original: string;
    var shrunk: string;
    var steps: int;
    var duration: real;

    /*
      Create an empty shrink result.
    */
    proc init() {
      this.original = "";
      this.shrunk = "";
      this.steps = 0;
      this.duration = 0.0;
    }

    /*
      Create a shrink result with values.

      :arg original: Original failing value
      :arg shrunk: Minimized failing value
      :arg steps: Shrinking iterations performed
      :arg duration: Time spent shrinking
    */
    proc init(original: string, shrunk: string, steps: int, duration: real) {
      this.original = original;
      this.shrunk = shrunk;
      this.steps = steps;
      this.duration = duration;
    }
  }

  /*
    Integer Shrinking
    -----------------

    Strategy: Binary search towards 0 (the simplest integer).
  */

  /*
    Generate shrink candidates for an integer.

    Strategy: Try 0 first, then binary search towards 0,
    then try immediate neighbors.

    :arg value: Integer to shrink
    :returns: List of candidate smaller values

    Example::

      var candidates = shrinkInt(100);
      // [0, 50, 25, 12, 6, 3, 1, 99]
  */
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

  /*
    Shrink an integer failure to find minimal counterexample.

    Repeatedly shrinks the value while the property still fails.

    :arg value: Initial failing value
    :arg pred: Predicate that should return true for valid values
    :arg maxSteps: Maximum shrinking iterations
    :returns: Tuple of (minimized value, steps taken)

    Example::

      var (minimal, steps) = shrinkIntFailure(1000,
        lambda(x: int) { return x < 50; });
      // minimal = 50, the smallest value where pred returns false
  */
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

  /*
    Real Number Shrinking
    ---------------------

    Strategy: Try 0, truncate to integer, round, then binary search.
  */

  /*
    Generate shrink candidates for a real number.

    Strategy: Try 0, truncate to integer, round to nearest integer,
    then binary search towards 0.

    :arg value: Real number to shrink
    :returns: List of candidate smaller values

    Example::

      var candidates = shrinkReal(3.14159);
      // [0.0, 3.0, 1.57, 0.785, ...]
  */
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

  /*
    Boolean Shrinking
    -----------------

    Strategy: false is simpler than true.
  */

  /*
    Generate shrink candidates for a boolean.

    Strategy: true shrinks to false, false has no shrinks.

    :arg value: Boolean to shrink
    :returns: List containing [false] if value is true, empty otherwise
  */
  proc shrinkBool(value: bool): list(bool) {
    var candidates: list(bool);

    if value == true {
      candidates.pushBack(false);
    }

    return candidates;
  }

  /*
    String Shrinking
    ----------------

    Strategy: Try empty, remove characters, simplify characters to 'a'.
  */

  /*
    Generate shrink candidates for a string.

    Strategy:
    1. Try empty string
    2. Remove characters from the end
    3. Remove single characters
    4. Simplify characters to 'a'

    :arg value: String to shrink
    :returns: List of candidate smaller strings

    Example::

      var candidates = shrinkString("hello");
      // ["", "h", "he", "hel", "hell", "ello", "hllo", "helo", "aello", ...]
  */
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

  /*
    List Shrinking
    --------------

    Strategy: Try empty, remove elements, shrink individual elements.
  */

  /*
    Generate shrink candidates for a list of integers.

    Strategy:
    1. Try empty list
    2. Remove elements from the end
    3. Remove single elements
    4. Shrink individual elements

    :arg value: List to shrink
    :returns: List of candidate smaller lists

    Example::

      var myList: list(int);
      myList.pushBack(10);
      myList.pushBack(20);

      var candidates = shrinkIntList(myList);
      // [[], [10], [20], [0, 20], [5, 20], [10, 0], [10, 10], ...]
  */
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

  /*
    Tuple Shrinking
    ---------------

    Shrink tuples by shrinking each component.
  */

  /*
    Generate shrink candidates for a 2-tuple of integers.

    Shrinks each component independently and in combination.

    :arg value: 2-tuple to shrink
    :returns: List of candidate smaller tuples

    Example::

      var candidates = shrinkIntTuple2((10, 20));
      // [(0, 20), (5, 20), (10, 0), (10, 10), (0, 0), (5, 10), ...]
  */
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

  /*
    Generate shrink candidates for a 3-tuple of integers.

    Shrinks each component independently.

    :arg value: 3-tuple to shrink
    :returns: List of candidate smaller tuples
  */
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

  /*
    Generic Shrink Dispatcher
    -------------------------

    Type-dispatched shrinking for common types.
  */

  /*
    Shrink an integer (dispatches to shrinkInt).

    :arg value: Integer to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: int): list(int) {
    return shrinkInt(value);
  }

  /*
    Shrink a real number (dispatches to shrinkReal).

    :arg value: Real to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: real): list(real) {
    return shrinkReal(value);
  }

  /*
    Shrink a boolean (dispatches to shrinkBool).

    :arg value: Boolean to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: bool): list(bool) {
    return shrinkBool(value);
  }

  /*
    Shrink a string (dispatches to shrinkString).

    :arg value: String to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: string): list(string) {
    return shrinkString(value);
  }

  /*
    Shrink a list of integers (dispatches to shrinkIntList).

    :arg value: List to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: list(int)): list(list(int)) {
    return shrinkIntList(value);
  }

  /*
    Shrink a 2-tuple of integers (dispatches to shrinkIntTuple2).

    :arg value: Tuple to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: (int, int)): list((int, int)) {
    return shrinkIntTuple2(value);
  }

  /*
    Shrink a 3-tuple of integers (dispatches to shrinkIntTuple3).

    :arg value: Tuple to shrink
    :returns: List of shrink candidates
  */
  proc shrink(value: (int, int, int)): list((int, int, int)) {
    return shrinkIntTuple3(value);
  }
}
