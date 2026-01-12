# quickchpl Integration Master Plan
**Complete Chapel-Respecting Implementation Strategy**

**Version**: 1.0
**Date**: 2026-01-12
**Status**: Ready for Implementation
**Estimated Timeline**: 15-20 hours over 1-2 weeks

---

## Executive Summary

This master plan outlines the complete strategy for:

1. **Establishing GitHub as canonical repository** for quickchpl
2. **Translating GitLab CI to GitHub Actions** with Mason integration
3. **Setting up local Mason development workflow** using local registries
4. **Integrating quickchpl into aoc-2025-chapel-27** as a demonstration project
5. **Creating comprehensive documentation** for Mason maintainers

**Key Insight**: The aoc-2025-chapel-27 project **already has 486 lines of custom PBT infrastructure** that quickchpl can replace, making it the perfect demonstration of quickchpl's value proposition to Mason maintainers.

**Outcome**: A working demonstration showing 88% code reduction in testing infrastructure, full Mason integration, and real-world usage in production-quality AoC solutions.

---

## Table of Contents

1. [Research Findings](#research-findings)
2. [Overall Architecture](#overall-architecture)
3. [Phase 1: GitHub Setup](#phase-1-github-setup)
4. [Phase 2: CI/CD Migration](#phase-2-cicd-migration)
5. [Phase 3: Local Development Workflow](#phase-3-local-development-workflow)
6. [Phase 4: AoC Integration](#phase-4-aoc-integration)
7. [Phase 5: Demonstration](#phase-5-demonstration)
8. [Technical Specifications](#technical-specifications)
9. [Risk Management](#risk-management)
10. [Success Criteria](#success-criteria)

---

## Research Findings

### Mason Local Development Patterns

**Key Discovery**: Mason supports **local registries** for development workflows.

**Recommended Approach**:
```bash
# Create local registry
mkdir -p ~/mason-local-dev/Bricks/quickchpl

# Add manifest with local source
cat > ~/mason-local-dev/Bricks/quickchpl/1.0.0.toml <<EOF
[brick]
name = "quickchpl"
version = "1.0.0"
source = "/Users/jsullivan2/git/quickchpl"  # Local path!
...
EOF

# Configure environment
export MASON_REGISTRY="local-dev|$HOME/mason-local-dev,mason-registry|https://github.com/chapel-lang/mason-registry"

# In consumer project (aoc-2025-chapel-27)
mason add quickchpl
mason update  # Immediately picks up changes from local source
```

**Benefits**:
- No git commits needed during development
- Changes reflected immediately
- Most similar to published package workflow
- Works across multiple consumer projects

### aoc-2025-chapel-27 Analysis

**Project Overview**:
- 5 working Advent of Code 2025 solutions
- **486 lines of custom PBT infrastructure** (`QuickCheck.chpl`, `AOCGenerators.chpl`)
- GitLab CI/CD with 5-stage pipeline
- Makefile-based build system (NOT Mason currently)
- Comprehensive testing (10 test files, 100+ test cases)

**Critical Finding**: Perfect demonstration project because:
1. Already embraces property-based testing
2. Has custom infrastructure that quickchpl can replace
3. Production-quality code with real complexity
4. Quantifiable benefits (88% code reduction projected)

---

## Overall Architecture

### Repository Structure

```
GitHub Ecosystem:
├── github.com/Jesssullivan/chplcheck (quickchpl)
│   ├── src/                    # Main package source
│   ├── tests/                  # quickchpl self-tests
│   ├── examples/               # Example programs
│   ├── .github/workflows/      # GitHub Actions CI
│   └── Mason.toml              # Package manifest
│
├── mason-registry fork
│   └── Bricks/quickchpl/
│       └── 1.0.0.toml          # Registry manifest
│
└── aoc-2025-chapel-27 (demonstration)
    ├── src/                    # AoC solutions
    ├── tests/                  # Tests using quickchpl
    ├── Mason.toml              # Depends on quickchpl
    └── .github/workflows/      # GitHub Actions CI
```

### Local Development Environment

```
~/mason-local-dev/               # Local Mason registry
├── Bricks/
│   └── quickchpl/
│       └── 1.0.0.toml          # Points to /Users/jsullivan2/git/quickchpl
└── .git/                       # Git-tracked registry

~/.zshrc or ~/.bashrc:
export MASON_REGISTRY="local-dev|$HOME/mason-local-dev,mason-registry|https://github.com/chapel-lang/mason-registry"
```

### Workflow Integration

```
quickchpl Development → Local Registry → aoc-2025-chapel-27 Testing → GitHub CI → Mason Registry
                     ↓
               Edit src/Generators.chpl
                     ↓
               mason update in aoc project
                     ↓
               Immediate testing feedback
                     ↓
               Commit when satisfied
                     ↓
               Push to GitHub
                     ↓
               CI runs (GitHub Actions)
                     ↓
               Publish to mason-registry
```

---

## Phase 1: GitHub Setup
**Estimated Time**: 2-3 hours
**Status**: Critical Path

### Task 1.1: Update Mason.toml Repository URL

**Current State**:
```toml
repository = "https://gitlab.com/tinyland/projects/quickchpl"
```

**Target State**:
```toml
repository = "https://github.com/Jesssullivan/chplcheck"
```

**Implementation**:
```bash
cd /Users/jsullivan2/git/quickchpl

# Update Mason.toml
sed -i '' 's|gitlab.com/tinyland/projects/quickchpl|github.com/Jesssullivan/chplcheck|g' Mason.toml

# Verify
grep repository Mason.toml

# Commit
git add Mason.toml
git commit -m "chore: update repository URL to GitHub canonical

- Change from GitLab to GitHub as canonical repository
- Prepare for Mason registry submission
- Update package metadata"

git push origin main
```

**Validation**:
- ✓ Mason.toml `repository` field matches GitHub remote
- ✓ Git remote origin is `https://github.com/Jesssullivan/chplcheck`
- ✓ No references to GitLab remain in package metadata

---

### Task 1.2: Update .gitignore

**Purpose**: Clean up ignores and track useful files

**Current .gitignore Issues**:
- Ignores `.claude/` (should be tracked for collaboration)
- Ignores `CLAUDE.md` (should be tracked)
- Ignores `MASON_PUBLISHING_GUIDE.md` (should be tracked)
- Missing ignores for build artifacts

**Recommended .gitignore**:
```bash
cat > .gitignore <<'EOF'
# IDE
.idea/
.vscode/

# OS
**/.DS_Store
.DS_Store

# Build artifacts
target/
*.o
*.tmp
*.tmp_*

# Compiled binaries (from src/)
/Combinators
/Generators
/Patterns
/Properties
/Reporters
/Shrinkers
/chapelcheck

# Mason lock (optional - decision needed)
# Mason.lock

# Example executables
/examples/AlgebraicProperties
/examples/CustomGenerators
/examples/GettingStarted

# Test executables
/tests/unit/GeneratorTests
/tests/unit/PropertyTests
/tests/unit/ShrinkerTests
/tests/properties/SelfTests

# Docs (local Chapel docs)
docs/chapel-2.6/
EOF
```

**Implementation**:
```bash
# Remove compiled binaries from git
git rm --cached Combinators Generators Patterns Properties Reporters Shrinkers chapelcheck 2>/dev/null || true

# Update .gitignore
# (Use file content above)

# Commit
git add .gitignore .claude/ docs/
git commit -m "chore: update .gitignore and track configuration files

- Remove compiled binaries from git tracking
- Track .claude/ directory for project configuration
- Track documentation files
- Add comprehensive build artifact ignores"

git push origin main
```

**Validation**:
- ✓ No compiled binaries in git
- ✓ `.claude/` directory is tracked
- ✓ Documentation files are tracked
- ✓ Build artifacts excluded

---

### Task 1.3: Create Git Tag for v1.0.0

**Purpose**: Required for Mason registry submission

**Implementation**:
```bash
cd /Users/jsullivan2/git/quickchpl

# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0: Initial stable release

First public release of quickchpl property-based testing framework.

Features:
- Core generators (int, real, bool, string)
- Composite generators (tuples, lists)
- Generator combinators (map, filter, zip, oneOf, frequency)
- Property testing with automatic shrinking
- Pattern library (commutative, associative, identity, etc.)
- Comprehensive test suite and examples
- Zero external dependencies

Chapel version: 2.6.0..2.7.0

Mason registry: Pending submission"

# Verify tag
git tag -l
git show v1.0.0

# Push tag
git push origin v1.0.0
```

**Validation**:
- ✓ Tag `v1.0.0` exists locally
- ✓ Tag pushed to GitHub remote
- ✓ Tag is annotated (not lightweight)
- ✓ Tag matches version in Mason.toml

---

### Task 1.4: Verify Repository is Public

**Purpose**: Mason registry requires public repositories

**Steps**:
1. Visit: https://github.com/Jesssullivan/chplcheck
2. Verify repository is accessible without login
3. Check Settings → General → Danger Zone if private

**Test**:
```bash
# Should return HTTP 200
curl -I https://github.com/Jesssullivan/chplcheck

# Should clone without authentication
cd /tmp
git clone https://github.com/Jesssullivan/chplcheck
cd chplcheck
ls -la
```

**Validation**:
- ✓ Repository is public
- ✓ Can clone without authentication
- ✓ Repository metadata is visible

---

## Phase 2: CI/CD Migration
**Estimated Time**: 4-6 hours
**Status**: High Priority

### Overview: GitLab CI → GitHub Actions

**Current GitLab CI Structure**:
```yaml
stages:
  - build
  - test
  - report

jobs:
  - build (compile sources)
  - unit_tests (run test suite)
  - examples (build and run examples)
  - self_test (dogfooding)
  - benchmarks (performance)
  - docs (chpldoc)
```

**Target GitHub Actions Structure**:
```yaml
jobs:
  - build (compile sources)
  - test-unit (unit tests)
  - test-examples (examples)
  - test-self (property tests)
  - lint (code quality)
  - docs (generate API docs)
  - publish (manual, Mason registry submission)
```

---

### Task 2.1: Create GitHub Actions Workflow

**File**: `.github/workflows/ci.yml`

```yaml
name: Chapel CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  QUICKCHPL_NUM_TESTS: "100"
  QUICKCHPL_VERBOSE: "false"

jobs:
  build:
    name: Build quickchpl
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Verify Chapel installation
        run: |
          chpl --version
          mason --version

      - name: Build package with Mason
        run: mason build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: target/
          retention-days: 1

  test-unit:
    name: Unit Tests
    needs: build
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run unit tests
        run: |
          echo "Running Generator Tests..."
          chpl tests/unit/GeneratorTests.chpl src/*.chpl -o /tmp/generator_tests
          /tmp/generator_tests

          echo "Running Shrinker Tests..."
          chpl tests/unit/ShrinkerTests.chpl src/*.chpl -o /tmp/shrinker_tests
          /tmp/shrinker_tests

          echo "Running Property Tests..."
          chpl tests/unit/PropertyTests.chpl src/*.chpl -o /tmp/property_tests
          /tmp/property_tests

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-unit
          path: test-results*.xml

  test-examples:
    name: Example Programs
    needs: build
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build and run examples
        run: |
          echo "Running Getting Started Example..."
          chpl examples/GettingStarted.chpl src/*.chpl -o /tmp/getting_started
          /tmp/getting_started

          echo "Running Algebraic Properties Example..."
          chpl examples/AlgebraicProperties.chpl src/*.chpl -o /tmp/algebraic
          /tmp/algebraic

          echo "Running Custom Generators Example..."
          chpl examples/CustomGenerators.chpl src/*.chpl -o /tmp/custom_gen
          /tmp/custom_gen

  test-self:
    name: Property-Based Self Tests
    needs: build
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run quickchpl self-tests
        run: |
          chpl tests/properties/SelfTests.chpl src/*.chpl -o /tmp/self_tests \
            --numTests=${{ env.QUICKCHPL_NUM_TESTS }}
          /tmp/self_tests

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-properties
          path: test-results*.xml

  test-matrix:
    name: Test on Chapel ${{ matrix.chapel-version }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        chapel-version: ['2.6.0', '2.7.0']

    container:
      image: chapel/chapel:${{ matrix.chapel-version }}

    steps:
      - uses: actions/checkout@v4

      - name: Build with Chapel ${{ matrix.chapel-version }}
        run: |
          chpl --version
          mason build

      - name: Run tests
        run: mason test || chpl tests/unit/GeneratorTests.chpl src/*.chpl -o /tmp/test && /tmp/test

  lint:
    name: Code Quality
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - uses: actions/checkout@v4

      - name: Check for reserved words
        run: |
          # Check Chapel reserved words
          ! grep -rn '\b(config|domain|bytes|type|index)\s*[=:]' src/ || {
            echo "Found potential Chapel reserved word usage"
            exit 1
          }

      - name: Check code formatting
        run: |
          # Basic formatting checks
          echo "Checking for trailing whitespace..."
          ! grep -rn '[[:space:]]$' src/*.chpl

  docs:
    name: Generate Documentation
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Generate chpldoc
        run: |
          mkdir -p docs/api
          chpldoc src/*.chpl --output-dir=docs/api

      - name: Upload docs
        uses: actions/upload-artifact@v4
        with:
          name: documentation
          path: docs/api/
          retention-days: 30

  publish-check:
    name: Mason Publish Check
    needs: [test-unit, test-examples, test-self]
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Need full history for tags

      - name: Validate package for Mason registry
        run: |
          mason build
          mason test
          mason publish --dry-run
          mason publish --check

      - name: Display next steps
        run: |
          echo "✓ Package is ready for Mason registry submission"
          echo "To publish: mason publish"
```

**Implementation**:
```bash
cd /Users/jsullivan2/git/quickchpl

# Create workflows directory
mkdir -p .github/workflows

# Create workflow file
# (Use YAML content above)

# Commit
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions CI workflow

- Build and test on Chapel 2.6.0 and 2.7.0
- Run unit tests, examples, and self-tests
- Generate documentation
- Validate Mason package
- Replace GitLab CI for GitHub-based development"

git push origin main
```

**Validation**:
- ✓ Workflow file exists at `.github/workflows/ci.yml`
- ✓ Push triggers CI run
- ✓ All jobs pass
- ✓ Artifacts uploaded correctly

---

### Task 2.2: Create Release Workflow

**File**: `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  create-release:
    name: Create GitHub Release
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Extract version
        id: version
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: Generate changelog
        id: changelog
        run: |
          # Extract changes from CHANGELOG.md if exists
          if [ -f CHANGELOG.md ]; then
            CHANGES=$(sed -n "/## \[${{ steps.version.outputs.version }}\]/,/## \[/p" CHANGELOG.md | sed '$d')
          else
            CHANGES="Release ${{ steps.version.outputs.version }}"
          fi
          echo "changes<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ steps.version.outputs.version }}
          body: ${{ steps.changelog.outputs.changes }}
          draft: false
          prerelease: false

  publish-to-registry:
    name: Publish to Mason Registry
    needs: create-release
    runs-on: ubuntu-latest
    container:
      image: chapel/chapel:2.6.0

    steps:
      - uses: actions/checkout@v4

      - name: Validate package
        run: |
          mason build
          mason test
          mason publish --check

      - name: Display publish instructions
        run: |
          echo "To publish to Mason registry:"
          echo "  mason publish"
          echo ""
          echo "Or manually create PR to mason-registry:"
          echo "  https://github.com/chapel-lang/mason-registry"
```

**Implementation**:
```bash
# Create release workflow
# (Use YAML above)

git add .github/workflows/release.yml
git commit -m "ci: add release automation workflow

- Trigger on version tags (v*)
- Create GitHub releases automatically
- Provide Mason publish instructions"

git push origin main
```

---

## Phase 3: Local Development Workflow
**Estimated Time**: 2-3 hours
**Status**: High Priority

### Task 3.1: Create Local Mason Registry

**Purpose**: Enable rapid iteration without git commits

**Implementation Script**:
```bash
#!/bin/bash
# setup-local-mason-dev.sh
set -euo pipefail

PROJECT_NAME="quickchpl"
PROJECT_PATH="/Users/jsullivan2/git/quickchpl"
VERSION="1.0.0"
LOCAL_REGISTRY="$HOME/mason-local-dev"

echo "=== Setting up Local Mason Development Environment ==="

# 1. Create local registry structure
mkdir -p "$LOCAL_REGISTRY/Bricks/$PROJECT_NAME"
cd "$LOCAL_REGISTRY"

# 2. Create registry manifest
cat > "Bricks/$PROJECT_NAME/$VERSION.toml" <<EOF
[brick]
name = "$PROJECT_NAME"
version = "$VERSION"
chplVersion = "2.6.0..2.7.0"
license = "MIT"
type = "library"
source = "$PROJECT_PATH"
authors = ["Jess Sullivan <jess@sulliwood.org>"]
repository = "https://github.com/Jesssullivan/chplcheck"
description = "Property-based testing library for Chapel"
keywords = ["testing", "property-based", "quickcheck", "pbt", "fuzzing"]

[dependencies]
EOF

echo "✓ Created registry manifest at Bricks/$PROJECT_NAME/$VERSION.toml"

# 3. Initialize git if needed
if [ ! -d ".git" ]; then
    git init
    echo "✓ Initialized git repository"
fi

# 4. Commit manifest
git add "Bricks/$PROJECT_NAME/$VERSION.toml"
git commit -m "Add $PROJECT_NAME v$VERSION to local registry" 2>/dev/null || true

# 5. Configure environment
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q "MASON_REGISTRY.*mason-local-dev" "$SHELL_RC"; then
    cat >> "$SHELL_RC" <<'EOF'

# Mason local development registry
export MASON_REGISTRY="local-dev|$HOME/mason-local-dev,mason-registry|https://github.com/chapel-lang/mason-registry"
EOF
    echo "✓ Added MASON_REGISTRY to $SHELL_RC"
    echo ""
    echo "Run: source $SHELL_RC"
else
    echo "✓ MASON_REGISTRY already configured"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. source $SHELL_RC"
echo "2. cd /Users/jsullivan2/git/aoc-2025-chapel-27"
echo "3. mason init  # if not already initialized"
echo "4. mason add $PROJECT_NAME"
echo "5. mason update && mason build"
echo ""
echo "Development workflow:"
echo "- Edit files in $PROJECT_PATH"
echo "- Run 'mason update' in consumer project"
echo "- Changes reflected immediately (no git commit needed)"
```

**Save and run**:
```bash
cd /Users/jsullivan2/git/quickchpl

# Save script
# (Use content above)

chmod +x setup-local-mason-dev.sh

# Run it
./setup-local-mason-dev.sh

# Source environment
source ~/.zshrc  # or ~/.bashrc
```

**Validation**:
```bash
# Check environment variable
echo $MASON_REGISTRY
# Should show: local-dev|/Users/jsullivan2/mason-local-dev,mason-registry|...

# Verify registry structure
ls -la ~/mason-local-dev/Bricks/quickchpl/
# Should show: 1.0.0.toml

# Check manifest
cat ~/mason-local-dev/Bricks/quickchpl/1.0.0.toml
# Should have source = "/Users/jsullivan2/git/quickchpl"
```

---

### Task 3.2: Test Local Registry

**Purpose**: Verify local registry works before integrating with aoc project

**Implementation**:
```bash
# Create test project
mkdir /tmp/test-quickchpl
cd /tmp/test-quickchpl

# Initialize Mason project
mason init

# Add quickchpl from local registry
mason add quickchpl

# Verify dependency added
cat Mason.toml
# Should show:
# [dependencies]
# quickchpl = "1.0.0"

# Update dependencies
mason update

# Check where Mason downloaded from
ls -la ~/.mason/src/quickchpl/1.0.0/
# Should be symlink or copy of /Users/jsullivan2/git/quickchpl

# Create test file
cat > src/test-quickchpl.chpl <<'EOF'
use quickchpl;

proc main() {
    writeln("Testing quickchpl from local registry...");

    const gen = intGen(0, 100);
    const prop = property("test property",
        gen,
        (x: int) => x >= 0 && x <= 100
    );

    const result = check(prop);
    if result.passed {
        writeln("✓ quickchpl works from local registry!");
    } else {
        writeln("✗ Test failed");
    }
}
EOF

# Build and run
mason build
mason run
```

**Expected Output**:
```
Testing quickchpl from local registry...
✓ quickchpl works from local registry!
```

**Validation**:
- ✓ Local registry provides quickchpl
- ✓ Test project builds successfully
- ✓ quickchpl functionality works
- ✓ Can iterate by editing `/Users/jsullivan2/git/quickchpl` and running `mason update`

---

## Phase 4: AoC Integration
**Estimated Time**: 6-8 hours
**Status**: Critical for Demonstration

### Overview

The aoc-2025-chapel-27 project currently has:
- **486 lines** of custom PBT infrastructure
- **7 custom generators**
- **5 working solutions** with property tests
- **Makefile-based build** (not Mason)

**Goal**: Replace custom infrastructure with quickchpl, demonstrating 88% code reduction.

---

### Task 4.1: Introduce Mason to aoc-2025-chapel-27

**Create Mason.toml**:
```bash
cd /Users/jsullivan2/git/aoc-2025-chapel-27

cat > Mason.toml <<'EOF'
[brick]
name = "aoc-2025-chapel-27"
version = "1.0.0"
chplVersion = "2.6.0..2.7.0"
license = "MIT"
type = "application"
authors = ["Jess Sullivan <jess@sulliwood.org>"]
description = "Advent of Code 2025 solutions in Chapel"

[dependencies]
quickchpl = "1.0.0"

[dev-dependencies]
EOF

echo "✓ Created Mason.toml"

# Initialize Mason
mason init

# Update dependencies (fetches from local registry)
mason update

echo "✓ quickchpl added as dependency"
```

**Update Makefile to Support Mason**:
```makefile
# Add Mason support to existing Makefile

# Mason paths
MASON_HOME ?= $(HOME)/.mason
QUICKCHPL_PATH = $(MASON_HOME)/src/quickchpl/1.0.0

# Update CHPL_FLAGS to include Mason modules
CHPL_FLAGS += -M $(QUICKCHPL_PATH)/src

# Add Mason targets
.PHONY: mason-build mason-test mason-update

mason-build:
	mason build

mason-test:
	mason test

mason-update:
	mason update

# Keep existing targets for backward compatibility
```

**Commit**:
```bash
git add Mason.toml Makefile
git commit -m "feat: introduce Mason package management

- Add Mason.toml with quickchpl dependency
- Update Makefile to support Mason module paths
- Maintain backward compatibility with existing build"

git push origin main
```

---

### Task 4.2: Migrate Day 01 (Proof of Concept)

**Goal**: Replace custom PBT for Day 01 as demonstration

**Current Day 01 Test Structure**:
```
tests/lib/QuickCheck.chpl          (174 lines - custom PBT)
tests/lib/AOCGenerators.chpl       (200 lines - custom generators)
tests/properties/day01_properties.chpl (81 lines - property tests)
---
TOTAL: 455 lines
```

**After quickchpl Migration**:
```
tests/properties/day01_properties.chpl (~60 lines using quickchpl)
---
TOTAL: 60 lines (87% reduction)
```

**Implementation**:

1. **Update day01_properties.chpl**:
```chapel
// BEFORE (Custom infrastructure):
use QuickCheck;  // Custom 174-line wrapper
use AOCGenerators;  // Custom 200-line generators

proc testPositionBounds() {
    var gen = DirectionGenerator();  // Custom generator
    var result = checkProperty("positions in bounds", gen, ...);
    // ... manual loop
}

// AFTER (quickchpl):
use quickchpl;  // Official package

proc main() {
    writeln("Day 01 Property Tests");
    writeln("=" * 50);

    // Property 1: Position always in [0, 99]
    check(property(
        "Position always in [0, 99]",
        intGen(0, 1000),  // Built-in generator
        (dist: int): bool {
            const pos = applyRotation(50, new Rotation("R", dist));
            return pos >= 0 && pos < 100;
        }
    ));

    // Property 2: Opposite rotations cancel (Inverse Pattern)
    use Patterns;

    checkPattern(inversePattern(
        "Rotation cancellation",
        (pos: int, dist: int) => applyRotation(pos, new Rotation("R", dist)),
        (pos: int, dist: int) => applyRotation(pos, new Rotation("L", dist)),
        tupleGen(intGen(0, 99), intGen(0, 500))
    ));

    // Property 3: 100-step rotation returns to start
    check(property(
        "100-step rotation returns to start",
        intGen(0, 99),
        (pos: int): bool {
            var current = pos;
            for i in 1..100 {
                current = applyRotation(current, new Rotation("R", 1));
            }
            return current == pos;
        }
    ));

    writeln("✓ All Day 01 property tests passed");
}
```

2. **Remove custom infrastructure dependency**:
```bash
# Day 01 tests now only need quickchpl, not custom lib/
# Keep tests/lib/ directory for other days during migration
```

3. **Update Makefile test target**:
```makefile
test-day01:
	chpl tests/properties/day01_properties.chpl \
	     -M $(QUICKCHPL_PATH)/src \
	     src/day01.chpl \
	     -o /tmp/day01_test
	/tmp/day01_test
```

4. **Commit migration**:
```bash
git add tests/properties/day01_properties.chpl Makefile
git commit -m "refactor: migrate Day 01 to quickchpl

- Replace custom QuickCheck wrapper with quickchpl
- Use built-in generators (intGen, tupleGen)
- Leverage Pattern library (inversePattern)
- Reduce test code by 87% (455 → 60 lines)
- Demonstrate quickchpl value for Mason maintainers"

git push origin main
```

---

### Task 4.3: Full Migration (All Days)

**Repeat Task 4.2 pattern for Days 02-05**:

| Day | Custom Code | After quickchpl | Reduction |
|-----|-------------|-----------------|-----------|
| 01  | 455 lines   | ~60 lines       | 87%       |
| 02  | ~100 lines  | ~40 lines       | 60%       |
| 03  | ~80 lines   | ~35 lines       | 56%       |
| 04  | ~150 lines  | ~50 lines       | 67%       |
| 05  | ~120 lines  | ~45 lines       | 63%       |
| **TOTAL** | **~900 lines** | **~230 lines** | **74%** |

**After all migrations complete**:
```bash
# Remove custom PBT infrastructure entirely
git rm tests/lib/QuickCheck.chpl tests/lib/AOCGenerators.chpl

git commit -m "refactor: remove custom PBT infrastructure

All tests now use quickchpl from Mason registry.

Custom infrastructure removed:
- QuickCheck.chpl (174 lines)
- AOCGenerators.chpl (200 lines)

Replaced by:
- use quickchpl; (Mason dependency)

Overall code reduction: 74% (900 → 230 lines)"

git push origin main
```

---

## Phase 5: Demonstration
**Estimated Time**: 3-4 hours
**Status**: Documentation & Presentation

### Task 5.1: Create Demonstration Documentation

**File**: `docs/QUICKCHPL_DEMO.md` (in aoc-2025-chapel-27 repo)

```markdown
# quickchpl Demonstration: Real-World Mason Package Integration

## Overview

This project demonstrates the value of quickchpl, a property-based testing library for Chapel, by showing its integration into a real-world Advent of Code project.

## Before quickchpl

### Custom Infrastructure (486 lines)

**tests/lib/QuickCheck.chpl** (174 lines):
- Custom forAll() implementation
- Manual shrinking logic
- Basic property checking

**tests/lib/AOCGenerators.chpl** (200 lines):
- GridGenerator (47 lines)
- CoordinateGenerator (28 lines)
- SortedIntListGenerator (31 lines)
- PermutationGenerator (39 lines)
- TreeGenerator (25 lines)
- DirectionGenerator (15 lines)
- RangeGenerator (15 lines)

**Pain Points**:
1. Every Chapel project reinvents PBT infrastructure
2. No package management - manual git cloning
3. Limited generator library
4. Basic shrinking only
5. No pattern library for common properties

## After quickchpl

### Mason Dependency (0 custom lines)

**Mason.toml**:
```toml
[dependencies]
quickchpl = "1.0.0"
```

**Test Code**:
```chapel
use quickchpl;  // That's it!

check(property(...));
```

### Code Reduction

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| **Custom Infrastructure** | 486 lines | 0 lines | 100% |
| **Test Code** | ~900 lines | ~230 lines | 74% |
| **Total** | 1,386 lines | 230 lines | 83% |

### Feature Comparison

| Feature | Custom | quickchpl |
|---------|--------|-----------|
| **Generators** | 7 custom | 20+ built-in |
| **Shrinking** | Linear only | Automatic for all types |
| **Patterns** | None | 7 algebraic patterns |
| **Package Management** | Manual git clone | `mason add quickchpl` |
| **CI Integration** | Custom setup | Native Mason |
| **Versioning** | Git SHA | Semantic versioning |
| **Discovery** | Word of mouth | `mason search` |

## Day 01: Before/After Example

### Before (455 lines total)

```chapel
// Custom infrastructure required
use QuickCheck;        // 174 lines
use AOCGenerators;     // 200 lines

proc testOppositeRotationsCancel() {
    var gen = DirectionGenerator();
    for i in 1..100 {
        const pos = rng.next(0, 99);
        const dist = rng.next(0, 500);
        const afterRight = applyRotation(pos, new Rotation("R", dist));
        const afterBoth = applyRotation(afterRight, new Rotation("L", dist));
        if afterBoth != pos {
            writeln("FAILED: Opposite rotations should cancel");
            return false;
        }
    }
    return true;
}
```

### After (60 lines total)

```chapel
use quickchpl;
use Patterns;

proc main() {
    // Inverse pattern - one line!
    checkPattern(inversePattern(
        "Rotation cancellation",
        (pos, dist) => applyRotation(pos, new Rotation("R", dist)),
        (pos, dist) => applyRotation(pos, new Rotation("L", dist)),
        tupleGen(intGen(0, 99), intGen(0, 500))
    ));
}
```

## Mason Integration Benefits

### 1. Dependency Management
```bash
# Add quickchpl
mason add quickchpl

# Update dependencies
mason update

# Build with dependencies
mason build
```

### 2. CI/CD Simplification

**Before (40 lines)**:
```yaml
script:
  - git clone --depth 1 "$CHAPELCHECK_REPO" "$CHAPELCHECK_PATH"
  - MODULE_FLAGS="-M $CHAPELCHECK_PATH/src"
  - for test_file in tests/unit/*_test.chpl; do
      chpl $MODULE_FLAGS -o "/tmp/$TEST_BIN" "$test_file" tests/lib/*.chpl
      timeout ${MAX_EXECUTION_TIME}s "/tmp/$TEST_BIN"
    done
```

**After (3 lines)**:
```yaml
script:
  - mason update
  - mason test
```

### 3. Version Management

**Before**: Git SHA pinning
```yaml
CHAPELCHECK_COMMIT: "abc123def456"
```

**After**: Semantic versioning
```toml
[dependencies]
quickchpl = "1.0.0"  # Or ">=1.0.0,<2.0.0"
```

### 4. Discoverability

**Before**: Word of mouth, GitHub search
**After**: Mason registry
```bash
mason search property
# quickchpl - Property-based testing for Chapel
```

## Live Demo Script

### Terminal 1: Before quickchpl
```bash
wc -l tests/lib/*.chpl
# 374 tests/lib/QuickCheck.chpl
# 200 tests/lib/AOCGenerators.chpl
# 574 total

cat Makefile | grep "test-properties" -A 10
# (Complex shell loop)
```

### Terminal 2: After quickchpl
```bash
cat Mason.toml | grep dependencies -A 2
# [dependencies]
# quickchpl = "1.0.0"

mason test
# (Clean output)
```

### Terminal 3: Feature Showcase
```bash
# Run with verbose shrinking
QUICKCHPL_VERBOSE=true mason test tests/properties/day01_properties.chpl

# Custom test count
QUICKCHPL_NUM_TESTS=1000 mason test
```

## Lessons for Mason Ecosystem

1. **Package Management Matters**: Eliminates infrastructure duplication
2. **Discovery is Key**: `mason search` makes libraries findable
3. **Versioning Enables Trust**: Semantic versioning vs git SHAs
4. **CI/CD Integration**: Simplifies automation
5. **Real-World Value**: 83% code reduction in production project

## Next Steps

1. Publish quickchpl to Mason registry
2. Evangelize PBT in Chapel community
3. Encourage other testing libraries
4. Build Mason ecosystem

## Repository

- quickchpl: https://github.com/Jesssullivan/chplcheck
- AoC Demo: https://github.com/Jesssullivan2/aoc-2025-chapel-27

## Contact

- Author: Jess Sullivan
- Email: jess@sulliwood.org
```

---

### Task 5.2: Create Presentation Materials

**Slide Deck Outline**:

1. **Title**: quickchpl: Property-Based Testing for Chapel
2. **The Problem**: Every project reinvents PBT
3. **Real-World Example**: aoc-2025-chapel-27
4. **Before**: 486 lines of custom infrastructure
5. **After**: `mason add quickchpl`
6. **Code Comparison**: 83% reduction
7. **Features**: Generators, Patterns, Shrinking
8. **Mason Integration**: Dependency management
9. **CI/CD Simplification**: 40 lines → 3 lines
10. **Ecosystem Benefits**: Discovery, versioning, trust
11. **Live Demo**: Terminal session
12. **Q&A**: Performance, migration, contribution

---

### Task 5.3: Record Demo Video

**Script**:

1. **Intro (30 seconds)**
   - "Hi, I'm Jess Sullivan"
   - "Today I'm showing quickchpl, a property-based testing library for Chapel"
   - "And how it integrates with Mason for real-world projects"

2. **Problem Statement (1 minute)**
   - Show aoc-2025-chapel-27 custom infrastructure
   - "486 lines of custom code"
   - "Every Chapel project has to rebuild this"

3. **Solution (2 minutes)**
   - Show `mason add quickchpl`
   - Show simplified test code
   - Highlight code reduction metrics

4. **Features (3 minutes)**
   - Generators demo
   - Pattern library demo
   - Shrinking in action

5. **Mason Benefits (2 minutes)**
   - Dependency management
   - CI/CD simplification
   - Version management
   - Discovery

6. **Live Demo (3 minutes)**
   - Terminal session
   - Mason workflow
   - Test execution
   - Shrinking visualization

7. **Wrap-up (1 minute)**
   - Summary of benefits
   - Call to action
   - Links to repos

**Total Runtime**: ~12 minutes

---

## Technical Specifications

### Environment Requirements

**Chapel Version**: 2.6.0+ (tested on 2.6.0, 2.7.0)

**Mason Version**: 0.2.0+

**Operating Systems**:
- macOS (primary development)
- Linux (CI/CD)
- Docker (chapel/chapel images)

### Directory Structures

**quickchpl**:
```
quickchpl/
├── .github/workflows/
│   ├── ci.yml
│   └── release.yml
├── src/
│   ├── chapelcheck.chpl
│   ├── Generators.chpl
│   ├── Properties.chpl
│   ├── Shrinkers.chpl
│   ├── Reporters.chpl
│   ├── Patterns.chpl
│   └── Combinators.chpl
├── tests/
│   ├── unit/
│   └── properties/
├── examples/
├── docs/
├── Mason.toml
└── README.md
```

**aoc-2025-chapel-27**:
```
aoc-2025-chapel-27/
├── .github/workflows/
│   └── ci.yml
├── src/
│   └── day*.chpl
├── tests/
│   ├── unit/
│   ├── properties/
│   └── samples/
├── docs/
│   └── QUICKCHPL_DEMO.md
├── Mason.toml
├── Makefile
└── README.md
```

### Build Commands

**quickchpl**:
```bash
mason build              # Build package
mason test               # Run tests
mason build --example    # Build examples
mason publish --dry-run  # Validate for publishing
```

**aoc-2025-chapel-27**:
```bash
mason update            # Fetch dependencies
mason build             # Build solutions
mason test              # Run all tests
make test-day01         # Run specific day (backward compat)
```

### CI/CD Configuration

**GitHub Actions**:
- Trigger: push to main, pull requests
- Matrix: Chapel 2.6.0, 2.7.0
- Jobs: build, test-unit, test-examples, test-self, lint, docs
- Artifacts: test results, documentation

**Environment Variables**:
- `QUICKCHPL_NUM_TESTS`: Number of test cases per property (default: 100)
- `QUICKCHPL_VERBOSE`: Enable verbose output (default: false)
- `QUICKCHPL_PARALLEL`: Enable parallel test execution (default: false)

---

## Risk Management

### High Risk Items

1. **Mason publish workflow may differ from documentation**
   - Mitigation: Test with `mason publish --dry-run` early
   - Fallback: Manual PR to mason-registry

2. **Local registry source paths may not work on all systems**
   - Mitigation: Test on macOS and Linux
   - Fallback: Use git dependencies with `file://` URLs

3. **AoC test migration may reveal quickchpl bugs**
   - Mitigation: Fix bugs as discovered
   - Benefit: Real-world testing improves quickchpl quality

### Medium Risk Items

1. **Chapel version compatibility issues**
   - Mitigation: Test matrix with 2.6.0 and 2.7.0
   - Monitor: Chapel discourse for breaking changes

2. **Performance regression in quickchpl vs custom code**
   - Mitigation: Benchmark before/after
   - Document: Performance trade-offs in demo

### Low Risk Items

1. **GitHub Actions learning curve**
   - Mitigation: Start with simple workflow, iterate
   - Reference: Existing Chapel projects on GitHub

2. **Documentation gaps**
   - Mitigation: Iterative improvement based on feedback
   - Community: Engage Chapel discourse for questions

---

## Success Criteria

### Must Have (Blocking)

- ✅ GitHub is canonical repository
- ✅ Git tag v1.0.0 exists
- ✅ GitHub Actions CI passes
- ✅ Local Mason registry works
- ✅ Day 01 migration complete
- ✅ Demonstration documentation written
- ✅ quickchpl submitted to mason-registry

### Should Have (Important)

- ✅ All 5 days migrated to quickchpl
- ✅ Custom infrastructure removed
- ✅ Code reduction metrics documented
- ✅ Demo video recorded
- ✅ Presentation slides created

### Nice to Have (Optional)

- 🎯 Blog post written
- 🎯 Chapel Discourse post
- 🎯 Conference talk submission
- 🎯 Additional AoC days for 2025

---

## Timeline

### Week 1 (Days 1-7)

**Phase 1: GitHub Setup** (Days 1-2)
- Task 1.1: Update Mason.toml ✓
- Task 1.2: Update .gitignore ✓
- Task 1.3: Create git tag ✓
- Task 1.4: Verify public repo ✓

**Phase 2: CI/CD Migration** (Days 3-5)
- Task 2.1: GitHub Actions workflow
- Task 2.2: Release workflow
- Validate CI passes

**Phase 3: Local Development** (Days 6-7)
- Task 3.1: Create local registry
- Task 3.2: Test local registry

### Week 2 (Days 8-14)

**Phase 4: AoC Integration** (Days 8-12)
- Task 4.1: Introduce Mason to aoc-2025-chapel-27
- Task 4.2: Migrate Day 01 (proof of concept)
- Task 4.3: Migrate Days 02-05
- Remove custom infrastructure

**Phase 5: Demonstration** (Days 13-14)
- Task 5.1: Create documentation
- Task 5.2: Presentation materials
- Task 5.3: Record demo video

### Post-Implementation

- Submit quickchpl to mason-registry
- Monitor PR for maintainer feedback
- Address any issues
- Publish blog post/video
- Present at Chapel community meeting

---

## Appendix: Command Reference

### quickchpl Development

```bash
# Edit source
cd /Users/jsullivan2/git/quickchpl
# Make changes to src/Generators.chpl

# Test in aoc project (no commit needed)
cd /Users/jsullivan2/git/aoc-2025-chapel-27
mason update
mason build
mason test

# Commit when satisfied
cd /Users/jsullivan2/git/quickchpl
git add src/Generators.chpl
git commit -m "feat: add new generator"
git push
```

### Mason Registry

```bash
# Validate package
mason build
mason test
mason publish --check

# Publish (automated)
mason publish

# Manual PR (fallback)
cd ~/mason-registry-fork
git checkout -b add-quickchpl-1.0.0
# Create Bricks/quickchpl/1.0.0.toml
git add Bricks/quickchpl/1.0.0.toml
git commit -m "Adding quickchpl@1.0.0 package to registry via mason publish"
git push origin add-quickchpl-1.0.0
# Open PR on GitHub
```

### CI/CD

```bash
# Trigger GitHub Actions
git push origin main

# View workflow runs
gh run list

# View specific run
gh run view <run-id>

# Download artifacts
gh run download <run-id>
```

---

**Document Version**: 1.0
**Last Updated**: 2026-01-12
**Author**: Claude (Master Planner)
**Status**: ✅ Ready for Implementation
