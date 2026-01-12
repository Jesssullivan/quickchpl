// quickchpl: Property Patterns Library
// Provides reusable property pattern helpers for common testing scenarios
//
// Note: Due to Chapel's type system, these are helper predicates rather than
// full Property factories. Users compose them with property() themselves.

module Patterns {
  use List;

  //============================================================================
  // Algebraic Property Predicates
  //============================================================================

  // Check associativity: (a op b) op c = a op (b op c)
  // Usage: isAssociative(a, b, c, myOp)
  proc isAssociative(a, b, c, op): bool {
    const left = op(op(a, b), c);
    const right = op(a, op(b, c));
    return left == right;
  }

  // Check commutativity: a op b = b op a
  proc isCommutative(a, b, op): bool {
    return op(a, b) == op(b, a);
  }

  // Check identity: a op e = a and e op a = a
  proc hasIdentity(a, e, op): bool {
    return op(a, e) == a && op(e, a) == a;
  }

  // Check inverse: a op inv(a) = e and inv(a) op a = e
  proc hasInverse(a, inv, e, op): bool {
    const invA = inv(a);
    return op(a, invA) == e && op(invA, a) == e;
  }

  // Check distributivity: a * (b + c) = (a * b) + (a * c)
  proc isDistributive(a, b, c, mult, add): bool {
    const left = mult(a, add(b, c));
    const right = add(mult(a, b), mult(a, c));
    return left == right;
  }

  // Check absorption: a meet (a join b) = a
  proc isAbsorptive(a, b, meet, join): bool {
    return meet(a, join(a, b)) == a;
  }

  //============================================================================
  // Functional Property Predicates
  //============================================================================

  // Check idempotence: f(f(x)) = f(x)
  proc isIdempotent(x, f): bool {
    return f(f(x)) == f(x);
  }

  // Check involution: f(f(x)) = x
  proc isInvolution(x, f): bool {
    return f(f(x)) == x;
  }

  // Check homomorphism: f(a opS b) = f(a) opT f(b)
  proc isHomomorphism(a, b, f, opSource, opTarget): bool {
    return f(opSource(a, b)) == opTarget(f(a), f(b));
  }

  // Check monotonicity: a <= b implies f(a) <= f(b)
  proc isMonotonic(a, b, f, leq): bool {
    if leq(a, b) then return leq(f(a), f(b));
    else return true;  // Vacuously true if condition not met
  }

  //============================================================================
  // Round-Trip Property Predicates
  //============================================================================

  // Check round-trip: decode(encode(x)) = x
  proc isRoundTrip(x, encode, decode): bool {
    try {
      return decode(encode(x)) == x;
    } catch {
      return false;
    }
  }

  //============================================================================
  // Ordering Property Predicates
  //============================================================================

  // Check reflexivity: a <= a
  proc isReflexive(a, leq): bool {
    return leq(a, a);
  }

  // Check antisymmetry: a <= b and b <= a implies a = b
  proc isAntisymmetric(a, b, leq): bool {
    if leq(a, b) && leq(b, a) then return a == b;
    else return true;
  }

  // Check transitivity: a <= b and b <= c implies a <= c
  proc isTransitive(a, b, c, leq): bool {
    if leq(a, b) && leq(b, c) then return leq(a, c);
    else return true;
  }

  // Check totality: a <= b or b <= a
  proc isTotal(a, b, leq): bool {
    return leq(a, b) || leq(b, a);
  }

  //============================================================================
  // Collection Property Predicates
  //============================================================================

  // Check length preservation: len(f(x)) = len(x)
  proc preservesLength(x, f, length): bool {
    return length(f(x)) == length(x);
  }

  //============================================================================
  // Equivalence Predicates
  //============================================================================

  // Check equivalence: f(x) = g(x)
  proc areEquivalent(x, f, g): bool {
    return f(x) == g(x);
  }

  // Check approximate equivalence: |f(x) - g(x)| < epsilon
  proc areApproxEquivalent(x, f, g, epsilon: real): bool {
    return abs(f(x) - g(x)) < epsilon;
  }

  //============================================================================
  // Implication Helper (for conditional properties)
  //============================================================================

  // Logical implication: condition => conclusion
  // If condition is false, the implication is vacuously true
  proc implies(condition: bool, conclusion: bool): bool {
    if !condition then return true;
    return conclusion;
  }

  // Shorthand
  inline proc impl(condition: bool, conclusion: bool): bool {
    return implies(condition, conclusion);
  }

  //============================================================================
  // Integer-specific predicates for common operations
  //============================================================================

  // Integer addition predicates
  proc intAddCommutative(a: int, b: int): bool {
    return a + b == b + a;
  }

  proc intAddAssociative(a: int, b: int, c: int): bool {
    return (a + b) + c == a + (b + c);
  }

  proc intAddIdentity(a: int): bool {
    return a + 0 == a && 0 + a == a;
  }

  // Integer multiplication predicates
  proc intMulCommutative(a: int, b: int): bool {
    return a * b == b * a;
  }

  proc intMulAssociative(a: int, b: int, c: int): bool {
    return (a * b) * c == a * (b * c);
  }

  proc intMulIdentity(a: int): bool {
    return a * 1 == a && 1 * a == a;
  }

  proc intDistributive(a: int, b: int, c: int): bool {
    return a * (b + c) == a * b + a * c;
  }

  // Max/min predicates
  proc maxCommutative(a: int, b: int): bool {
    return max(a, b) == max(b, a);
  }

  proc maxAssociative(a: int, b: int, c: int): bool {
    return max(max(a, b), c) == max(a, max(b, c));
  }

  proc maxIdempotent(a: int): bool {
    return max(a, a) == a;
  }

  proc minCommutative(a: int, b: int): bool {
    return min(a, b) == min(b, a);
  }

  proc minAssociative(a: int, b: int, c: int): bool {
    return min(min(a, b), c) == min(a, min(b, c));
  }

  proc minIdempotent(a: int): bool {
    return min(a, a) == a;
  }
}
