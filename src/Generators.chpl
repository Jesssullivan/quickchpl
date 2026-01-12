// quickchpl: Generator Framework
// Provides type-safe, composable random value generators

module Generators {
  use Random;
  use List;
  use Math;

  // Configuration
  config const defaultMinInt = -1000000;
  config const defaultMaxInt = 1000000;
  config const defaultMinReal = -1000000.0;
  config const defaultMaxReal = 1000000.0;
  config const defaultMaxStringLen = 100;
  config const defaultMaxArrayLen = 100;

  // Default character set for string generation
  param DEFAULT_CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  // Statistical distributions for real number generation
  enum Distribution {
    Uniform,
    Normal,
    Exponential
  }

  //============================================================================
  // Base Generator Record (Generic)
  //============================================================================

  // Generator configuration
  record GenConfig {
    var size: int = 100;        // Controls size of generated values
    var maxRetries: int = 100;  // For filtered generators
  }

  //============================================================================
  // Integer Generator
  //============================================================================

  record IntGenerator {
    var min: int;
    var max: int;
    var rng: randomStream(int);

    proc init(min: int = defaultMinInt, max: int = defaultMaxInt, seed: int = -1) {
      this.min = min;
      this.max = max;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    proc ref next(): int {
      // Generate random int in range [min, max]
      if min == max then return min;
      const span = max - min + 1;
      const raw = abs(rng.next()) % span;
      return min + raw;
    }

    iter these(n: int = 100) ref : int {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for integer generator
  proc intGen(min: int = defaultMinInt, max: int = defaultMaxInt, seed: int = -1): IntGenerator {
    return new IntGenerator(min, max, seed);
  }

  // Natural numbers (non-negative integers)
  proc natGen(max: int = defaultMaxInt, seed: int = -1): IntGenerator {
    return new IntGenerator(0, max, seed);
  }

  // Positive integers (>= 1)
  proc positiveIntGen(max: int = defaultMaxInt, seed: int = -1): IntGenerator {
    return new IntGenerator(1, max, seed);
  }

  //============================================================================
  // Real Generator
  //============================================================================

  record RealGenerator {
    var minVal: real;
    var maxVal: real;
    var distribution: Distribution;
    var rng: randomStream(real);

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
          // Clamp to range
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

    iter these(n: int = 100) ref : real {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for real generator
  proc realGen(minVal: real = defaultMinReal, maxVal: real = defaultMaxReal,
               distribution: Distribution = Distribution.Uniform, seed: int = -1): RealGenerator {
    return new RealGenerator(minVal, maxVal, distribution, seed);
  }

  // Unit interval [0, 1)
  proc unitRealGen(seed: int = -1): RealGenerator {
    return new RealGenerator(0.0, 1.0, Distribution.Uniform, seed);
  }

  //============================================================================
  // Boolean Generator
  //============================================================================

  record BoolGenerator {
    var trueProb: real;  // Probability of generating true
    var rng: randomStream(real);

    proc init(trueProb: real = 0.5, seed: int = -1) {
      this.trueProb = trueProb;
      if seed >= 0 {
        this.rng = new randomStream(real, seed);
      } else {
        this.rng = new randomStream(real);
      }
    }

    proc ref next(): bool {
      return rng.next() < trueProb;
    }

    iter these(n: int = 100) ref : bool {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for boolean generator
  proc boolGen(trueProb: real = 0.5, seed: int = -1): BoolGenerator {
    return new BoolGenerator(trueProb, seed);
  }

  //============================================================================
  // String Generator
  //============================================================================

  record StringGenerator {
    var minLen: int;
    var maxLen: int;
    var charset: string;
    var rng: randomStream(int);

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

    proc ref next(): string {
      // Random length
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

    iter these(n: int = 100) ref : string {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for string generator
  proc stringGen(minLen: int = 0, maxLen: int = defaultMaxStringLen,
                 charset: string = DEFAULT_CHARSET, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, charset, seed);
  }

  // Alphabetic strings only
  proc alphaGen(minLen: int = 0, maxLen: int = defaultMaxStringLen, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", seed);
  }

  // Alphanumeric strings
  proc alphaNumGen(minLen: int = 0, maxLen: int = defaultMaxStringLen, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, DEFAULT_CHARSET, seed);
  }

  // Numeric strings (digits only)
  proc numericStringGen(minLen: int = 0, maxLen: int = defaultMaxStringLen, seed: int = -1): StringGenerator {
    return new StringGenerator(minLen, maxLen, "0123456789", seed);
  }

  //============================================================================
  // Tuple Generators (2-tuple and 3-tuple)
  //============================================================================

  record Tuple2Generator {
    type T1;
    type T2;
    var gen1: T1;
    var gen2: T2;

    proc ref next() {
      return (gen1.next(), gen2.next());
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  record Tuple3Generator {
    type T1;
    type T2;
    type T3;
    var gen1: T1;
    var gen2: T2;
    var gen3: T3;

    proc ref next() {
      return (gen1.next(), gen2.next(), gen3.next());
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory functions for tuple generators
  proc tupleGen(gen1, gen2) {
    return new Tuple2Generator(gen1.type, gen2.type, gen1, gen2);
  }

  proc tupleGen(gen1, gen2, gen3) {
    return new Tuple3Generator(gen1.type, gen2.type, gen3.type, gen1, gen2, gen3);
  }

  //============================================================================
  // List Generator
  //============================================================================

  record ListGenerator {
    type ElemGenType;
    var elemGen: ElemGenType;
    var minSize: int;
    var maxSize: int;
    var rng: randomStream(int);

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

    proc ref next() {
      const size = if minSize == maxSize then minSize
                   else minSize + abs(rng.next()) % (maxSize - minSize + 1);

      var result: list(elemGen.next().type);
      for i in 1..size {
        result.pushBack(elemGen.next());
      }
      return result;
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for list generator
  proc listGen(elemGen, minSize: int = 0, maxSize: int = defaultMaxArrayLen, seed: int = -1) {
    return new ListGenerator(elemGen.type, elemGen, minSize, maxSize, seed);
  }

  //============================================================================
  // Constant Generator (always returns same value)
  //============================================================================

  record ConstantGenerator {
    type T;
    var value: T;

    proc init(value) {
      this.T = value.type;
      this.value = value;
    }

    proc next(): T {
      return value;
    }

    iter these(n: int = 100): T {
      for i in 1..n {
        yield value;
      }
    }
  }

  // Factory function for constant generator
  proc constantGen(value) {
    return new ConstantGenerator(value);
  }

  //============================================================================
  // Elements Generator (chooses from fixed list)
  //============================================================================

  record ElementsGenerator {
    type T;
    var elements: list(T);
    var rng: randomStream(int);

    proc init(type T, elements: list(T), seed: int = -1) {
      this.T = T;
      this.elements = elements;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    proc ref next(): T {
      if elements.size == 0 then halt("ElementsGenerator: empty elements list");
      const idx = abs(rng.next()) % elements.size;
      return elements[idx];
    }

    iter these(n: int = 100) ref : T {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for elements generator
  proc elementsGen(elements: list(?T), seed: int = -1) {
    return new ElementsGenerator(T, elements, seed);
  }
}
