/*
  Reporters Module
  ================

  Formatted output for test results in multiple formats.

  This module provides reporters for displaying and exporting test results
  in various formats suitable for different use cases:

  - Console output with optional color
  - TAP (Test Anything Protocol) for CI integration
  - JUnit XML for IDE and CI tool integration

  **Output Formats:**

  - :proc:`printResult` - Console output for single test
  - :proc:`printSummary` - Console summary of all tests
  - :proc:`formatTAP` - TAP format for CI
  - :proc:`formatJUnit` - JUnit XML for IDEs

  **Color Support:**

  - :proc:`greenText` - Success messages
  - :proc:`redText` - Failure messages
  - :proc:`yellowText` - Warnings/counterexamples

  Example::

    use Reporters;

    // Print test result to console
    printResult(true, "addition commutes", 100);
    // Output: ✓ addition commutes passed 100 tests

    // Print failure with counterexample
    printResult(false, "subtraction commutes", 1, "(5, 3)");
    // Output: ✗ subtraction commutes FAILED
    //         Counterexample: (5, 3)
*/
module Reporters {
  use IO;
  use List;

  /*
    Verbosity Levels
    ----------------

    Control how much output is displayed.
  */

  /*
    Verbosity level for test output.

    - ``Quiet`` - Only show final summary
    - ``Normal`` - Show failures only
    - ``Verbose`` - Show all tests
    - ``Exhaustive`` - Show all, don't stop on failure
  */
  enum Verbosity {
    Quiet,
    Normal,
    Verbose,
    Exhaustive
  }

  /*
    Console Reporter
    ----------------

    Human-readable console output.
  */

  /*
    Format a test result as a string.

    :arg passed: Whether the test passed
    :arg propertyName: Name of the property
    :arg numTests: Number of tests run
    :arg failureInfo: Counterexample (if failed)
    :arg shrunkInfo: Minimized counterexample (if different)
    :returns: Formatted string for console output
  */
  proc formatResult(passed: bool, propertyName: string, numTests: int,
                    failureInfo: string = "", shrunkInfo: string = ""): string {
    if passed {
      return "✓ " + propertyName + " passed " + numTests:string + " tests";
    } else {
      var msg = "✗ " + propertyName + " FAILED\n";
      if failureInfo.size > 0 {
        msg += "  Counterexample: " + failureInfo + "\n";
      }
      if shrunkInfo.size > 0 && shrunkInfo != failureInfo {
        msg += "  Shrunk to: " + shrunkInfo + "\n";
      }
      return msg;
    }
  }

  /*
    Print a test result to console.

    :arg passed: Whether the test passed
    :arg propertyName: Name of the property
    :arg numTests: Number of tests run
    :arg failureInfo: Counterexample (if failed)
    :arg shrunkInfo: Minimized counterexample (if different)
  */
  proc printResult(passed: bool, propertyName: string, numTests: int,
                   failureInfo: string = "", shrunkInfo: string = "") {
    writeln(formatResult(passed, propertyName, numTests, failureInfo, shrunkInfo));
  }

  /*
    Print a summary of multiple test results.

    :arg numPassed: Count of passing properties
    :arg numFailed: Count of failing properties
    :arg totalTests: Total individual tests run
    :arg duration: Total execution time (seconds)
  */
  proc printSummary(numPassed: int, numFailed: int, totalTests: int, duration: real) {
    writeln();
    writeln("=" * 50);
    writeln("Summary: ", numPassed, " passed, ", numFailed, " failed");
    writeln("Total tests run: ", totalTests);
    writeln("Duration: ", duration:string, " seconds");

    if numFailed == 0 {
      writeln("All properties passed! ✓");
    } else {
      writeln("Some properties failed! ✗");
    }
    writeln("=" * 50);
  }

  /*
    TAP (Test Anything Protocol) Reporter
    -------------------------------------

    Machine-readable format for CI integration.
    See: https://testanything.org/tap-specification.html
  */

  /*
    Format results as TAP output.

    TAP is a simple text-based format widely supported by CI tools.

    :arg results: List of (passed, name, numTests, failureInfo) tuples
    :returns: TAP-formatted string

    Example output::

      TAP version 13
      1..2
      ok 1 - addition commutes
      not ok 2 - subtraction commutes
        ---
        counterexample: (5, 3)
        ...
  */
  proc formatTAP(results: list((bool, string, int, string))): string {
    var output = "TAP version 13\n";
    output += "1.." + results.size:string + "\n";

    var testNum = 1;
    for (passed, name, numTests, failureInfo) in results {
      if passed {
        output += "ok " + testNum:string + " - " + name + "\n";
      } else {
        output += "not ok " + testNum:string + " - " + name + "\n";
        if failureInfo.size > 0 {
          output += "  ---\n";
          output += "  counterexample: " + failureInfo + "\n";
          output += "  ...\n";
        }
      }
      testNum += 1;
    }

    return output;
  }

  /*
    Write TAP output to a file.

    :arg filename: Output file path
    :arg results: List of test results
  */
  proc writeTAP(filename: string, results: list((bool, string, int, string))) {
    try {
      var f = open(filename, ioMode.cw);
      var writer = f.writer(locking=false);
      writer.write(formatTAP(results));
      f.close();
    } catch e {
      writeln("Error writing TAP file: ", e);
    }
  }

  /*
    JUnit XML Reporter
    ------------------

    XML format for IDE and CI tool integration.
  */

  /*
    Escape XML special characters.

    :arg s: String to escape
    :returns: XML-safe string
  */
  proc escapeXML(s: string): string {
    var result = s;
    result = result.replace("&", "&amp;");
    result = result.replace("<", "&lt;");
    result = result.replace(">", "&gt;");
    result = result.replace("\"", "&quot;");
    result = result.replace("'", "&apos;");
    return result;
  }

  /*
    Format results as JUnit XML.

    JUnit XML is widely supported by IDEs (IntelliJ, VS Code) and
    CI tools (Jenkins, GitLab CI, GitHub Actions).

    :arg suiteName: Name for the test suite
    :arg results: List of (passed, name, numTests, failureInfo, duration) tuples
    :returns: JUnit XML string

    Example output::

      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite name="quickchpl" tests="2" failures="1" time="0.5">
        <testcase name="addition commutes" time="0.2"/>
        <testcase name="subtraction commutes" time="0.3">
          <failure message="Property failed">
            Counterexample: (5, 3)
          </failure>
        </testcase>
      </testsuite>
  */
  proc formatJUnit(suiteName: string, results: list((bool, string, int, string, real))): string {
    var numTests = results.size;
    var numFailures = 0;
    var totalTime = 0.0;

    for (passed, _, _, _, duration) in results {
      if !passed then numFailures += 1;
      totalTime += duration;
    }

    var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    xml += "<testsuite name=\"" + escapeXML(suiteName) + "\" ";
    xml += "tests=\"" + numTests:string + "\" ";
    xml += "failures=\"" + numFailures:string + "\" ";
    xml += "time=\"" + totalTime:string + "\">\n";

    for (passed, name, numTestsRun, failureInfo, duration) in results {
      xml += "  <testcase name=\"" + escapeXML(name) + "\" ";
      xml += "time=\"" + duration:string + "\"";

      if passed {
        xml += "/>\n";
      } else {
        xml += ">\n";
        xml += "    <failure message=\"Property failed\">\n";
        xml += "      Counterexample: " + escapeXML(failureInfo) + "\n";
        xml += "    </failure>\n";
        xml += "  </testcase>\n";
      }
    }

    xml += "</testsuite>\n";
    return xml;
  }

  /*
    Write JUnit XML to a file.

    :arg filename: Output file path
    :arg suiteName: Name for the test suite
    :arg results: List of test results with timing
  */
  proc writeJUnit(filename: string, suiteName: string,
                  results: list((bool, string, int, string, real))) {
    try {
      var f = open(filename, ioMode.cw);
      var writer = f.writer(locking=false);
      writer.write(formatJUnit(suiteName, results));
      f.close();
    } catch e {
      writeln("Error writing JUnit file: ", e);
    }
  }

  /*
    Progress Reporter
    -----------------

    Visual progress feedback during test execution.
  */

  /*
    Print a progress indicator for each test.

    Prints '.' for pass, 'F' for fail. Newline every 50 tests.

    :arg testNum: Current test number
    :arg passed: Whether this test passed
  */
  proc printProgress(testNum: int, passed: bool) {
    if passed then write(".");
    else write("F");

    // Newline every 50 tests
    if testNum % 50 == 0 then writeln();
  }

  /*
    Print a spinner for long-running tests.

    Shows animated spinner to indicate progress.

    :arg step: Current step number (for animation)
  */
  proc printSpinner(step: int) {
    const spinners = ["|", "/", "-", "\\"];
    const idx = step % 4;
    write("\r", spinners[idx], " Running tests...");
  }

  /*
    Color Support
    -------------

    ANSI color codes for terminal output.
  */

  /* ANSI escape character. */
  const ESC = 0x1B: uint(8): string;

  /* Green color code (success). */
  const GREEN = ESC + "[32m";

  /* Red color code (failure). */
  const RED = ESC + "[31m";

  /* Yellow color code (warning). */
  const YELLOW = ESC + "[33m";

  /* Reset to default color. */
  const RESET = ESC + "[0m";

  /* Bold text. */
  const BOLD = ESC + "[1m";

  /*
    Apply color to a string.

    :arg s: String to colorize
    :arg color: ANSI color code
    :returns: Colorized string
  */
  proc colorize(s: string, color: string): string {
    return color + s + RESET;
  }

  /*
    Format string in green (success).

    :arg s: String to format
    :returns: Green-colored string
  */
  proc greenText(s: string): string {
    return colorize(s, GREEN);
  }

  /*
    Format string in red (failure).

    :arg s: String to format
    :returns: Red-colored string
  */
  proc redText(s: string): string {
    return colorize(s, RED);
  }

  /*
    Format string in yellow (warning).

    :arg s: String to format
    :returns: Yellow-colored string
  */
  proc yellowText(s: string): string {
    return colorize(s, YELLOW);
  }

  /*
    Format string in bold.

    :arg s: String to format
    :returns: Bold string
  */
  proc boldText(s: string): string {
    return colorize(s, BOLD);
  }

  /*
    Format a test result with color.

    Like formatResult but with ANSI colors for terminal display.

    :arg passed: Whether the test passed
    :arg propertyName: Name of the property
    :arg numTests: Number of tests run
    :arg failureInfo: Counterexample (if failed)
    :arg shrunkInfo: Minimized counterexample (if different)
    :returns: Colorized formatted string
  */
  proc formatResultColor(passed: bool, propertyName: string, numTests: int,
                         failureInfo: string = "", shrunkInfo: string = ""): string {
    if passed {
      return greenText("✓") + " " + propertyName + " passed " + numTests:string + " tests";
    } else {
      var msg = redText("✗") + " " + boldText(propertyName) + " FAILED\n";
      if failureInfo.size > 0 {
        msg += "  Counterexample: " + yellowText(failureInfo) + "\n";
      }
      if shrunkInfo.size > 0 && shrunkInfo != failureInfo {
        msg += "  Shrunk to: " + yellowText(shrunkInfo) + "\n";
      }
      return msg;
    }
  }
}
