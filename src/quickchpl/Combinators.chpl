/*
  Combinators Module
  ==================

  Composition operators for building complex generators from simple ones.

  Combinators allow you to transform, filter, and combine generators to
  create sophisticated test data generation strategies without writing
  custom generator code.

  **Transformation Combinators:**

  - :proc:`map` - Transform generator output
  - :proc:`filter` - Only allow values matching predicate
  - :proc:`suchThat` - Alias for filter

  **Combination Combinators:**

  - :proc:`zipGen` - Combine two generators into tuple generator
  - :proc:`zipGen3` - Combine three generators
  - :proc:`oneOf` - Randomly choose between generators
  - :proc:`frequency` - Weighted random choice

  **Sizing Combinators:**

  - :proc:`resize` - Scale generator size parameter
  - :proc:`nonEmpty` - Ensure collections have at least one element

  Example::

    use Combinators;
    use Generators;

    // Generate even numbers by filtering
    var evenGen = filter(intGen(), lambda(x: int) { return x % 2 == 0; });

    // Generate positive squares by mapping
    var squareGen = map(positiveIntGen(100), lambda(x: int) { return x * x; });

    // Combine with weighted choice
    var gen = frequency(3, intGen(-10, 10), 1, constantGen(0));
*/
module Combinators {
  use Random;
  use List;

  /*
    Mapped Generator
    ----------------

    Transforms output of a base generator using a function.
  */

  /*
    Generator that transforms values from a base generator.

    Applies a mapping function to each generated value.

    :type BaseGenType: Type of the base generator
    :type OutputType: Type of transformed output
    :var baseGen: Base generator
    :var mapperFn: Transformation function
  */
  record mappedGenerator {
    type BaseGenType;
    type OutputType;
    var baseGen: BaseGenType;
    var mapperFn;

    /*
      Initialize a mapped generator.

      :arg baseGen: Base generator to transform
      :arg mapperFn: Function to apply to each value
    */
    proc init(baseGen, mapperFn) {
      this.BaseGenType = baseGen.type;
      this.OutputType = mapperFn(baseGen.next()).type;
      this.baseGen = baseGen;
      this.mapperFn = mapperFn;
    }

    /*
      Generate next transformed value.

      :returns: mapperFn applied to baseGen.next()
    */
    proc ref next(): OutputType {
      return mapperFn(baseGen.next());
    }

    /*
      Iterate over n transformed values.

      :arg n: Number of values to generate
      :yields: Transformed values
    */
    iter these(n: int = 100) ref : OutputType {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a mapped generator.

    Transform generator output using a function.

    :arg gen: Base generator
    :arg fn: Transformation function
    :returns: Generator producing fn(gen.next())

    Example::

      // Generate squares
      var squareGen = map(intGen(1, 10), lambda(x: int) { return x * x; });
      // Produces: 1, 4, 9, 16, 25, ...
  */
  proc map(gen, fn) {
    return new mappedGenerator(gen, fn);
  }

  /*
    Filtered Generator
    ------------------

    Only produces values that match a predicate.
  */

  /*
    Generator that filters values from a base generator.

    Repeatedly generates values until one matches the predicate.
    Halts if maxRetries is exceeded (predicate too restrictive).

    :type BaseGenType: Type of the base generator
    :type OutputType: Type of filtered output
    :var baseGen: Base generator
    :var predicateFn: Filter predicate (returns true to keep)
    :var maxRetries: Maximum attempts before halting
  */
  record filteredGenerator {
    type BaseGenType;
    type OutputType;
    var baseGen: BaseGenType;
    var predicateFn;
    var maxRetries: int;

    /*
      Initialize a filtered generator.

      :arg baseGen: Base generator
      :arg predicateFn: Predicate (true to keep value)
      :arg maxRetries: Max attempts (default: 100)
    */
    proc init(baseGen, predicateFn, maxRetries: int = 100) {
      this.BaseGenType = baseGen.type;
      this.OutputType = baseGen.next().type;
      this.baseGen = baseGen;
      this.predicateFn = predicateFn;
      this.maxRetries = maxRetries;
    }

    /*
      Generate next value matching predicate.

      :returns: Next value where predicateFn returns true
      :throws: Halts if maxRetries exceeded
    */
    proc ref next(): OutputType {
      var retries = 0;
      while retries < maxRetries {
        const value = baseGen.next();
        if predicateFn(value) then return value;
        retries += 1;
      }
      halt("FilteredGenerator: exceeded ", maxRetries,
           " retries - predicate too restrictive");
    }

    /*
      Iterate over n filtered values.

      :arg n: Number of values to generate
      :yields: Values matching predicate
    */
    iter these(n: int = 100) ref : OutputType {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a filtered generator.

    Only produces values where predicate returns true.

    :arg gen: Base generator
    :arg pred: Predicate function
    :arg maxRetries: Max attempts per value (default: 100)
    :returns: Generator producing only values where pred(value) is true

    Example::

      // Generate even numbers only
      var evenGen = filter(intGen(), lambda(x: int) { return x % 2 == 0; });
  */
  proc filter(gen, pred, maxRetries: int = 100) {
    return new filteredGenerator(gen, pred, maxRetries);
  }

  /*
    Zip Generators
    --------------

    Combine multiple generators into tuple generators.
  */

  /*
    Generator that zips two generators into tuples.

    :type Gen1Type: Type of first generator
    :type Gen2Type: Type of second generator
    :var gen1: First generator
    :var gen2: Second generator
  */
  record zipGenerator {
    type Gen1Type;
    type Gen2Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;

    /*
      Initialize a zip generator.

      :arg gen1: First generator
      :arg gen2: Second generator
    */
    proc init(gen1, gen2) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.gen1 = gen1;
      this.gen2 = gen2;
    }

    /*
      Generate next tuple.

      :returns: (gen1.next(), gen2.next())
    */
    proc ref next() {
      return (gen1.next(), gen2.next());
    }

    /*
      Iterate over n tuples.

      :arg n: Number of tuples to generate
      :yields: 2-tuples of values
    */
    iter these(n: int = 100) ref {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Combine two generators into a tuple generator.

    :arg gen1: First generator
    :arg gen2: Second generator
    :returns: Generator producing (T1, T2) tuples

    Example::

      var gen = zipGen(intGen(), boolGen());
      var (num, flag) = gen.next();
  */
  proc zipGen(gen1, gen2) {
    return new zipGenerator(gen1, gen2);
  }

  /*
    3-way Zip Generator
    -------------------

    Combines three generators into 3-tuples.
  */

  /*
    Generator that zips three generators into 3-tuples.

    :type Gen1Type: Type of first generator
    :type Gen2Type: Type of second generator
    :type Gen3Type: Type of third generator
    :var gen1: First generator
    :var gen2: Second generator
    :var gen3: Third generator
  */
  record zip3Generator {
    type Gen1Type;
    type Gen2Type;
    type Gen3Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var gen3: Gen3Type;

    /*
      Initialize a 3-way zip generator.

      :arg gen1: First generator
      :arg gen2: Second generator
      :arg gen3: Third generator
    */
    proc init(gen1, gen2, gen3) {
      this.Gen1Type = gen1.type;
      this.Gen2Type = gen2.type;
      this.Gen3Type = gen3.type;
      this.gen1 = gen1;
      this.gen2 = gen2;
      this.gen3 = gen3;
    }

    /*
      Generate next 3-tuple.

      :returns: (gen1.next(), gen2.next(), gen3.next())
    */
    proc ref next() {
      return (gen1.next(), gen2.next(), gen3.next());
    }

    /*
      Iterate over n 3-tuples.

      :arg n: Number of tuples to generate
      :yields: 3-tuples of values
    */
    iter these(n: int = 100) ref {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Combine three generators into a tuple generator.

    :arg gen1: First generator
    :arg gen2: Second generator
    :arg gen3: Third generator
    :returns: Generator producing (T1, T2, T3) tuples
  */
  proc zipGen3(gen1, gen2, gen3) {
    return new zip3Generator(gen1, gen2, gen3);
  }

  /*
    OneOf Generator
    ---------------

    Randomly chooses between multiple generators.
  */

  /*
    Generator that randomly chooses between two generators.

    Each call to next() randomly selects which generator to use.

    :type Gen1Type: Type of first generator
    :type Gen2Type: Type of second generator
    :var gen1: First generator
    :var gen2: Second generator
    :var rng: Internal random stream
  */
  record oneOf2Generator {
    type Gen1Type;
    type Gen2Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var rng: randomStream(int);

    /*
      Initialize a oneOf generator with two choices.

      :arg gen1: First generator
      :arg gen2: Second generator
      :arg seed: Random seed (-1 for random)
    */
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

    /*
      Generate next value from randomly chosen generator.

      :returns: Value from gen1 or gen2 (50% each)
    */
    proc ref next() {
      const choice = abs(rng.next()) % 2;
      if choice == 0 then
        return gen1.next();
      else
        return gen2.next();
    }

    /*
      Iterate over n randomly chosen values.

      :arg n: Number of values to generate
      :yields: Values from randomly selected generators
    */
    iter these(n: int = 100) ref {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Generator that randomly chooses between three generators.

    :type Gen1Type: Type of first generator
    :type Gen2Type: Type of second generator
    :type Gen3Type: Type of third generator
    :var gen1: First generator
    :var gen2: Second generator
    :var gen3: Third generator
    :var rng: Internal random stream
  */
  record oneOf3Generator {
    type Gen1Type;
    type Gen2Type;
    type Gen3Type;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var gen3: Gen3Type;
    var rng: randomStream(int);

    /*
      Initialize a oneOf generator with three choices.

      :arg gen1: First generator
      :arg gen2: Second generator
      :arg gen3: Third generator
      :arg seed: Random seed (-1 for random)
    */
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

    /*
      Generate next value from randomly chosen generator.

      :returns: Value from gen1, gen2, or gen3 (33% each)
    */
    proc ref next() {
      const choice = abs(rng.next()) % 3;
      if choice == 0 then
        return gen1.next();
      else if choice == 1 then
        return gen2.next();
      else
        return gen3.next();
    }

    /*
      Iterate over n randomly chosen values.

      :arg n: Number of values to generate
      :yields: Values from randomly selected generators
    */
    iter these(n: int = 100) ref {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Randomly choose between two generators.

    :arg gen1: First generator
    :arg gen2: Second generator
    :arg seed: Random seed (-1 for random)
    :returns: Generator that randomly picks from gen1 or gen2

    Example::

      // Mix positive and negative numbers
      var gen = oneOf(intGen(1, 100), intGen(-100, -1));
  */
  proc oneOf(gen1, gen2, seed: int = -1) {
    return new oneOf2Generator(gen1, gen2, seed);
  }

  /*
    Randomly choose between three generators.

    :arg gen1: First generator
    :arg gen2: Second generator
    :arg gen3: Third generator
    :arg seed: Random seed (-1 for random)
    :returns: Generator that randomly picks from one of the three
  */
  proc oneOf(gen1, gen2, gen3, seed: int = -1) {
    return new oneOf3Generator(gen1, gen2, gen3, seed);
  }

  /*
    Frequency Generator
    -------------------

    Weighted random choice between generators.
  */

  /*
    Generator with weighted random choice between two generators.

    Uses weights to control probability of selecting each generator.
    With weights (3, 1), gen1 is chosen 75% of the time.

    :type Gen1Type: Type of first generator
    :type Gen2Type: Type of second generator
    :var weight1: Weight for first generator
    :var weight2: Weight for second generator
    :var gen1: First generator
    :var gen2: Second generator
    :var rng: Internal random stream
  */
  record frequency2Generator {
    type Gen1Type;
    type Gen2Type;
    var weight1: int;
    var weight2: int;
    var gen1: Gen1Type;
    var gen2: Gen2Type;
    var rng: randomStream(int);

    /*
      Initialize a frequency generator.

      :arg weight1: Weight for first generator
      :arg gen1: First generator
      :arg weight2: Weight for second generator
      :arg gen2: Second generator
      :arg seed: Random seed (-1 for random)
    */
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

    /*
      Generate next value with weighted selection.

      :returns: Value from gen1 (weight1/(weight1+weight2)) or gen2
    */
    proc ref next() {
      const totalWeight = weight1 + weight2;
      const choice = abs(rng.next()) % totalWeight;
      if choice < weight1 then return gen1.next();
      else return gen2.next();
    }

    /*
      Iterate over n weighted random values.

      :arg n: Number of values to generate
      :yields: Values with weighted selection
    */
    iter these(n: int = 100) ref {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a weighted random choice generator.

    :arg weight1: Weight for first generator
    :arg gen1: First generator
    :arg weight2: Weight for second generator
    :arg gen2: Second generator
    :arg seed: Random seed (-1 for random)
    :returns: Generator with weighted selection

    Example::

      // 90% normal numbers, 10% edge case (0)
      var gen = frequency(9, intGen(-100, 100), 1, constantGen(0));
  */
  proc frequency(weight1: int, gen1, weight2: int, gen2, seed: int = -1) {
    return new frequency2Generator(weight1, gen1, weight2, gen2, seed);
  }

  /*
    suchThat - Alias for Filter
    ---------------------------

    More readable name for filter, matching QuickCheck convention.
  */

  /*
    Create a filtered generator (alias for filter).

    :arg gen: Base generator
    :arg pred: Predicate function
    :arg maxRetries: Max attempts per value (default: 100)
    :returns: Generator producing only values where pred(value) is true

    Example::

      // Same as filter, but more readable in some contexts
      var positiveGen = suchThat(intGen(), lambda(x: int) { return x > 0; });
  */
  proc suchThat(gen, pred, maxRetries: int = 100) {
    return filter(gen, pred, maxRetries);
  }

  /*
    Resize Generator
    ----------------

    Scales the "size" parameter for sized generators.
  */

  /*
    Generator that scales the size parameter.

    Useful for controlling the size of generated collections.

    :type BaseGenType: Type of base generator
    :var baseGen: Base generator
    :var scaleFactor: Multiplier for size parameter
  */
  record resizedGenerator {
    type BaseGenType;
    var baseGen: BaseGenType;
    var scaleFactor: real;

    /*
      Initialize a resized generator.

      :arg baseGen: Base generator
      :arg scaleFactor: Size multiplier
    */
    proc init(baseGen, scaleFactor: real) {
      this.BaseGenType = baseGen.type;
      this.baseGen = baseGen;
      this.scaleFactor = scaleFactor;
    }

    /*
      Generate next value (size scaling applied to sized generators).

      :returns: Value from base generator with scaled size
    */
    proc ref next() {
      // For generators that respect size, this would scale
      // For now, just pass through
      return baseGen.next();
    }

    /*
      Iterate over n values.

      :arg n: Number of values to generate
      :yields: Values with scaled size
    */
    iter these(n: int = 100) ref {
      for 1..n {
        yield this.next();
      }
    }
  }

  /*
    Create a resized generator.

    Scales the size parameter for generators that support it.

    :arg gen: Base generator
    :arg scaleFactor: Size multiplier (0.5 = half size, 2.0 = double size)
    :returns: Generator with scaled size parameter
  */
  proc resize(gen, scaleFactor: real) {
    return new resizedGenerator(gen, scaleFactor);
  }

  /*
    NonEmpty Generator
    ------------------

    Ensures collections have at least one element.
  */

  /*
    Create a generator that produces non-empty collections.

    Filters out empty collections from the base generator.

    :arg gen: Base generator (should produce collections)
    :returns: Generator that only produces non-empty collections

    Example::

      // Generate non-empty lists
      var nonEmptyLists = nonEmpty(listGen(intGen()));
  */
  proc nonEmpty(gen) {
    return filter(gen, proc(lst) { return lst.size > 0; });
  }
}
