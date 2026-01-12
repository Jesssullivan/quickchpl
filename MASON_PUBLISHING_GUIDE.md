# Mason Package Publishing Guide

**Comprehensive guide to publishing Chapel packages to the Mason Registry**

This guide provides detailed information about Chapel's Mason build system and package manager, with specific focus on preparing packages for registry submission.

---

## Table of Contents

1. [Mason Package Structure](#mason-package-structure)
2. [Mason.toml Configuration](#masontoml-configuration)
3. [Mason Commands](#mason-commands)
4. [Package Publishing Process](#package-publishing-process)
5. [Best Practices](#best-practices)
6. [Property-Based Testing Library Considerations](#property-based-testing-library-considerations)
7. [Common Pitfalls](#common-pitfalls)
8. [Existing Package Examples](#existing-package-examples)

---

## 1. Mason Package Structure

### Directory Layout

Mason enforces a standard directory structure for both applications and libraries:

#### Library Package (created with `mason new <PackageName> --lib`):
```
PackageName/
├── Mason.toml          # Package manifest
├── Mason.lock          # Dependency lock file (auto-generated)
├── src/
│   └── PackageName.chpl    # Main module (must match package name)
├── test/
│   └── PackageNameTest.chpl
├── example/
│   └── PackageNameExample.chpl
└── target/             # Build artifacts (auto-generated)
    ├── debug/
    ├── release/
    ├── test/
    └── example/
```

#### Application Package (created with `mason new <AppName>`):
```
AppName/
├── Mason.toml
├── src/
│   └── AppName.chpl    # Contains main() routine
├── test/
└── example/
```

### Required Files

- **Mason.toml**: Package manifest (required)
- **src/<PackageName>.chpl**: Main module that matches the package name (required)
- **LICENSE**: License file (highly recommended)
- **README.md**: Package documentation (highly recommended)

### Naming Conventions

- **Package directory name** must match the `name` field in Mason.toml
- **Main source file** (in `src/`) must match the package name
- **Module name** in the main source file should match the package name
- Use **camelCase** for package names (e.g., `MyPackage`, `quickchpl`)
- Test files typically use pattern: `{packageName}Test.chpl`
- Example files typically use pattern: `{packageName}Example.chpl`

### Git Repository Structure

Mason packages must be hosted in a git repository with:
- Remote origin configured
- Version tags in format `v{major}.{minor}.{patch}` (e.g., `v0.1.0`, `v1.2.3`)
- Clean git history

---

## 2. Mason.toml Configuration

### Format

Mason.toml uses TOML (Tom's Obvious, Minimal Language) format. Reference: [TOML Spec](https://github.com/toml-lang/toml)

### Required Fields

All packages must include these fields in the `[brick]` section:

```toml
[brick]
name = "PackageName"           # Package identifier (must be unique in registry)
version = "1.0.0"              # Semantic version (a.b.c format)
chplVersion = "2.6.0..2.7.0"   # Compatible Chapel versions
type = "library"               # "library", "application", or "light"
```

### Optional Fields

```toml
[brick]
license = "MIT"                              # SPDX license identifier
authors = ["Name <email@example.com>"]       # Author information
repository = "https://github.com/user/repo"  # Source repository
description = "Brief package description"    # One-line description
keywords = ["testing", "property-based"]     # Search keywords (for discoverability)
tests = ["test1.chpl", "test2.chpl"]        # Explicit test file list
```

### Field Details

#### `name`
- Must be a valid Chapel identifier
- Should be unique in the registry (first-come, first-served)
- Use descriptive, clear names
- Avoid generic names that might conflict

#### `version`
- Must follow semantic versioning: `major.minor.patch`
- Example: `"1.0.0"`, `"0.2.1"`, `"2.15.3"`
- See [Semantic Versioning](#semantic-versioning) section for rules

#### `chplVersion`
Specifies compatible Chapel releases. Accepted formats:

```toml
chplVersion = "2.6.0"           # Version 2.6.0 or later
chplVersion = "2.6"             # Version 2.6.0 or later
chplVersion = "2.6.0..2.7.0"    # Versions 2.6.0 through 2.7.0 (inclusive)
```

#### `type`
- `"library"`: Reusable package without main routine
- `"application"`: Standalone executable with main routine
- `"light"`: Lightweight package (minimal dependencies)

#### `license`
- Use SPDX License Identifiers: https://spdx.org/licenses/
- Common options: `"MIT"`, `"Apache-2.0"`, `"BSD-3-Clause"`, `"GPL-3.0"`, `"None"`
- Defaults to `"None"` if not specified

#### `source` (Registry Manifest Only)
- Required when submitting to registry
- Not present in repository Mason.toml
- Points to git repository and specific version tag
- Example: `source = "https://github.com/user/package"`

### Dependency Sections

#### `[dependencies]`

Specify Chapel package dependencies:

```toml
[dependencies]
# Mason registry packages (simple version)
Curl = "1.0.0"
DataStructures = "1.0.0"

# Git repository dependencies
myDep = { git = "https://github.com/user/repo" }
myDep2 = { git = "https://github.com/user/repo", branch = "main" }
myDep3 = { git = "https://github.com/user/repo", rev = "abc123commit" }
```

#### `[dev-dependencies]`

Dependencies only needed for development/testing (not yet widely used):

```toml
[dev-dependencies]
# Development tools
# chplcheck = "1.0.0"  # Example (not in registry yet)
```

#### `[system]`

External system dependencies managed through Spack or pkg-config:

```toml
[system]
cmake = "3.18"
curl = "7.0"
```

### Example Sections

#### `[examples]`

List example files and their configurations:

```toml
[examples]
examples = ["myPackageExample.chpl", "advancedExample.chpl"]

[examples.myPackageExample]
compopts = "--savec tmp"       # Compiler options
execopts = "--count=20"        # Runtime arguments

[examples.advancedExample]
compopts = "-O3"
execopts = "--verbose"
```

**Note**: If `examples` array is specified, Mason only recognizes explicitly listed files and won't auto-discover others in the `example/` directory.

### Complete Example Mason.toml

Here's a complete example from the quickchpl project:

```toml
[brick]
name = "quickchpl"
version = "1.0.0"
chplVersion = "2.6.0..2.7.0"
license = "MIT"
authors = ["Jess Sullivan <jess@sulliwood.org>"]
repository = "https://gitlab.com/tinyland/projects/quickchpl"
description = "A simple property-based testing library for Chapel"
keywords = ["testing", "property-based", "quickcheck", "pbt", "fuzzing"]

[dependencies]
# No external dependencies - pure Chapel uWu

[dev-dependencies]
# chplcheck would be good here
```

### Mason.lock File

- **Auto-generated** by `mason update` or first `mason build`
- Contains resolved dependency versions and their locations
- **Never edit manually**
- Should be committed to version control for applications
- May be gitignored for libraries (debatable)

---

## 3. Mason Commands

### Package Creation

#### `mason new`
Creates a new Mason package with full directory structure.

```bash
# Create an application (with main routine)
mason new MyApp

# Create a library (no main routine)
mason new MyLibrary --lib

# Create without git repository
mason new MyPackage --no-vcs

# Specify package name different from directory
mason new my-dir --name MyPackage
```

**What it creates**:
- Project directory
- `Mason.toml` with basic configuration
- `src/` directory with main module file
- `test/` directory (empty)
- `example/` directory (empty)
- Git repository (unless `--no-vcs` specified)

#### `mason init`
Initializes an existing directory as a Mason package.

```bash
# Initialize current directory
mason init

# Initialize specific directory
mason init path/to/project
```

### Dependency Management

#### `mason add`
Adds a dependency to Mason.toml.

```bash
# Add latest version of a package
mason add PackageName

# Add specific version (manual edit of Mason.toml required)
# Edit Mason.toml: PackageName = "1.2.3"
```

#### `mason rm`
Removes a dependency from Mason.toml.

```bash
mason rm PackageName
```

#### `mason update`
Updates dependencies and generates/updates Mason.lock file.

```bash
mason update
```

This command:
- Resolves all dependencies
- Downloads Chapel dependencies from Mason Registry
- Creates or updates Mason.lock
- Should be run after modifying dependencies

### Building and Running

#### `mason build`
Compiles the package.

```bash
# Standard build (debug mode)
mason build

# Build with Chapel compiler options
mason build --no-optimize
mason build --savec tmp

# Build examples
mason build --example
```

Compiled binaries are placed in:
- `target/debug/<PackageName>` (default)
- `target/release/<PackageName>` (optimized builds)

#### `mason run`
Executes the built application.

```bash
# Run the application
mason run

# Run with arguments
mason run -- --arg1 value1 --arg2 value2

# List available examples
mason run --example

# Run specific example
mason run --example myPackageExample.chpl
```

### Testing

#### `mason test`
Runs the package test suite.

```bash
# Run all tests
mason test

# Run specific tests
mason test test1.chpl test2.chpl

# Run tests matching substring
mason test PropertyTests

# Filter unit tests by regex
mason test --filter 'testA|testB' test/file.chpl

# Show additional output
mason test --show
```

**Test Execution**:
- Tests in `test/` directory are compiled and executed
- Success = exit code 0
- Failure = non-zero exit code or uncaught error
- Supports UnitTest module for structured testing

**Test Configuration in Mason.toml**:
```toml
[brick]
tests = ["test1.chpl", "test2.chpl"]
```

If specified, only explicitly listed tests are run by default.

### Registry Operations

#### `mason search`
Searches the Mason registry for packages.

```bash
# Search for packages
mason search keyword

# Example
mason search linear
mason search json
```

**Note**: Search performs case-insensitive name matching. Results are not filtered by Chapel version compatibility.

#### `mason publish`
Publishes a package to a Mason registry.

```bash
# Automated publishing (recommended)
mason publish

# Dry run (check without publishing)
mason publish --dry-run

# Full check (includes build and tests)
mason publish --check

# Publish to local/private registry
mason publish path/to/registry

# Create and publish to new local registry
mason publish --create-registry path/to/new/registry
```

**Automated Process** (`mason publish`):
1. Verifies package structure and Mason.toml
2. Checks git repository and remote origin
3. Creates registry manifest with source field
4. Provides URL to create GitHub pull request
5. Opens browser to PR creation page

---

## 4. Package Publishing Process

### Prerequisites

Before publishing to the Mason Registry, ensure:

1. **Package is complete**:
   - Well-tested code
   - Documentation (README.md)
   - License file
   - Working examples (recommended)

2. **Git repository**:
   - Hosted on GitHub, GitLab, or similar
   - Remote origin configured: `git remote -v`
   - Clean working directory: `git status`

3. **Semantic version tag**:
   - Format: `v{major}.{minor}.{patch}`
   - Example: `git tag v0.1.0`
   - Pushed to remote: `git push origin v0.1.0`

4. **Mason.toml is complete**:
   - All required fields present
   - Valid Chapel version specification
   - Correct package type
   - License specified

### Submission Methods

#### Method 1: Automated (Recommended)

This is the easiest and recommended approach:

```bash
# 1. Ensure package is ready
mason build
mason test

# 2. Create and push version tag
git tag v0.1.0
git push origin v0.1.0

# 3. Test publishing (dry run)
mason publish --dry-run

# 4. Comprehensive check (builds and tests)
mason publish --check

# 5. Publish to registry
mason publish
```

**Steps**:
1. Mason validates your package
2. Creates a branch in your fork of mason-registry
3. Generates the registry manifest (`Bricks/<PackageName>/<version>.toml`)
4. Provides a URL to open a GitHub pull request
5. You open the PR and wait for maintainer approval

#### Method 2: Manual Submission

For more control or if automated publishing fails:

```bash
# 1. Fork mason-registry on GitHub
# Visit: https://github.com/chapel-lang/mason-registry
# Click "Fork"

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/mason-registry.git
cd mason-registry

# 3. Create a branch
git checkout -b add-quickchpl-v1.0.0

# 4. Create directory for your package
mkdir -p Bricks/quickchpl

# 5. Copy your Mason.toml to version file
cp /path/to/your/project/Mason.toml Bricks/quickchpl/1.0.0.toml

# 6. Add source field to the version file
# Edit Bricks/quickchpl/1.0.0.toml and add:
source = "https://github.com/YOUR_USERNAME/quickchpl"

# 7. Commit and push
git add Bricks/quickchpl/1.0.0.toml
git commit -m "Add quickchpl v1.0.0"
git push origin add-quickchpl-v1.0.0

# 8. Open pull request on GitHub
# Visit your fork and click "New Pull Request"
```

### Registry Manifest Format

When submitting to the registry, your `<version>.toml` file must include a `source` field:

```toml
[brick]
name = "PackageName"
version = "1.0.0"
chplVersion = "2.6.0"
license = "MIT"
type = "library"
source = "https://github.com/username/PackageName"  # Required for registry
authors = ["Name <email@example.com>"]

[dependencies]
# ... your dependencies
```

### Semantic Versioning

The Mason Registry **enforces semantic versioning** with strict conventions:

#### Version Format
All versions must follow `a.b.c` format:
- **a** = Major version (breaking changes)
- **b** = Minor version (backward-compatible additions)
- **c** = Patch version (bug fixes)

#### Versioning Rules

**Major Version (a)**:
- Increment for breaking API changes
- Examples: Updated data structures, removed methods, incompatible changes
- Reset minor and patch to 0
- Example: `1.13.1` → `2.0.0`

**Minor Version (b)**:
- Increment for backward-compatible new features
- Adds functionality without breaking existing code
- Reset patch to 0
- Example: `1.13.1` → `1.14.0`

**Patch Version (c)**:
- Increment for bug fixes only
- No API changes or new features
- Example: `1.13.1` → `1.13.2`

**Exception**: If major version is 0 (`0.x.x`), no conventions are enforced. This indicates pre-release/development status.

#### Version Tags in Git

```bash
# Create version tag
git tag v0.1.0

# Create annotated tag (recommended)
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to remote
git push origin v1.0.0

# List all tags
git tag -l
```

### Version Resolution Strategy

When dependencies conflict, Mason uses this hierarchy:

1. Select the **latest patch version** within compatible range
2. Choose the **highest minor version** within matching major versions
3. **Error** if multiple incompatible major versions are required

Example:
- Package A requires `Curl >= 1.2.0`
- Package B requires `Curl >= 1.3.5`
- Resolution: Uses `Curl 1.3.5` (or later if available)

### Approval Process

1. **Submit PR**: Open pull request to mason-registry
2. **Automated checks**: CI runs validation (if configured)
3. **Maintainer review**: Chapel team reviews submission
4. **Approval**: PR is merged into registry
5. **Availability**: Package is immediately available via `mason search` and `mason add`

### Maintenance Obligations

As a package maintainer:

- **Maintain package integrity**: Keep code functional and secure
- **Update documentation**: Keep README and examples current
- **Tag new releases**: Follow semantic versioning
- **Respond to issues**: Address user-reported problems
- **Notify if deprecating**: Contact Chapel team if package should be removed

The Mason Registry maintainers reserve the right to remove packages that fail to maintain integrity standards.

---

## 5. Best Practices

### Package Naming

**Do**:
- Use clear, descriptive names
- Follow camelCase convention (`MyPackage`, `quickchpl`)
- Choose names indicating purpose (`DataStructures`, `LinearAlgebraJama`)
- Keep names reasonably short

**Don't**:
- Use generic names (`Utils`, `Helpers`, `Common`)
- Include "chapel" in name unless necessary (e.g., `quickchpl` is fine because it's QuickCheck for Chapel)
- Use names that might conflict with standard library modules
- Use special characters or spaces

### Version Management

**Initial Release**:
- Start with `0.1.0` for first public version
- Use `0.x.x` during development phase
- Bump to `1.0.0` when API is stable

**Development Versions**:
```bash
# First release
git tag v0.1.0

# Bug fix
git tag v0.1.1

# New feature
git tag v0.2.0

# Stable API
git tag v1.0.0
```

**Semantic Versioning Tips**:
- Document breaking changes in CHANGELOG.md
- Consider deprecation warnings before breaking changes
- Major version 0 allows rapid iteration
- Once at 1.0.0+, follow versioning rules strictly

### Documentation Standards

**README.md should include**:
- Brief description (1-2 sentences)
- Installation instructions (manual and Mason)
- Quick start example
- Feature overview
- API documentation or link to docs
- License information
- Contributing guidelines (if accepting contributions)

**Code Documentation**:
```chapel
/*
 * Property-based test generator for integers.
 *
 * :arg min: Minimum value (inclusive)
 * :arg max: Maximum value (inclusive)
 * :returns: IntGenerator configured for range
 */
proc intGen(min: int = int.min, max: int = int.max) {
    // Implementation
}
```

### Testing Strategies

**Unit Tests** (`test/` directory):
- Test each public API function
- Use Chapel's UnitTest module for structured tests
- Organize tests by module or functionality
- Name tests descriptively

**Example Tests**:
```chapel
use UnitTest;

proc testIntGeneratorRange(test: borrowed Test) throws {
    var gen = intGen(0, 100);
    for 1..50 {
        var val = gen.generate();
        test.assertTrue(val >= 0 && val <= 100);
    }
}
```

**Exit Code Tests**:
```chapel
// test/simpleTest.chpl
use quickchpl;

proc main() {
    var result = quickCheck(intGen(), proc(x: int) { return x + 0 == x; });
    if !result {
        exit(1);  // Non-zero exit = failure
    }
}
```

**Test Configuration**:
```toml
[brick]
tests = [
    "unit/GeneratorTests.chpl",
    "unit/PropertyTests.chpl",
    "properties/SelfTests.chpl"
]
```

### Example Programs

**Purpose**:
- Demonstrate package usage
- Serve as documentation
- Provide starting point for users

**Example Structure**:
```chapel
// example/GettingStarted.chpl

/*
 * Getting Started with quickchpl
 *
 * This example demonstrates basic property-based testing.
 */

use quickchpl;

proc main() {
    writeln("=== quickchpl Getting Started ===\n");

    // Test that addition is commutative
    var gen = tupleGen(intGen(-100, 100), intGen(-100, 100));
    var prop = property(
        "addition is commutative",
        gen,
        proc((a, b): (int, int)) { return a + b == b + a; }
    );

    var result = check(prop);
    writeln(if result.passed then "✓ PASSED" else "✗ FAILED");
}
```

### License Requirements

**Choose a license**:
- **MIT**: Permissive, simple, recommended for libraries
- **Apache-2.0**: Permissive with patent grant
- **BSD-3-Clause**: Permissive with attribution
- **GPL-3.0**: Copyleft (requires derivatives to be GPL)
- **None**: Not recommended (unclear rights)

**Include LICENSE file**:
```bash
# MIT License example
curl https://opensource.org/licenses/MIT > LICENSE
# Edit to add your name and year
```

**Update Mason.toml**:
```toml
[brick]
license = "MIT"
```

### Project Organization

**Recommended Structure**:
```
PackageName/
├── .git/
├── .gitignore
├── LICENSE
├── README.md
├── CHANGELOG.md          # Version history (recommended)
├── Mason.toml
├── Mason.lock
├── src/
│   ├── PackageName.chpl  # Main public module
│   ├── Internals.chpl    # Private implementation
│   └── Utils.chpl        # Utility functions
├── test/
│   ├── unit/
│   │   ├── ModuleATests.chpl
│   │   └── ModuleBTests.chpl
│   └── integration/
│       └── IntegrationTests.chpl
├── example/
│   ├── GettingStarted.chpl
│   ├── AdvancedUsage.chpl
│   └── Patterns.chpl
└── docs/                 # Optional detailed docs
    ├── api.md
    └── guide.md
```

### Git Best Practices

**What to commit**:
- Source code (`src/`)
- Tests (`test/`)
- Examples (`example/`)
- `Mason.toml`
- `LICENSE`, `README.md`
- `.gitignore`

**What NOT to commit**:
- `target/` (build artifacts)
- `Mason.lock` (debatable - commit for apps, skip for libs)
- Editor configs (`.vscode/`, `.idea/`)
- OS files (`.DS_Store`)

**Sample .gitignore**:
```
# Build artifacts
/target/
*.o
*.tmp

# Mason lock (optional)
Mason.lock

# Editor
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
```

### Continuous Integration

**Test on CI**:
```yaml
# .gitlab-ci.yml example
test:
  image: chapel/chapel:latest
  script:
    - mason build
    - mason test
    - mason build --example
```

---

## 6. Property-Based Testing Library Considerations

### Specific Requirements for quickchpl

Based on the quickchpl project structure, here are specific considerations:

#### Package Type
- **Type**: `library` (not an application)
- No main routine in primary module
- Designed for import by other projects

#### Module Organization
quickchpl uses multiple modules:
- `chapelcheck` - Main entry point
- `Generators` - Random value generation
- `Properties` - Property definition and checking
- `Shrinkers` - Counterexample minimization
- `Reporters` - Test output formatting
- `Patterns` - Reusable property patterns
- `Combinators` - Generator combinators

**Main Module** (`src/chapelcheck.chpl`):
```chapel
module chapelcheck {
    public use Generators;
    public use Properties;
    public use Shrinkers;
    public use Reporters;
    public use Patterns;
    public use Combinators;
}
```

#### Testing Strategy

For a testing library, you need to test the tester:

1. **Unit Tests** (`tests/unit/`):
   - Test each generator type
   - Test property checking logic
   - Test shrinking algorithms
   - Test combinators

2. **Self-Tests** (`tests/properties/`):
   - Use quickchpl to test itself
   - Properties of generators (e.g., range constraints)
   - Properties of shrinkers (e.g., shrunk values are smaller)

3. **Example Tests**:
   - Ensure all examples compile and run
   - Examples serve as integration tests

#### Documentation Priority

Testing libraries need excellent documentation:

1. **Quick Start**: Get users testing in 5 minutes
2. **Generator Reference**: Document all built-in generators
3. **Pattern Library**: Show reusable property patterns
4. **Advanced Usage**: Custom generators, shrinking, configuration
5. **API Reference**: Complete function and type documentation

#### Chapel Version Compatibility

Testing libraries should support a wide range of Chapel versions:

```toml
# Support current and previous versions
chplVersion = "2.6.0..2.7.0"

# Or be conservative
chplVersion = "2.6.0"  # 2.6.0 or later
```

Consider:
- What Chapel features you use
- Backwards compatibility vs. new features
- Target audience (cutting-edge vs. stable)

#### Keywords for Discoverability

```toml
keywords = [
    "testing",
    "property-based",
    "quickcheck",
    "pbt",
    "fuzzing",
    "verification",
    "test-framework"
]
```

#### Dependencies

Property-based testing libraries typically have:
- **Zero dependencies** (like quickchpl) - easier to adopt
- **Minimal dependencies** - only essential packages
- Avoid heavy dependencies that increase adoption friction

---

## 7. Common Pitfalls

### Package Structure Pitfalls

**Problem**: Main module doesn't match package name
```
❌ Package: MyPackage, File: src/main.chpl
✅ Package: MyPackage, File: src/MyPackage.chpl
```

**Problem**: Missing required fields in Mason.toml
```toml
❌ Missing chplVersion
[brick]
name = "MyPackage"
version = "1.0.0"

✅ All required fields
[brick]
name = "MyPackage"
version = "1.0.0"
chplVersion = "2.6.0"
type = "library"
```

### Versioning Pitfalls

**Problem**: Version tag doesn't match Mason.toml
```bash
❌ Git tag: v1.0.0, Mason.toml: version = "0.9.0"
✅ Git tag: v1.0.0, Mason.toml: version = "1.0.0"
```

**Problem**: Not following semantic versioning
```
❌ Breaking change with patch bump: 1.0.0 → 1.0.1
✅ Breaking change with major bump: 1.0.0 → 2.0.0
```

**Problem**: Missing 'v' prefix on git tags
```bash
❌ git tag 1.0.0
✅ git tag v1.0.0
```

### Publishing Pitfalls

**Problem**: No remote origin configured
```bash
❌ git remote -v  # empty output
✅ git remote add origin https://github.com/user/repo.git
```

**Problem**: Source field in repository Mason.toml
```toml
❌ In your repo's Mason.toml:
source = "https://github.com/..."  # Don't include this

✅ Only in registry submission:
Bricks/MyPackage/1.0.0.toml should have source field
```

**Problem**: Submitting PR with multiple versions
```bash
❌ Single PR adds:
    Bricks/MyPackage/1.0.0.toml
    Bricks/MyPackage/1.1.0.toml

✅ Separate PR for each version:
    PR #1: Bricks/MyPackage/1.0.0.toml
    PR #2: Bricks/MyPackage/1.1.0.toml
```

### Testing Pitfalls

**Problem**: Tests that always pass
```chapel
❌ proc testSomething() {
    var x = compute();
    // No assertion - always succeeds!
}

✅ proc testSomething() {
    var x = compute();
    assert(x > 0);  // Actual validation
}
```

**Problem**: Tests not discoverable
```bash
❌ Tests in wrong location: /tests_dir/test.chpl
✅ Tests in correct location: /test/test.chpl
```

**Problem**: Tests with side effects
```chapel
❌ Test modifies global state or files without cleanup
✅ Tests are isolated and clean up after themselves
```

### Documentation Pitfalls

**Problem**: No usage examples
```markdown
❌ README only describes features, no code examples
✅ README includes quick start with copy-pasteable code
```

**Problem**: Outdated examples
```chapel
❌ Examples use old API that no longer exists
✅ Examples tested and updated with each release
```

### Dependency Pitfalls

**Problem**: Circular dependencies
```toml
❌ Package A depends on B, B depends on A
✅ Refactor to eliminate circular dependency
```

**Problem**: Overly restrictive version constraints
```toml
❌ chplVersion = "2.6.0..2.6.0"  # Only one version
✅ chplVersion = "2.6.0..2.7.0"  # Reasonable range
```

---

## 8. Existing Package Examples

### Packages in Mason Registry

Current packages (as of 2026):
- `Codecs` - Encoding/decoding utilities
- `DataStructures` - Additional data structures
- `ForwardModeAD` - Automatic differentiation
- `GPUIterator` - GPU acceleration
- `Gnuplot` - Plotting interface
- `HelloWorld` - Example package
- `LinearAlgebraJama` - Linear algebra routines
- `LocalAtomics` - Atomic operations
- `Logging` - Logging framework
- `MatrixMarket` - Matrix file I/O
- `NumpyLike` - NumPy-style operations
- `StringUtils` - String utilities
- `SymArrayDmap` - Array distribution
- `UUID` - UUID generation

### Example: HelloWorld (Minimal Package)

**Mason.toml**:
```toml
[brick]
authors = "Ben McDonald"
chplVersion = "1.27.0"
license = "None"
name = "HelloWorld"
source = "https://github.com/bmcdonald3/HelloWorld"
type = "library"
version = "0.1.0"
```

**Structure**:
```
HelloWorld/
├── Mason.toml
└── src/
    └── HelloWorld.chpl
```

### Example: LinearAlgebraJama (With Version Range)

**Mason.toml**:
```toml
[brick]
name = "LinearAlgebraJama"
version = "0.1.0"
chplVersion = "1.16.0..1.18.0"  # Version range
author = "ct-clmsn"
source = "https://github.com/ct-clmsn/LinearAlgebraJama"

[dependencies]
```

### Example: NumpyLike (GitLab Source)

**Mason.toml**:
```toml
[brick]
name = "NumpyLike"
version = "0.1.0"
chplVersion = "1.19.0"
source = "https://gitlab.com/npadmana/numpylike.git"  # GitLab supported

[dependencies]
```

### Example: Codecs (Newer Chapel Version)

**Mason.toml**:
```toml
[brick]
chplVersion = "1.29.0"
license = "None"
name = "Codecs"
type = "library"
version = "0.1.0"
source = "https://github.com/bmcdonald3/Codecs"
```

### Example: quickchpl (Complete Testing Library)

**Mason.toml**:
```toml
[brick]
name = "quickchpl"
version = "1.0.0"
chplVersion = "2.6.0..2.7.0"
license = "MIT"
authors = ["Jess Sullivan <jess@sulliwood.org>"]
repository = "https://gitlab.com/tinyland/projects/quickchpl"
description = "A simple property-based testing library for Chapel"
keywords = ["testing", "property-based", "quickcheck", "pbt", "fuzzing"]

[dependencies]
# No external dependencies - pure Chapel

[dev-dependencies]
# Future: chplcheck for linting
```

**Project Structure**:
```
quickchpl/
├── .git/
├── .gitignore
├── LICENSE (MIT)
├── README.md (comprehensive)
├── Mason.toml
├── src/
│   ├── chapelcheck.chpl  # Main module
│   ├── Generators.chpl
│   ├── Properties.chpl
│   ├── Shrinkers.chpl
│   ├── Reporters.chpl
│   ├── Patterns.chpl
│   └── Combinators.chpl
├── test/
│   ├── unit/
│   │   ├── GeneratorTests.chpl
│   │   ├── PropertyTests.chpl
│   │   └── ShrinkerTests.chpl
│   └── properties/
│       └── SelfTests.chpl
└── examples/
    ├── GettingStarted.chpl
    ├── AlgebraicProperties.chpl
    └── CustomGenerators.chpl
```

---

## Quick Reference: Publishing Checklist

### Pre-Publication Checklist

- [ ] Package builds successfully: `mason build`
- [ ] All tests pass: `mason test`
- [ ] Examples work: `mason build --example && mason run --example`
- [ ] README.md is complete and accurate
- [ ] LICENSE file is present
- [ ] Mason.toml has all required fields
- [ ] Version follows semantic versioning
- [ ] Git repository is clean: `git status`
- [ ] Remote origin is configured: `git remote -v`
- [ ] Version tag exists: `git tag v1.0.0`
- [ ] Version tag is pushed: `git push origin v1.0.0`
- [ ] Mason.toml version matches git tag
- [ ] Package name is unique (check `mason search`)

### Publication Commands

```bash
# 1. Final build and test
mason build && mason test

# 2. Create version tag
git tag v1.0.0
git push origin v1.0.0

# 3. Dry run
mason publish --dry-run

# 4. Full check
mason publish --check

# 5. Publish
mason publish

# 6. Follow link to create PR
# Wait for approval from Mason Registry maintainers
```

### Post-Publication

- [ ] Verify package appears in registry: `mason search YourPackage`
- [ ] Test installation: `mason add YourPackage` (in a test project)
- [ ] Update documentation with Mason installation instructions
- [ ] Announce release (if appropriate)
- [ ] Monitor for user issues

---

## Additional Resources

### Official Documentation
- **Mason Documentation**: https://chapel-lang.org/docs/tools/mason/mason.html
- **Mason Guide**: https://chapel-lang.org/docs/tools/mason/guide/
- **Manifest File**: https://chapel-lang.org/docs/tools/mason/guide/manifestfile.html
- **Mason Registry**: https://chapel-lang.org/docs/tools/mason/guide/masonregistry.html
- **Submitting Packages**: https://chapel-lang.org/docs/tools/mason/guide/submitting.html

### Repository Links
- **Mason Registry**: https://github.com/chapel-lang/mason-registry
- **Chapel Language**: https://github.com/chapel-lang/chapel

### Community
- **Chapel Discourse**: https://chapel.discourse.group/
- **Chapel Gitter**: https://gitter.im/chapel-lang/chapel

### Standards
- **TOML Spec**: https://github.com/toml-lang/toml
- **Semantic Versioning**: https://semver.org/
- **SPDX Licenses**: https://spdx.org/licenses/

---

**Generated**: 2026-01-12
**For**: quickchpl property-based testing library
**Chapel Version**: 2.6-2.7
**Mason Version**: Current stable
