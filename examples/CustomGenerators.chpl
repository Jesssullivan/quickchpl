// quickchpl: Custom Generators Example
// Demonstrates creating generators for custom types

module CustomGenerators {
  use quickchpl;
  use List;
  use Random;

  //============================================================================
  // Custom Record Type: Point
  //============================================================================

  record Point {
    var x: int;
    var y: int;

    proc distance(): real {
      return sqrt((x * x + y * y): real);
    }

    // Required for quickchpl to stringify counterexamples
    proc writeThis(f) throws {
      f.write("Point(", x, ", ", y, ")");
    }
  }

  // Custom generator for Point using composition
  proc pointGen(minCoord: int = -100, maxCoord: int = 100) {
    return map(
      tupleGen(intGen(minCoord, maxCoord), intGen(minCoord, maxCoord)),
      proc(args: (int, int)) { const (x, y) = args; return new Point(x, y); }
    );
  }

  //============================================================================
  // Custom Record Type: Rectangle
  //============================================================================

  record Rectangle {
    var width: int;
    var height: int;

    proc area(): int {
      return width * height;
    }

    proc perimeter(): int {
      return 2 * (width + height);
    }

    // Required for quickchpl to stringify counterexamples
    proc writeThis(f) throws {
      f.write("Rectangle(", width, " x ", height, ")");
    }
  }

  // Generator for positive rectangles
  proc rectangleGen(maxDim: int = 100) {
    return map(
      tupleGen(positiveIntGen(maxDim), positiveIntGen(maxDim)),
      proc(args: (int, int)) { const (w, h) = args; return new Rectangle(w, h); }
    );
  }

  //============================================================================
  // Custom Enum Type: Color
  //============================================================================

  enum Color {
    Red, Green, Blue, Yellow, Cyan, Magenta, White, Black
  }

  // Generator for Color enum
  record ColorGenerator {
    var rng: randomStream(int);

    proc init(seed: int = -1) {
      if seed >= 0 {
        this.rng = new randomStream(int, seed);
      } else {
        this.rng = new randomStream(int);
      }
    }

    proc ref next(): Color {
      const choice = abs(rng.next()) % 8;
      select choice {
        when 0 do return Color.Red;
        when 1 do return Color.Green;
        when 2 do return Color.Blue;
        when 3 do return Color.Yellow;
        when 4 do return Color.Cyan;
        when 5 do return Color.Magenta;
        when 6 do return Color.White;
        otherwise do return Color.Black;
      }
    }

    iter these(n: int = 100) ref : Color {
      for i in 1..n {
        yield this.next();
      }
    }
  }

  proc colorGen(seed: int = -1): ColorGenerator {
    return new ColorGenerator(seed);
  }

  //============================================================================
  // Main: Demonstrate custom generators
  //============================================================================

  proc main() {
    writeln("quickchpl Custom Generators Example");
    writeln("=" * 50);
    writeln();

    // Test Point properties
    writeln("Testing Point Properties:");
    writeln("-" * 40);

    {
      var gen = pointGen(-100, 100);

      // Distance is non-negative
      var prop1 = property(
        "point distance is non-negative",
        gen,
        proc(p: Point) { return p.distance() >= 0.0; }
      );
      var result1 = check(prop1);
      printResult(result1.passed, prop1.name, result1.numTests);

      // Origin has distance 0
      var originGen = constantGen(new Point(0, 0));
      var prop2 = property(
        "origin has distance 0",
        originGen,
        proc(p: Point) { return p.distance() == 0.0; }
      );
      var result2 = check(prop2);
      printResult(result2.passed, prop2.name, result2.numTests);
    }
    writeln();

    // Test Rectangle properties
    writeln("Testing Rectangle Properties:");
    writeln("-" * 40);

    {
      var gen = rectangleGen(100);

      // Area is positive for positive dimensions
      var prop1 = property(
        "rectangle area is positive",
        gen,
        proc(r: Rectangle) { return r.area() > 0; }
      );
      var result1 = check(prop1);
      printResult(result1.passed, prop1.name, result1.numTests);

      // Perimeter is at least 4 (minimum 1x1 rectangle)
      var prop2 = property(
        "rectangle perimeter >= 4",
        gen,
        proc(r: Rectangle) { return r.perimeter() >= 4; }
      );
      var result2 = check(prop2);
      printResult(result2.passed, prop2.name, result2.numTests);

      // Area <= (perimeter/4)^2 (isoperimetric inequality)
      var prop3 = property(
        "area bounded by perimeter",
        gen,
        proc(r: Rectangle) {
          const p = r.perimeter(): real;
          const maxArea = (p / 4.0) * (p / 4.0);
          return r.area(): real <= maxArea;
        }
      );
      var result3 = check(prop3);
      printResult(result3.passed, prop3.name, result3.numTests);
    }
    writeln();

    // Test Color generator
    writeln("Testing Color Enum Generator:");
    writeln("-" * 40);

    {
      var gen = colorGen();

      // All colors are valid enum values
      var prop = property(
        "generated colors are valid",
        gen,
        proc(c: Color) {
          return c == Color.Red || c == Color.Green || c == Color.Blue ||
                 c == Color.Yellow || c == Color.Cyan || c == Color.Magenta ||
                 c == Color.White || c == Color.Black;
        }
      );
      var result = check(prop);
      printResult(result.passed, prop.name, result.numTests);

      // Show distribution (not a property test, just informative)
      writeln("\n  Color distribution (100 samples):");
      var counts: [0..7] int;
      for i in 1..100 {
        const c = gen.next();
        select c {
          when Color.Red do counts[0] += 1;
          when Color.Green do counts[1] += 1;
          when Color.Blue do counts[2] += 1;
          when Color.Yellow do counts[3] += 1;
          when Color.Cyan do counts[4] += 1;
          when Color.Magenta do counts[5] += 1;
          when Color.White do counts[6] += 1;
          when Color.Black do counts[7] += 1;
        }
      }
      writeln("    Red=", counts[0], " Green=", counts[1], " Blue=", counts[2],
              " Yellow=", counts[3]);
      writeln("    Cyan=", counts[4], " Magenta=", counts[5], " White=", counts[6],
              " Black=", counts[7]);
    }
    writeln();

    writeln("=" * 50);
    writeln("Custom generators example complete!");
  }
}
