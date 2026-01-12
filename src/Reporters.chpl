// quickchpl: Test Reporters
// Provides formatted output for test results (console, TAP, JUnit XML)

module Reporters {
  use IO;
  use List;

  // Forward declaration - TestResult is defined in Properties
  // We'll use a local copy for this module

  //============================================================================
  // Verbosity Levels
  //============================================================================

  enum Verbosity {
    Quiet,       // Only summary
    Normal,      // Show failures
    Verbose,     // Show all tests
    Exhaustive   // Don't stop on first failure
  }

  //============================================================================
  // Console Reporter
  //============================================================================

  // Format a single test result for console output
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

  // Print a test result to console
  proc printResult(passed: bool, propertyName: string, numTests: int,
                   failureInfo: string = "", shrunkInfo: string = "") {
    writeln(formatResult(passed, propertyName, numTests, failureInfo, shrunkInfo));
  }

  // Print a summary of multiple test results
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

  //============================================================================
  // TAP (Test Anything Protocol) Reporter
  //============================================================================

  // Format results as TAP output
  // TAP format: https://testanything.org/tap-specification.html
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

  // Write TAP output to file
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

  //============================================================================
  // JUnit XML Reporter
  //============================================================================

  // Escape XML special characters
  proc escapeXML(s: string): string {
    var result = s;
    result = result.replace("&", "&amp;");
    result = result.replace("<", "&lt;");
    result = result.replace(">", "&gt;");
    result = result.replace("\"", "&quot;");
    result = result.replace("'", "&apos;");
    return result;
  }

  // Format results as JUnit XML
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

  // Write JUnit XML to file
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

  //============================================================================
  // Progress Reporter
  //============================================================================

  // Print a progress dot for each test
  proc printProgress(testNum: int, passed: bool) {
    if passed then write(".");
    else write("F");

    // Newline every 50 tests
    if testNum % 50 == 0 then writeln();
  }

  // Print a spinner for long-running tests
  proc printSpinner(step: int) {
    const spinners = ["|", "/", "-", "\\"];
    const idx = step % 4;
    write("\r", spinners[idx], " Running tests...");
  }

  //============================================================================
  // Color Support
  //============================================================================

  // ANSI color codes (using hex escapes)
  const ESC = 0x1B: uint(8): string;
  const GREEN = ESC + "[32m";
  const RED = ESC + "[31m";
  const YELLOW = ESC + "[33m";
  const RESET = ESC + "[0m";
  const BOLD = ESC + "[1m";

  // Format with color (for terminal output)
  proc colorize(s: string, color: string): string {
    return color + s + RESET;
  }

  proc greenText(s: string): string {
    return colorize(s, GREEN);
  }

  proc redText(s: string): string {
    return colorize(s, RED);
  }

  proc yellowText(s: string): string {
    return colorize(s, YELLOW);
  }

  proc boldText(s: string): string {
    return colorize(s, BOLD);
  }

  // Format result with color
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
