/*
  Generators Module
  =================

  Type-safe, composable random value generators for property-based testing.

  This module provides generators for primitive types (int, real, bool, string)
  and composite types (tuples, lists). All generators follow a common interface
  with ``next()`` method and iterator support.

  **Basic Generators:**

  - :proc:`intGen` - Integer generator with configurable range
  - :proc:`realGen` - Real number generator with distribution options
  - :proc:`boolGen` - Boolean generator with probability control
  - :proc:`stringGen` - String generator with charset control

  **Composite Generators:**

  - :proc:`tupleGen` - Combine generators into tuple generator
  - :proc:`listGen` - Generate lists of values
  - :proc:`constantGen` - Always returns the same value
  - :proc:`elementsGen` - Choose from a fixed set of values

  **Convenience Generators:**

  - :proc:`natGen` - Natural numbers (>= 0)
  - :proc:`positiveIntGen` - Positive integers (>= 1)
  - :proc:`unitRealGen` - Real numbers in [0, 1)
  - :proc:`alphaGen` - Alphabetic strings only
  - :proc:`alphaNumGen` - Alphanumeric strings
  - :proc:`numericStringGen` - Digit strings only

  Example::

    use Generators;

    var gen = intGen(-100, 100);
    for value in gen.these(10) {
      writeln(value);
    }
*/
module Generators {
  use Random;
  use List;
  use Math;

  /*
    Configuration Constants
    -----------------------

    Default bounds for generators. Override via command line.
  */

  /* Default minimum value for integer generators. */
  config const defaultMinInt = -1000000;

  /* Default maximum value for integer generators. */
  config const defaultMaxInt = 1000000;

  /* Default minimum value for real generators. */
  config const defaultMinReal = -1000000.0;

  /* Default maximum value for real generators. */
  config const defaultMaxReal = 1000000.0;

  /* Default maximum length for string generators. */
  config const defaultMaxStringLen = 100;

  /* Default maximum length for array/list generators. */
  config const defaultMaxArrayLen = 100;

  /* Default character set for string generation. */
  param DEFAULT_CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  /*
    Statistical distributions for real number generation.

    - ``Uniform`` - Equal probability across range
    - ``Normal`` - Gaussian distribution centered in range
    - ``Exponential`` - Exponential decay from minimum
  */
  enum Distribution {
    Uniform,
    Normal,
    Exponential
  }

  /*
    Generator Configuration
    -----------------------

    Common configuration for generators.
  */

  /*
    Configuration record for sized generators.

    :var size: Controls the size of generated values (e.g., list length)
    :var maxRetries: Maximum retries for filtered generators
  */
  record GenConfig {
    var size: int = 100;
    var maxRetries: int = 100;
  }

  /*
    Integer Generator
    -----------------

    Generates random integers within a specified range.
  */

  /*
    Random integer generator.

    Produces uniformly distributed integers in the range [min, max].
    Supports iteration via ``these()`` and single value via ``next()``.

    :var min: Minimum value (inclusive)
    :var max: Maximum value (inclusive)
    :var rng: Internal random stream
  */
  record IntGenerator {
    var min: int;
    var max: int;
    var rng: randomStream(int);

    /*
      Initialize an integer generator.

      :arg min: Minimum value (inclusive)
      :arg max: Maximum value (inclusive)
      :arg seed: Random seed (-1 for random)
    */
    proc init(min: int = defaultMinInt, max: int = defaultMaxInt, seed: int = -1) {
      this.min = min;
      this.max = max;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    /*
      Generate the next random integer.

      :returns: Random integer in [min, max]
    */
    proc ref next(): int {
      if min == max then return min;
      const span = max - min + 1;
      const raw = abs(rng.next()) % span;
      return min + raw;
    }

    /*
      Iterate over n random integers.

      :arg n: Number of values to generate
      :yields: Random integers in [min, max]
    */
    iter these(n: int = 100) ref : int {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create an integer generator.

    :arg min: Minimum value (inclusive), default -1000000
    :arg max: Maximum value (inclusive), default 1000000
    :arg seed: Random seed (-1 for random)
    :returns: New IntGenerator

    Example::

      var gen = intGen(-10, 10);
      var value = gen.next();  // Random int in [-10, 10]
  */
  proc intGen(min: int = defaultMinInt, max: int = defaultMaxInt, seed: int = -1): IntGenerator {
    return new IntGenerator(min, max, seed);
  }

  /*
    Create a natural number generator (non-negative integers).

    :arg max: Maximum value (inclusive)
    :arg seed: Random seed (-1 for random)
    :returns: IntGenerator with min=0

    Example::

      var gen = natGen(100);  // Generates 0..100
  */
  proc natGen(max: int = defaultMaxInt, seed: int = -1): IntGenerator {
    return new IntGenerator(0, max, seed);
  }

  /*
    Create a positive integer generator (>= 1).

    :arg max: Maximum value (inclusive)
    :arg seed: Random seed (-1 for random)
    :returns: IntGenerator with min=1

    Example::

      var gen = positiveIntGen(100);  // Generates 1..100
  */
  proc positiveIntGen(max: int = defaultMaxInt, seed: int = -1): IntGenerator {
    return new IntGenerator(1, max, seed);
  }

  /*
    Real Number Generator
    ---------------------

    Generates random real numbers with configurable distribution.
  */

  /*
    Random real number generator.

    Produces real numbers in the range [minVal, maxVal] with
    configurable distribution (Uniform, Normal, or Exponential).

    :var minVal: Minimum value (inclusive)
    :var maxVal: Maximum value (inclusive)
    :var distribution: Statistical distribution to use
    :var rng: Internal random stream
  */
  record RealGenerator {
    var minVal: real;
    var maxVal: real;
    var distribution: Distribution;
    var rng: randomStream(real);

    /*
      Initialize a real number generator.

      :arg minVal: Minimum value (inclusive)
      :arg maxVal: Maximum value (inclusive)
      :arg distribution: Distribution type (Uniform, Normal, Exponential)
      :arg seed: Random seed (-1 for random)
    */
    proc init(minVal: real = defaultMinReal, maxVal: real = defaultMaxReal,
              distribution: Distribution = Distribution.Uniform, seed: int = -1) {
      this.minVal = minVal;
      this.maxVal = maxVal;
      this.distribution = distribution;
      if seed >= 0 {
        this.rng = new randomStream(real, seed);
      } else {
        this.rng = new randomStream(real);
      }
    }

    /*
      Generate the next random real number.

      Uses Box-Muller transform for Normal distribution,
      inverse transform for Exponential.

      :returns: Random real in [minVal, maxVal]
    */
    proc ref next(): real {
      select distribution {
        when Distribution.Uniform {
          const raw = rng.next();  // [0, 1)
          return minVal + raw * (maxVal - minVal);
        }
        when Distribution.Normal {
          // Box-Muller transform for normal distribution
          const mean = (minVal + maxVal) / 2.0;
          const stddev = (maxVal - minVal) / 6.0;  // ~99.7% within range
          var u1 = rng.next();
          if u1 < 1e-10 then u1 = 1e-10;  // Avoid log(0)
          const u2 = rng.next();
          const z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * 3.14159265358979 * u2);
          var result = mean + stddev * z0;
          if result < minVal then result = minVal;
          if result > maxVal then result = maxVal;
          return result;
        }
        when Distribution.Exponential {
          const lambdaVal = 1.0 / ((maxVal - minVal) / 2.0);
          var u = rng.next();
          if u < 1e-10 then u = 1e-10;
          var result = minVal + (-log(u) / lambdaVal);
          if result > maxVal then result = maxVal;
          return result;
        }
        otherwise {
          return minVal + rng.next() * (maxVal - minVal);
        }
      }
    }

    /*
      Iterate over n random real numbers.

      :arg n: Number of values to generate
      :yields: Random reals in [minVal, maxVal]
    */
    iter these(n: int = 100) ref : real {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a real number generator.

    :arg minVal: Minimum value (inclusive)
    :arg maxVal: Maximum value (inclusive)
    :arg distribution: Distribution type (default: Uniform)
    :arg seed: Random seed (-1 for random)
    :returns: New RealGenerator

    Example::

      // Uniform distribution
      var uniform = realGen(0.0, 1.0);

      // Normal distribution (Gaussian)
      var normal = realGen(-1.0, 1.0, Distribution.Normal);
  */
  proc realGen(minVal: real = defaultMinReal, maxVal: real = defaultMaxReal,
               distribution: Distribution = Distribution.Uniform, seed: int = -1): RealGenerator {
    return new RealGenerator(minVal, maxVal, distribution, seed);
  }

  /*
    Create a unit interval generator [0, 1).

    :arg seed: Random seed (-1 for random)
    :returns: RealGenerator for [0.0, 1.0)

    Example::

      var gen = unitRealGen();
      var prob = gen.next();  // Random probability
  */
  proc unitRealGen(seed: int = -1): RealGenerator {
    return new RealGenerator(0.0, 1.0, Distribution.Uniform, seed);
  }

  /*
    Boolean Generator
    -----------------

    Generates random boolean values with configurable probability.
  */

  /*
    Random boolean generator.

    Produces boolean values with configurable true probability.

    :var trueProb: Probability of generating true (0.0 to 1.0)
    :var rng: Internal random stream
  */
  record BoolGenerator {
    var trueProb: real;
    var rng: randomStream(real);

    /*
      Initialize a boolean generator.

      :arg trueProb: Probability of generating true (default: 0.5)
      :arg seed: Random seed (-1 for random)
    */
    proc init(trueProb: real = 0.5, seed: int = -1) {
      this.trueProb = trueProb;
      if seed >= 0 {
        this.rng = new randomStream(real, seed);
      } else {
        this.rng = new randomStream(real);
      }
    }

    /*
      Generate the next random boolean.

      :returns: true with probability trueProb, false otherwise
    */
    proc ref next(): bool {
      return rng.next() < trueProb;
    }

    /*
      Iterate over n random booleans.

      :arg n: Number of values to generate
      :yields: Random boolean values
    */
    iter these(n: int = 100) ref : bool {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a boolean generator.

    :arg trueProb: Probability of generating true (default: 0.5)
    :arg seed: Random seed (-1 for random)
    :returns: New BoolGenerator

    Example::

      // Fair coin flip
      var fair = boolGen();

      // Biased: 80% true
      var biased = boolGen(0.8);
  */
  proc boolGen(trueProb: real = 0.5, seed: int = -1): BoolGenerator {
    return new BoolGenerator(trueProb, seed);
  }

  /*
    String Generator
    ----------------

    Generates random strings with configurable length and character set.
  */

  /*
    Random string generator.

    Produces strings with random length in [minLen, maxLen]
    using characters from the specified charset.

    :var minLen: Minimum string length
    :var maxLen: Maximum string length
    :var charset: Characters to choose from
    :var rng: Internal random stream
  */
  record StringGenerator {
    var minLen: int;
    var maxLen: int;
    var charset: string;
    var rng: randomStream(int);

    /*
      Initialize a string generator.

      :arg minLen: Minimum length (default: 0)
      :arg maxLen: Maximum length (default: 100)
      :arg charset: Characters to use (default: alphanumeric)
      :arg seed: Random seed (-1 for random)
    */
    proc init(minLen: int = 0, maxLen: int = defaultMaxStringLen,
              charset: string = DEFAULT_CHARSET, seed: int = -1) {
      this.minLen = minLen;
      this.maxLen = maxLen;
      this.charset = charset;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    /*
      Generate the next random string.

      :returns: Random string with length in [minLen, maxLen]
    */
    proc ref next(): string {
      const len = if minLen == maxLen then minLen
                  else minLen + abs(rng.next()) % (maxLen - minLen + 1);

      if len == 0 then return "";

      var result: string;
      const charsetLen = charset.size;

      for i in 1..len {
        const idx = abs(rng.next()) % charsetLen;
        result += charset[idx];
      }

      return result;
    }

    /*
      Iterate over n random strings.

      :arg n: Number of strings to generate
      :yields: Random strings
    */
    iter these(n: int = 100) ref : string {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a string generator.

    :arg minLen: Minimum length (default: 0)
    :arg maxLen: Maximum length (default: 100)
    :arg charset: Characters to use (default: alphanumeric)
    :arg seed: Random seed (-1 for random)
    :returns: New StringGenerator

    Example::

      // Random alphanumeric strings of length 5-10
      var gen = stringGen(5, 10);

      // Custom charset
      var hexGen = stringGen(8, 8, "0123456789abcdef");
  */
  proc stringGen(minLen: int = 0, maxLen: int = defaultMaxStringLen,
                 charset: string = DEFAULT_CHARSET, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, charset, seed);
  }

  /*
    Create an alphabetic-only string generator.

    :arg minLen: Minimum length
    :arg maxLen: Maximum length
    :arg seed: Random seed (-1 for random)
    :returns: StringGenerator with letters only (a-z, A-Z)
  */
  proc alphaGen(minLen: int = 0, maxLen: int = defaultMaxStringLen, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", seed);
  }

  /*
    Create an alphanumeric string generator.

    :arg minLen: Minimum length
    :arg maxLen: Maximum length
    :arg seed: Random seed (-1 for random)
    :returns: StringGenerator with letters and digits
  */
  proc alphaNumGen(minLen: int = 0, maxLen: int = defaultMaxStringLen, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, DEFAULT_CHARSET, seed);
  }

  /*
    Create a numeric string generator (digits only).

    :arg minLen: Minimum length
    :arg maxLen: Maximum length
    :arg seed: Random seed (-1 for random)
    :returns: StringGenerator with digits only (0-9)

    Example::

      var gen = numericStringGen(10, 10);  // 10-digit numbers
  */
  proc numericStringGen(minLen: int = 0, maxLen: int = defaultMaxStringLen, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, "0123456789", seed);
  }

  /*
    Tuple Generators
    ----------------

    Combine multiple generators into tuple generators.
  */

  /*
    2-tuple generator.

    Combines two generators into a generator of 2-tuples.

    :type T1: Type of first generator
    :type T2: Type of second generator
    :var gen1: First generator
    :var gen2: Second generator
  */
  record Tuple2Generator {
    type T1;
    type T2;
    var gen1: T1;
    var gen2: T2;

    /*
      Generate the next 2-tuple.

      :returns: Tuple of (gen1.next(), gen2.next())
    */
    proc ref next() {
      return (gen1.next(), gen2.next());
    }

    /*
      Iterate over n 2-tuples.

      :arg n: Number of tuples to generate
      :yields: 2-tuples of generated values
    */
    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    3-tuple generator.

    Combines three generators into a generator of 3-tuples.

    :type T1: Type of first generator
    :type T2: Type of second generator
    :type T3: Type of third generator
    :var gen1: First generator
    :var gen2: Second generator
    :var gen3: Third generator
  */
  record Tuple3Generator {
    type T1;
    type T2;
    type T3;
    var gen1: T1;
    var gen2: T2;
    var gen3: T3;

    /*
      Generate the next 3-tuple.

      :returns: Tuple of (gen1.next(), gen2.next(), gen3.next())
    */
    proc ref next() {
      return (gen1.next(), gen2.next(), gen3.next());
    }

    /*
      Iterate over n 3-tuples.

      :arg n: Number of tuples to generate
      :yields: 3-tuples of generated values
    */
    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a 2-tuple generator.

    :arg gen1: First generator
    :arg gen2: Second generator
    :returns: Generator producing (T1, T2) tuples

    Example::

      // Generate (int, bool) pairs
      var gen = tupleGen(intGen(-10, 10), boolGen());
      var (x, flag) = gen.next();
  */
  proc tupleGen(gen1, gen2) {
    return new Tuple2Generator(gen1.type, gen2.type, gen1, gen2);
  }

  /*
    Create a 3-tuple generator.

    :arg gen1: First generator
    :arg gen2: Second generator
    :arg gen3: Third generator
    :returns: Generator producing (T1, T2, T3) tuples

    Example::

      // Generate (int, int, int) triples for testing associativity
      var gen = tupleGen(intGen(), intGen(), intGen());
  */
  proc tupleGen(gen1, gen2, gen3) {
    return new Tuple3Generator(gen1.type, gen2.type, gen3.type, gen1, gen2, gen3);
  }

  /*
    List Generator
    --------------

    Generates lists of values using an element generator.
  */

  /*
    Random list generator.

    Produces lists of values with random length in [minSize, maxSize].
    Elements are generated using the provided element generator.

    :type ElemGenType: Type of element generator
    :var elemGen: Generator for list elements
    :var minSize: Minimum list length
    :var maxSize: Maximum list length
    :var rng: Internal random stream for size selection
  */
  record ListGenerator {
    type ElemGenType;
    var elemGen: ElemGenType;
    var minSize: int;
    var maxSize: int;
    var rng: randomStream(int);

    /*
      Initialize a list generator.

      :arg ElemGenType: Type of element generator
      :arg elemGen: Generator for list elements
      :arg minSize: Minimum list length (default: 0)
      :arg maxSize: Maximum list length (default: 100)
      :arg seed: Random seed (-1 for random)
    */
    proc init(type ElemGenType, elemGen: ElemGenType,
              minSize: int = 0, maxSize: int = defaultMaxArrayLen, seed: int = -1) {
      this.ElemGenType = ElemGenType;
      this.elemGen = elemGen;
      this.minSize = minSize;
      this.maxSize = maxSize;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    /*
      Generate the next random list.

      :returns: List with length in [minSize, maxSize]
    */
    proc ref next() {
      const size = if minSize == maxSize then minSize
                   else minSize + abs(rng.next()) % (maxSize - minSize + 1);

      var result: list(elemGen.next().type);
      for i in 1..size {
        result.pushBack(elemGen.next());
      }
      return result;
    }

    /*
      Iterate over n random lists.

      :arg n: Number of lists to generate
      :yields: Random lists
    */
    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a list generator.

    :arg elemGen: Generator for list elements
    :arg minSize: Minimum list length (default: 0)
    :arg maxSize: Maximum list length (default: 100)
    :arg seed: Random seed (-1 for random)
    :returns: Generator producing lists of elements

    Example::

      // Generate lists of 1-10 integers
      var gen = listGen(intGen(-100, 100), 1, 10);
      var numbers = gen.next();  // list(int) with 1-10 elements
  */
  proc listGen(elemGen, minSize: int = 0, maxSize: int = defaultMaxArrayLen, seed: int = -1) {
    return new ListGenerator(elemGen.type, elemGen, minSize, maxSize, seed);
  }

  /*
    Constant Generator
    ------------------

    Always returns the same value (useful for testing edge cases).
  */

  /*
    Constant value generator.

    Always produces the same value. Useful for testing specific
    edge cases or combining with other generators.

    :type T: Type of the constant value
    :var value: The constant value to return
  */
  record ConstantGenerator {
    type T;
    var value: T;

    /*
      Initialize a constant generator.

      :arg value: The value to always return
    */
    proc init(value) {
      this.T = value.type;
      this.value = value;
    }

    /*
      Return the constant value.

      :returns: The stored constant value
    */
    proc next(): T {
      return value;
    }

    /*
      Iterate, yielding the constant value n times.

      :arg n: Number of times to yield
      :yields: The constant value
    */
    iter these(n: int = 100): T {
      for i in 1..n {
        yield value;
      }
    }
  }

  /*
    Create a constant generator.

    :arg value: The value to always return
    :returns: Generator that always produces value

    Example::

      // Test with edge case value 0
      var zeroGen = constantGen(0);

      // Combine with other generators
      var gen = oneOf(intGen(), constantGen(0));  // Include 0 as edge case
  */
  proc constantGen(value) {
    return new ConstantGenerator(value);
  }

  /*
    Elements Generator
    ------------------

    Randomly chooses from a fixed set of values.
  */

  /*
    Random element selection generator.

    Randomly selects from a predefined list of values.
    Useful for enumeration-like testing.

    :type T: Type of elements
    :var elements: List of values to choose from
    :var rng: Internal random stream
  */
  record ElementsGenerator {
    type T;
    var elements: list(T);
    var rng: randomStream(int);

    /*
      Initialize an elements generator.

      :arg T: Type of elements
      :arg elements: List of values to choose from
      :arg seed: Random seed (-1 for random)
    */
    proc init(type T, elements: list(T), seed: int = -1) {
      this.T = T;
      this.elements = elements;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    /*
      Select a random element.

      :returns: Randomly selected element from the list
      :throws: Halts if elements list is empty
    */
    proc ref next(): T {
      if elements.size == 0 then halt("ElementsGenerator: empty elements list");
      const idx = abs(rng.next()) % elements.size;
      return elements[idx];
    }

    /*
      Iterate over n random selections.

      :arg n: Number of selections to make
      :yields: Randomly selected elements
    */
    iter these(n: int = 100) ref : T {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create an elements generator.

    :arg elements: List of values to choose from
    :arg seed: Random seed (-1 for random)
    :returns: Generator that randomly selects from elements

    Example::

      var colors: list(string);
      colors.pushBack("red");
      colors.pushBack("green");
      colors.pushBack("blue");

      var gen = elementsGen(colors);
      var color = gen.next();  // "red", "green", or "blue"
  */
  proc elementsGen(elements: list(?T), seed: int = -1) {
    return new ElementsGenerator(T, elements, seed);
  }
}
