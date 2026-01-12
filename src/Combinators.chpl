// quickchpl: Generator Combinators
// Provides composition operators for building complex generators from simple ones

module Combinators {
  use Random;
  use List;

  //============================================================================
  // Mapped Generator - transforms output of base generator
  //============================================================================

  record MappedGenerator {
    type BaseGenType;
    type OutputType;
    var baseGen: BaseGenType;
    var mapperFn;

    proc init(baseGen, mapperFn) {
      this.BaseGenType = baseGen.type;
      this.OutputType = mapperFn(baseGen.next()).type;
      this.baseGen = baseGen;
      this.mapperFn = mapperFn;
    }

    proc ref next(): OutputType {
      return mapperFn(baseGen.next());
    }

    iter these(n: int = 100) ref : OutputType {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Create a mapped generator
  proc map(gen, fn) {
    return new MappedGenerator(gen, fn);
  }

  //============================================================================
  // Filtered Generator - only produces values matching predicate
  //============================================================================

  record FilteredGenerator {
    type BaseGenType;
    type OutputType;
    var baseGen: BaseGenType;
    var predicateFn;
    var maxRetries: int;

    proc init(baseGen, predicateFn, maxRetries: int = 100) {
      this.BaseGenType = baseGen.type;
      this.OutputType = baseGen.next().type;
      this.baseGen = baseGen;
      this.predicateFn = predicateFn;
      this.maxRetries = maxRetries;
    }

    proc ref next(): OutputType {
      var retries = 0;
      while retries < maxRetries {
        const value = baseGen.next();
        if predicateFn(value) then return value;
        retries += 1;
      }
      halt("FilteredGenerator: exceeded ", maxRetries, " retries - predicate too restrictive");
    }

    iter these(n: int = 100) ref : OutputType {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Create a filtered generator
  proc filter(gen, pred, maxRetries: int = 100) {
    return new FilteredGenerator(gen, pred, maxRetries);
  }

  //============================================================================
  // Zip Generator - combines two generators into tuple generator
  //============================================================================

  record ZipGenerator {
    type Gen1Type;
    type Gen2Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;

    proc init(gen1, gen2) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.gen1 = gen1;
      this.gen2 = gen2;
    }

    proc ref next() {
      return (gen1.next(), gen2.next());
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Combine two generators into a tuple generator
  proc zipGen(gen1, gen2) {
    return new ZipGenerator(gen1, gen2);
  }

  //============================================================================
  // Zip3 Generator - combines three generators
  //============================================================================

  record Zip3Generator {
    type Gen1Type;
    type Gen2Type;
    type Gen3Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var gen3: Gen3Type;

    proc init(gen1, gen2, gen3) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.Gen3Type = gen3.type;
      this.gen1 = gen1;
      this.gen2 = gen2;
      this.gen3 = gen3;
    }

    proc ref next() {
      return (gen1.next(), gen2.next(), gen3.next());
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Combine three generators into a tuple generator
  proc zipGen3(gen1, gen2, gen3) {
    return new Zip3Generator(gen1, gen2, gen3);
  }

  //============================================================================
  // OneOf Generator - randomly chooses between generators
  //============================================================================

  // For simplicity, we provide specific arity versions
  record OneOf2Generator {
    type Gen1Type;
    type Gen2Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var rng: randomStream(int);

    proc init(gen1, gen2, seed: int = -1) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.gen1 = gen1;
      this.gen2 = gen2;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    proc ref next() {
      const choice = abs(rng.next()) % 2;
      if choice == 0 then return gen1.next();
      else return gen2.next();
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  record OneOf3Generator {
    type Gen1Type;
    type Gen2Type;
    type Gen3Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var gen3: Gen3Type;
    var rng: randomStream(int);

    proc init(gen1, gen2, gen3, seed: int = -1) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.Gen3Type = gen3.type;
      this.gen1 = gen1;
      this.gen2 = gen2;
      this.gen3 = gen3;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    proc ref next() {
      const choice = abs(rng.next()) % 3;
      if choice == 0 then return gen1.next();
      else if choice == 1 then return gen2.next();
      else return gen3.next();
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory functions for oneOf
  proc oneOf(gen1, gen2, seed: int = -1) {
    return new OneOf2Generator(gen1, gen2, seed);
  }

  proc oneOf(gen1, gen2, gen3, seed: int = -1) {
    return new OneOf3Generator(gen1, gen2, gen3, seed);
  }

  //============================================================================
  // Frequency Generator - weighted random choice between generators
  //============================================================================

  // 2-choice frequency generator
  record Frequency2Generator {
    type Gen1Type;
    type Gen2Type;
    var weight1: int;
    var weight2: int;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var rng: randomStream(int);

    proc init(weight1: int, gen1, weight2: int, gen2, seed: int = -1) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.weight1 = weight1;
      this.weight2 = weight2;
      this.gen1 = gen1;
      this.gen2 = gen2;
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    proc ref next() {
      const totalWeight = weight1 + weight2;
      const choice = abs(rng.next()) % totalWeight;
      if choice < weight1 then return gen1.next();
      else return gen2.next();
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Factory function for frequency
  proc frequency(weight1: int, gen1, weight2: int, gen2, seed: int = -1) {
    return new Frequency2Generator(weight1, gen1, weight2, gen2, seed);
  }

  //============================================================================
  // SuchThat Generator - alias for filter with better name
  //============================================================================

  proc suchThat(gen, pred, maxRetries: int = 100) {
    return filter(gen, pred, maxRetries);
  }

  //============================================================================
  // Resize Generator - scales the "size" parameter for sized generators
  //============================================================================

  record ResizedGenerator {
    type BaseGenType;
    var baseGen: BaseGenType;
    var scaleFactor: real;

    proc init(baseGen, scaleFactor: real) {
      this.BaseGenType = baseGen.type;
      this.baseGen = baseGen;
      this.scaleFactor = scaleFactor;
    }

    proc ref next() {
      // For generators that respect size, this would scale
      // For now, just pass through
      return baseGen.next();
    }

    iter these(n: int = 100) ref {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  // Create a resized generator
  proc resize(gen, scaleFactor: real) {
    return new ResizedGenerator(gen, scaleFactor);
  }

  //============================================================================
  // NonEmpty Generator - ensures collections have at least one element
  //============================================================================

  // Helper that adjusts list generator to have minSize >= 1
  proc nonEmpty(gen) {
    // For list generators, we can use filter to ensure non-empty
    return filter(gen, proc(lst) { return lst.size > 0; });
  }
}
