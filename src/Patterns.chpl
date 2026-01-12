/*
  Patterns Module
  ===============

  Reusable property patterns for common testing scenarios.

  This module provides predicate functions for testing common mathematical
  and programming properties. These are building blocks that can be composed
  with generators to create property tests.

  **Algebraic Properties:**

  - :proc:`isAssociative` - (a op b) op c = a op (b op c)
  - :proc:`isCommutative` - a op b = b op a
  - :proc:`hasIdentity` - a op e = a and e op a = a
  - :proc:`hasInverse` - a op inv(a) = e
  - :proc:`isDistributive` - a * (b + c) = (a * b) + (a * c)

  **Functional Properties:**

  - :proc:`isIdempotent` - f(f(x)) = f(x)
  - :proc:`isInvolution` - f(f(x)) = x
  - :proc:`isHomomorphism` - f(a op b) = f(a) op f(b)
  - :proc:`isMonotonic` - a <= b implies f(a) <= f(b)

  **Round-Trip Properties:**

  - :proc:`isRoundTrip` - decode(encode(x)) = x

  **Ordering Properties:**

  - :proc:`isReflexive` - a <= a
  - :proc:`isAntisymmetric` - a <= b and b <= a implies a = b
  - :proc:`isTransitive` - a <= b and b <= c implies a <= c

  **Logic:**

  - :proc:`implies` - condition => conclusion

  Example::

    use Patterns;
    use Properties;
    use Generators;

    // Test that addition is commutative
    var prop = property("add commutes",
                        tupleGen(intGen(), intGen()),
                        lambda((a, b): (int, int)) {
                          return isCommutative(a, b, lambda(x: int, y: int) { return x + y; });
                        });
*/
module Patterns {
  use List;

  /*
    Algebraic Property Predicates
    -----------------------------

    Test mathematical properties of operations.
  */

  /*
    Check associativity: (a op b) op c = a op (b op c).

    :arg a: First value
    :arg b: Second value
    :arg c: Third value
    :arg op: Binary operation
    :returns: true if operation is associative for these values

    Example::

      // Test addition associativity
      var result = isAssociative(1, 2, 3, lambda(x: int, y: int) { return x + y; });
      // (1 + 2) + 3 = 1 + (2 + 3) = 6, so result is true
  */
  proc isAssociative(a, b, c, op): bool {
    const left = op(op(a, b), c);
    const right = op(a, op(b, c));
    return left == right;
  }

  /*
    Check commutativity: a op b = b op a.

    :arg a: First value
    :arg b: Second value
    :arg op: Binary operation
    :returns: true if operation is commutative for these values
  */
  proc isCommutative(a, b, op): bool {
    return op(a, b) == op(b, a);
  }

  /*
    Check identity: a op e = a and e op a = a.

    :arg a: Value to test
    :arg e: Candidate identity element
    :arg op: Binary operation
    :returns: true if e is identity for op with respect to a
  */
  proc hasIdentity(a, e, op): bool {
    return op(a, e) == a && op(e, a) == a;
  }

  /*
    Check inverse: a op inv(a) = e and inv(a) op a = e.

    :arg a: Value to test
    :arg inv: Inverse function
    :arg e: Identity element
    :arg op: Binary operation
    :returns: true if inv(a) is inverse of a under op
  */
  proc hasInverse(a, inv, e, op): bool {
    const invA = inv(a);
    return op(a, invA) == e && op(invA, a) == e;
  }

  /*
    Check distributivity: a * (b + c) = (a * b) + (a * c).

    :arg a: First value
    :arg b: Second value
    :arg c: Third value
    :arg mult: Multiplication-like operation
    :arg add: Addition-like operation
    :returns: true if mult distributes over add
  */
  proc isDistributive(a, b, c, mult, add): bool {
    const left = mult(a, add(b, c));
    const right = add(mult(a, b), mult(a, c));
    return left == right;
  }

  /*
    Check absorption: a meet (a join b) = a.

    :arg a: First value
    :arg b: Second value
    :arg meet: Meet/infimum operation
    :arg join: Join/supremum operation
    :returns: true if absorption law holds
  */
  proc isAbsorptive(a, b, meet, join): bool {
    return meet(a, join(a, b)) == a;
  }

  /*
    Functional Property Predicates
    ------------------------------

    Test properties of functions.
  */

  /*
    Check idempotence: f(f(x)) = f(x).

    :arg x: Input value
    :arg f: Function to test
    :returns: true if f is idempotent for x
  */
  proc isIdempotent(x, f): bool {
    return f(f(x)) == f(x);
  }

  /*
    Check involution: f(f(x)) = x.

    :arg x: Input value
    :arg f: Function to test
    :returns: true if f is an involution for x
  */
  proc isInvolution(x, f): bool {
    return f(f(x)) == x;
  }

  /*
    Check homomorphism: f(a opS b) = f(a) opT f(b).

    :arg a: First value
    :arg b: Second value
    :arg f: Function to test
    :arg opSource: Operation in source domain
    :arg opTarget: Operation in target domain
    :returns: true if f is a homomorphism
  */
  proc isHomomorphism(a, b, f, opSource, opTarget): bool {
    return f(opSource(a, b)) == opTarget(f(a), f(b));
  }

  /*
    Check monotonicity: a <= b implies f(a) <= f(b).

    :arg a: First value
    :arg b: Second value
    :arg f: Function to test
    :arg leq: Less-than-or-equal comparison
    :returns: true if f is monotonic for a, b
  */
  proc isMonotonic(a, b, f, leq): bool {
    if leq(a, b) then return leq(f(a), f(b));
    else return true;  // Vacuously true if condition not met
  }

  /*
    Round-Trip Property Predicates
    ------------------------------

    Test encode/decode, serialize/deserialize pairs.
  */

  /*
    Check round-trip: decode(encode(x)) = x.

    :arg x: Value to encode and decode
    :arg encode: Encoding function
    :arg decode: Decoding function
    :returns: true if round-trip preserves value
  */
  proc isRoundTrip(x, encode, decode): bool {
    try {
      return decode(encode(x)) == x;
    } catch {
      return false;
    }
  }

  /*
    Ordering Property Predicates
    ----------------------------

    Test properties of ordering relations.
  */

  /*
    Check reflexivity: a <= a.

    :arg a: Value to test
    :arg leq: Less-than-or-equal comparison
    :returns: true if leq is reflexive for a
  */
  proc isReflexive(a, leq): bool {
    return leq(a, a);
  }

  /*
    Check antisymmetry: a <= b and b <= a implies a = b.

    :arg a: First value
    :arg b: Second value
    :arg leq: Less-than-or-equal comparison
    :returns: true if leq is antisymmetric for a, b
  */
  proc isAntisymmetric(a, b, leq): bool {
    if leq(a, b) && leq(b, a) then return a == b;
    else return true;
  }

  /*
    Check transitivity: a <= b and b <= c implies a <= c.

    :arg a: First value
    :arg b: Second value
    :arg c: Third value
    :arg leq: Less-than-or-equal comparison
    :returns: true if leq is transitive for a, b, c
  */
  proc isTransitive(a, b, c, leq): bool {
    if leq(a, b) && leq(b, c) then return leq(a, c);
    else return true;
  }

  /*
    Check totality: a <= b or b <= a.

    :arg a: First value
    :arg b: Second value
    :arg leq: Less-than-or-equal comparison
    :returns: true if leq is total for a, b
  */
  proc isTotal(a, b, leq): bool {
    return leq(a, b) || leq(b, a);
  }

  /*
    Collection Property Predicates
    ------------------------------

    Test properties of collections and transformations.
  */

  /*
    Check length preservation: len(f(x)) = len(x).

    :arg x: Collection to transform
    :arg f: Transformation function
    :arg length: Length function
    :returns: true if f preserves length
  */
  proc preservesLength(x, f, length): bool {
    return length(f(x)) == length(x);
  }

  /*
    Equivalence Predicates
    ----------------------

    Test function equivalence.
  */

  /*
    Check equivalence: f(x) = g(x).

    :arg x: Input value
    :arg f: First function
    :arg g: Second function
    :returns: true if f and g produce same output for x
  */
  proc areEquivalent(x, f, g): bool {
    return f(x) == g(x);
  }

  /*
    Check approximate equivalence: |f(x) - g(x)| < epsilon.

    :arg x: Input value
    :arg f: First function
    :arg g: Second function
    :arg epsilon: Maximum allowed difference
    :returns: true if outputs differ by less than epsilon
  */
  proc areApproxEquivalent(x, f, g, epsilon: real): bool {
    return abs(f(x) - g(x)) < epsilon;
  }

  /*
    Implication Helper
    ------------------

    For conditional properties.
  */

  /*
    Logical implication: condition => conclusion.

    If condition is false, the implication is vacuously true.
    This is essential for testing conditional properties.

    :arg condition: Antecedent
    :arg conclusion: Consequent
    :returns: true if implication holds

    Example::

      // Test: if x > 0 then x * 2 > 0
      implies(x > 0, x * 2 > 0)
  */
  proc implies(condition: bool, conclusion: bool): bool {
    if !condition then return true;
    return conclusion;
  }

  /*
    Shorthand for implies.

    :arg condition: Antecedent
    :arg conclusion: Consequent
    :returns: true if implication holds
  */
  inline proc impl(condition: bool, conclusion: bool): bool {
    return implies(condition, conclusion);
  }

  /*
    Integer-Specific Predicates
    ---------------------------

    Ready-to-use predicates for common integer operations.
    These can be used directly without defining operations.
  */

  /*
    Integer addition commutes: a + b = b + a.

    :arg a: First integer
    :arg b: Second integer
    :returns: true (always, for integers)
  */
  proc intAddCommutative(a: int, b: int): bool {
    return a + b == b + a;
  }

  /*
    Integer addition associates: (a + b) + c = a + (b + c).

    :arg a: First integer
    :arg b: Second integer
    :arg c: Third integer
    :returns: true (always, for integers)
  */
  proc intAddAssociative(a: int, b: int, c: int): bool {
    return (a + b) + c == a + (b + c);
  }

  /*
    Zero is identity for addition: a + 0 = a.

    :arg a: Integer to test
    :returns: true (always)
  */
  proc intAddIdentity(a: int): bool {
    return a + 0 == a && 0 + a == a;
  }

  /*
    Integer multiplication commutes: a * b = b * a.

    :arg a: First integer
    :arg b: Second integer
    :returns: true (always, for integers)
  */
  proc intMulCommutative(a: int, b: int): bool {
    return a * b == b * a;
  }

  /*
    Integer multiplication associates: (a * b) * c = a * (b * c).

    :arg a: First integer
    :arg b: Second integer
    :arg c: Third integer
    :returns: true (always, for integers)
  */
  proc intMulAssociative(a: int, b: int, c: int): bool {
    return (a * b) * c == a * (b * c);
  }

  /*
    One is identity for multiplication: a * 1 = a.

    :arg a: Integer to test
    :returns: true (always)
  */
  proc intMulIdentity(a: int): bool {
    return a * 1 == a && 1 * a == a;
  }

  /*
    Multiplication distributes over addition: a * (b + c) = a * b + a * c.

    :arg a: First integer
    :arg b: Second integer
    :arg c: Third integer
    :returns: true (always, for integers)
  */
  proc intDistributive(a: int, b: int, c: int): bool {
    return a * (b + c) == a * b + a * c;
  }

  /*
    Max commutes: max(a, b) = max(b, a).

    :arg a: First integer
    :arg b: Second integer
    :returns: true (always)
  */
  proc maxCommutative(a: int, b: int): bool {
    return max(a, b) == max(b, a);
  }

  /*
    Max associates: max(max(a, b), c) = max(a, max(b, c)).

    :arg a: First integer
    :arg b: Second integer
    :arg c: Third integer
    :returns: true (always)
  */
  proc maxAssociative(a: int, b: int, c: int): bool {
    return max(max(a, b), c) == max(a, max(b, c));
  }

  /*
    Max is idempotent: max(a, a) = a.

    :arg a: Integer to test
    :returns: true (always)
  */
  proc maxIdempotent(a: int): bool {
    return max(a, a) == a;
  }

  /*
    Min commutes: min(a, b) = min(b, a).

    :arg a: First integer
    :arg b: Second integer
    :returns: true (always)
  */
  proc minCommutative(a: int, b: int): bool {
    return min(a, b) == min(b, a);
  }

  /*
    Min associates: min(min(a, b), c) = min(a, min(b, c)).

    :arg a: First integer
    :arg b: Second integer
    :arg c: Third integer
    :returns: true (always)
  */
  proc minAssociative(a: int, b: int, c: int): bool {
    return min(min(a, b), c) == min(a, min(b, c));
  }

  /*
    Min is idempotent: min(a, a) = a.

    :arg a: Integer to test
    :returns: true (always)
  */
  proc minIdempotent(a: int): bool {
    return min(a, a) == a;
  }
}
