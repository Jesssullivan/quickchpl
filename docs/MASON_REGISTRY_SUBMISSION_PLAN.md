# Mason Registry Submission Plan for quickchpl

**Status**: Ready for Implementation
**Target Version**: 1.0.0
**Target Registry**: https://github.com/chapel-lang/mason-registry
**Estimated Completion**: 5-8 tasks

---

## Executive Summary

This plan outlines the steps to successfully submit the `quickchpl` property-based testing library to the Chapel Mason Registry. The package is well-structured and nearly ready for publication, requiring only configuration updates, validation testing, and formal submission.

---

## Current State Analysis

### ✅ Strengths

1. **Complete Package Structure**
   - ✅ Main module: `src/chapelcheck.chpl` (re-exports 6 submodules)
   - ✅ 6 well-organized modules: Generators, Properties, Shrinkers, Reporters, Patterns, Combinators
   - ✅ Comprehensive test suite: 3 unit tests + 1 property test (dogfooding)
   - ✅ 3 example programs demonstrating real usage
   - ✅ Excellent README.md with extensive documentation
   - ✅ MIT License file
   - ✅ Zero dependencies (excellent for adoption)

2. **Mason Configuration**
   - ✅ Mason.toml exists with all required fields
   - ✅ Version 1.0.0 (confident initial release)
   - ✅ Chapel version range: 2.6.0..2.7.0
   - ✅ Descriptive keywords for discoverability
   - ✅ Author information

3. **Code Quality**
   - ✅ Modern Chapel idioms (records, generics, iterators)
   - ✅ Config constants for runtime configuration
   - ✅ Clear module boundaries and public API
   - ✅ Chapel doc comments throughout

### ❌ Critical Issues

1. **Repository Configuration**
   - ❌ **CRITICAL**: No git tag for v1.0.0 (required for Mason registry)
   - ❌ **CRITICAL**: Repository URL mismatch:
     - Mason.toml: `https://gitlab.com/tinyland/projects/quickchpl`
     - Git remote: `https://github.com/Jesssullivan/chplcheck`
   - Decision needed: Which repository is canonical?

2. **Build Artifacts**
   - ❌ Compiled binaries in root directory (Combinators, Generators, etc.)
   - ❌ These should be in .gitignore and removed from git

3. **Configuration Files**
   - ⚠️ .gitignore currently ignores:
     - `.claude` directory (now exists)
     - `CLAUDE.md` (now exists)
     - `MASON_PUBLISHING_GUIDE.md` (now exists)
   - These should NOT be ignored (decision needed)

4. **Validation**
   - ⚠️ Need to verify: `mason build` succeeds
   - ⚠️ Need to verify: `mason test` passes all tests
   - ⚠️ Need to verify: `mason build --example` succeeds
   - ⚠️ Need to verify: Examples run successfully

### ⚠️ Recommendations

1. **Version Strategy**
   - Current: 1.0.0 (bold choice for first release)
   - Alternative: Consider 0.1.0 for initial registry submission
   - Reason: Semantic versioning conventions suggest 1.0.0 signals stable, production-ready API
   - Decision needed: Keep 1.0.0 or start with 0.1.0?

2. **Package Name**
   - Current: `quickchpl`
   - Alternative: Consider `ChapelCheck` or `QuickChpl` (consistent with QuickCheck heritage)
   - Registry uses first-come-first-served namespace
   - Current name is fine if user prefers it

---

## Implementation Plan

### Phase 1: Repository & Configuration Cleanup

**Goal**: Resolve repository conflicts and clean up build artifacts

#### Task 1.1: Resolve Repository URL Conflict

**Issue**: Mason.toml references GitLab, but git remote is GitHub

**Options**:
- **Option A**: Use GitHub as canonical (current remote)
  - Update Mason.toml `repository` field to `https://github.com/Jesssullivan/chplcheck`
  - Simpler since it's already the origin
  - GitHub is more common for Chapel packages

- **Option B**: Use GitLab as canonical
  - Update git remote to GitLab
  - Push repository to GitLab
  - More work but matches current Mason.toml

**Recommendation**: **Option A** (GitHub) - less work, more conventional

**Implementation**:
```bash
# Option A: Update Mason.toml
Edit Mason.toml:
  repository = "https://github.com/Jesssullivan/chplcheck"
```

**Validation**:
```bash
git remote -v  # Verify GitHub URL
grep repository Mason.toml  # Verify Mason.toml updated
```

---

#### Task 1.2: Update .gitignore

**Issue**: Current .gitignore is minimal and ignores useful files

**Current .gitignore**:
```
.gitignore
.idea/
**/.DS_Store
.claude
CLAUDE.md
MASON_PUBLISHING_GUIDE.md
```

**Recommended .gitignore**:
```
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

# Mason (optional - some keep this)
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
```

**Implementation**:
```bash
# Update .gitignore with recommended patterns
# Remove .claude, CLAUDE.md, MASON_PUBLISHING_GUIDE.md from ignores
```

**Validation**:
```bash
git status  # Should show .claude/, docs/ as untracked or modified
```

---

#### Task 1.3: Remove Compiled Binaries from Git

**Issue**: Root directory contains compiled binaries that should not be tracked

**Binaries to Remove**:
- `/Combinators`
- `/Generators`
- `/Patterns`
- `/Properties`
- `/Reporters`
- `/Shrinkers`
- `/chapelcheck`

**Implementation**:
```bash
# Remove from git but keep in .gitignore
git rm --cached Combinators Generators Patterns Properties Reporters Shrinkers chapelcheck

# Commit the removal
git add .gitignore
git commit -m "chore: remove compiled binaries from git tracking

- Remove build artifacts from repository
- Update .gitignore to exclude build outputs
- Prepare repository for Mason registry submission"
```

**Validation**:
```bash
git status  # Should show clean working directory
ls -la     # Binaries still exist locally but not tracked
```

---

### Phase 2: Validation & Testing

**Goal**: Ensure package builds, tests pass, and examples run

#### Task 2.1: Validate Mason Build

**Purpose**: Verify package compiles cleanly

**Implementation**:
```bash
# Clean any existing builds
rm -rf target/

# Build the package
mason build

# Check for errors
echo $?  # Should be 0
```

**Expected Output**:
```
Updating dependencies...
Building quickchpl...
Build complete.
```

**Failure Handling**:
- If build fails, examine compiler errors
- Check Chapel version compatibility
- Verify module dependencies are correct
- Fix issues before proceeding

---

#### Task 2.2: Run Test Suite

**Purpose**: Ensure all tests pass

**Implementation**:
```bash
# Run all tests
mason test

# Run specific test suites
mason test tests/unit/GeneratorTests.chpl
mason test tests/unit/PropertyTests.chpl
mason test tests/unit/ShrinkerTests.chpl
mason test tests/properties/SelfTests.chpl
```

**Expected Output**:
```
Running tests...
tests/unit/GeneratorTests.chpl: PASSED
tests/unit/PropertyTests.chpl: PASSED
tests/unit/ShrinkerTests.chpl: PASSED
tests/properties/SelfTests.chpl: PASSED
All tests passed.
```

**Failure Handling**:
- If tests fail, debug and fix issues
- Update tests if API has changed
- Ensure property tests demonstrate framework capabilities
- Fix before proceeding

---

#### Task 2.3: Validate Examples

**Purpose**: Ensure examples build and run successfully

**Implementation**:
```bash
# Build all examples
mason build --example

# Run each example
mason run --example GettingStarted
mason run --example AlgebraicProperties
mason run --example CustomGenerators
```

**Expected Output**:
```
quickchpl Getting Started Example
==================================================

Example 1: Commutativity of addition
✓ addition is commutative passed 100 tests

...
```

**Failure Handling**:
- If examples fail to build, check module imports
- If examples fail at runtime, debug issues
- Examples demonstrate real usage - critical for adoption

---

#### Task 2.4: Run Pre-Publish Checklist

**Purpose**: Comprehensive validation before submission

**Implementation**:
```bash
# Run the pre-publish helper script
./.claude/helpers/pre-publish-checklist.sh
```

**Checks Performed**:
1. ✅ Git working directory is clean
2. ✅ Mason.toml exists
3. ✅ Version tag exists (will fail initially - Task 3.1 will fix)
4. ✅ Git remote configured
5. ✅ Package builds successfully
6. ✅ Tests pass
7. ✅ Examples build
8. ✅ LICENSE file exists
9. ✅ README.md exists
10. ✅ `mason publish --dry-run` succeeds

**Expected Output**:
```
🔍 ChapelCheck Pre-Publish Checklist
=====================================

✅ Working directory is clean
✅ Mason.toml exists
❌ Git tag v1.0.0 not found  # Will fix in Task 3.1
✅ Remote origin: https://github.com/Jesssullivan/chplcheck
✅ Build successful
✅ Tests passed
✅ Examples built successfully
✅ LICENSE file exists
✅ README.md exists
✅ Publish dry-run successful

🎉 Most checks passed! (Missing git tag - see Task 3.1)
```

---

### Phase 3: Git Tagging & Version Management

**Goal**: Create proper git tags for Mason registry submission

#### Task 3.1: Create Version Tag

**Purpose**: Mason registry requires git tags matching version numbers

**Implementation**:
```bash
# Verify current version in Mason.toml
grep "^version" Mason.toml
# Output: version = "1.0.0"

# Create annotated git tag
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

Chapel version: 2.6.0..2.7.0"

# Verify tag created
git tag -l
# Output: v1.0.0

# View tag details
git show v1.0.0

# Push tag to remote
git push origin v1.0.0
```

**Validation**:
```bash
# Verify tag exists locally
git tag | grep "^v1.0.0$"

# Verify tag pushed to remote
git ls-remote --tags origin | grep "v1.0.0"

# Verify tag is annotated (not lightweight)
git cat-file -t v1.0.0  # Should output: "tag"
```

**Important Notes**:
- Tag MUST be prefixed with 'v' (Mason requirement)
- Tag MUST match version in Mason.toml exactly
- Use annotated tags (`-a`) not lightweight tags
- Tag message should describe release contents

---

#### Task 3.2: Verify Repository is Public

**Purpose**: Mason registry requires publicly accessible repositories

**Implementation**:
```bash
# Check if repository is public on GitHub
# Visit: https://github.com/Jesssullivan/chplcheck
# Verify: Repository should be accessible without login

# Or test via curl
curl -I https://github.com/Jesssullivan/chplcheck
# Should return HTTP 200, not 404
```

**If Repository is Private**:
```bash
# Go to GitHub repository settings
# Navigate to: Settings → General → Danger Zone
# Click "Change repository visibility"
# Select "Make public"
# Confirm
```

---

### Phase 4: Mason Registry Submission

**Goal**: Submit package to official Chapel Mason Registry

#### Task 4.1: Run Mason Publish (Automated Method)

**Purpose**: Use Mason's built-in publish command (recommended)

**Prerequisite Checks**:
```bash
# Verify all prerequisites
mason publish --check

# Expected output:
✅ Package name: quickchpl
✅ Version: 1.0.0
✅ Git repository: https://github.com/Jesssullivan/chplcheck
✅ Git tag v1.0.0 exists
✅ Remote origin configured
✅ Package builds
✅ Tests pass
✅ Ready to publish
```

**Dry Run** (Preview without submitting):
```bash
mason publish --dry-run

# Expected output:
Would create PR to mason-registry with:
  File: Bricks/quickchpl/1.0.0.toml
  Content:
    [brick]
    name = "quickchpl"
    version = "1.0.0"
    chplVersion = "2.6.0..2.7.0"
    license = "MIT"
    authors = ["Jess Sullivan <jess@sulliwood.org>"]
    repository = "https://github.com/Jesssullivan/chplcheck"
    description = "A simple property-based testing library for Chapel"
    keywords = ["testing", "property-based", "quickcheck", "pbt", "fuzzing"]
    source = "https://github.com/Jesssullivan/chplcheck"

    [dependencies]
```

**Actual Submission**:
```bash
# Submit to Mason Registry
mason publish

# Expected output:
Creating pull request to mason-registry...
✅ PR created: https://github.com/chapel-lang/mason-registry/pull/XXX
✅ PR title: "Adding quickchpl@1.0.0 package to registry via mason publish"
✅ CI checks will run automatically
✅ Wait for maintainer review and approval
```

**Post-Submission**:
1. Visit the PR URL provided
2. Monitor CI checks (should pass automatically)
3. Respond to any maintainer feedback
4. Wait for approval and merge

---

#### Task 4.2: Manual Submission (Fallback Method)

**Purpose**: If automated `mason publish` fails, submit manually

**Steps**:

1. **Fork mason-registry**:
   ```bash
   # Via GitHub UI or CLI
   gh repo fork chapel-lang/mason-registry
   cd /path/to/mason-registry
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b add-quickchpl-1.0.0
   ```

3. **Create package directory**:
   ```bash
   mkdir -p Bricks/quickchpl
   ```

4. **Create version TOML file**:
   ```bash
   # Copy Mason.toml and add source field
   cp /Users/jsullivan2/git/quickchpl/Mason.toml Bricks/quickchpl/1.0.0.toml

   # Add source field to 1.0.0.toml
   # Edit: Insert after [brick] section:
   source = "https://github.com/Jesssullivan/chplcheck"
   ```

5. **Commit and push**:
   ```bash
   git add Bricks/quickchpl/1.0.0.toml
   git commit -m "Adding quickchpl@1.0.0 package to registry via mason publish"
   git push origin add-quickchpl-1.0.0
   ```

6. **Open Pull Request**:
   ```bash
   # Via GitHub UI or CLI
   gh pr create --title "Adding quickchpl@1.0.0 package to registry via mason publish" \
                --body "Property-based testing framework for Chapel

This PR adds quickchpl version 1.0.0 to the Mason Registry.

**Package Details**:
- Name: quickchpl
- Version: 1.0.0
- Repository: https://github.com/Jesssullivan/chplcheck
- License: MIT
- Chapel Version: 2.6.0..2.7.0

**Description**:
quickchpl is a property-based testing library for Chapel, inspired by QuickCheck and Hypothesis. It provides generators, properties, shrinking, and common testing patterns with zero external dependencies.

**Features**:
- Comprehensive generator library (primitives, composites, combinators)
- Property testing with automatic counterexample shrinking
- Pattern library for common algebraic and functional properties
- Extensive test suite (unit + property tests)
- Multiple examples demonstrating real usage
- Well-documented API

**Validation**:
- ✅ Package builds: \`mason build\`
- ✅ Tests pass: \`mason test\`
- ✅ Examples work: \`mason build --example\`
- ✅ Git tag v1.0.0 exists
- ✅ Repository is public

**Checklist**:
- [x] Single .toml file for version 1.0.0
- [x] Source field points to public repository
- [x] Git tag v1.0.0 exists in repository
- [x] Package builds and tests pass
- [x] LICENSE file exists (MIT)
- [x] README.md is comprehensive"
   ```

7. **Monitor PR**:
   - CI will automatically validate the submission
   - Maintainers will review
   - Respond to any feedback
   - Wait for merge approval

---

### Phase 5: Post-Submission

**Goal**: Verify successful registration and update documentation

#### Task 5.1: Verify Package in Registry

**Purpose**: Confirm package is searchable and installable

**Implementation**:
```bash
# After PR is merged, wait ~5 minutes for registry update

# Search for package
mason search quickchpl

# Expected output:
quickchpl (1.0.0) - A simple property-based testing library for Chapel

# Try installing in a test project
mkdir /tmp/test-quickchpl-install
cd /tmp/test-quickchpl-install
mason new test-project
cd test-project

# Add quickchpl as dependency
mason add quickchpl@1.0.0

# Verify it appears in Mason.toml
cat Mason.toml
# Should show:
# [dependencies]
# quickchpl = "1.0.0"

# Build to verify installation
mason build
```

**Validation Criteria**:
- ✅ Package appears in `mason search quickchpl`
- ✅ Package can be added with `mason add quickchpl@1.0.0`
- ✅ Package installs and builds successfully
- ✅ Repository link works in registry web interface

---

#### Task 5.2: Update Project Documentation

**Purpose**: Inform users about Mason availability

**Implementation**:

1. **Update README.md**:
   ```markdown
   # quickchpl

   **Simple Property-Based Testing for Chapel**

   ## Installation

   ### Via Mason (Recommended)

   ```bash
   mason add quickchpl@1.0.0
   ```

   Then in your Chapel code:
   ```chapel
   use quickchpl;
   ```

   ### Manual Installation

   ```bash
   # clone
   export CHPL_MODULE_PATH=$CHPL_MODULE_PATH:$PWD/quickchpl/src
   ```
   ```

2. **Create CHANGELOG.md**:
   ```markdown
   # Changelog

   All notable changes to quickchpl will be documented in this file.

   The format is based on [Keep a Changelog](https://keepachangelog.com/),
   and this project adheres to [Semantic Versioning](https://semver.org/).

   ## [1.0.0] - 2026-01-12

   ### Added
   - Initial stable release
   - Core generators: int, real, bool, string
   - Composite generators: tuples, lists
   - Generator combinators: map, filter, zip, oneOf, frequency
   - Property testing framework with automatic shrinking
   - Pattern library: commutative, associative, identity, idempotent, involution, round-trip
   - Comprehensive test suite (unit + property tests)
   - Three example programs demonstrating usage
   - Zero external dependencies
   - Mason registry publication

   ### Documentation
   - Complete README with API reference
   - MASON_PUBLISHING_GUIDE (development)
   - Code documentation throughout
   - Examples with detailed comments

   [1.0.0]: https://github.com/Jesssullivan/chplcheck/releases/tag/v1.0.0
   ```

3. **Commit updates**:
   ```bash
   git add README.md CHANGELOG.md
   git commit -m "docs: update README with Mason installation instructions

   - Add Mason installation as recommended method
   - Create CHANGELOG.md for version tracking
   - Document v1.0.0 release features"

   git push origin main
   ```

---

#### Task 5.3: Create GitHub Release

**Purpose**: Provide official release artifacts on GitHub

**Implementation**:
```bash
# Via GitHub CLI
gh release create v1.0.0 \
  --title "v1.0.0: Initial Stable Release" \
  --notes "First public release of quickchpl property-based testing framework.

## 🎉 Features

- **Generators**: Create random test data for primitive and composite types
- **Properties**: Define invariants that should hold across all inputs
- **Shrinking**: Automatic minimization of failing test cases
- **Patterns**: Reusable templates for common property types
- **Combinators**: Compose and transform generators
- **Zero Dependencies**: Pure Chapel implementation

## 📦 Installation

### Via Mason (Recommended)
\`\`\`bash
mason add quickchpl@1.0.0
\`\`\`

### Manual
\`\`\`bash
git clone https://github.com/Jesssullivan/chplcheck.git
export CHPL_MODULE_PATH=\$CHPL_MODULE_PATH:\$PWD/chplcheck/src
\`\`\`

## 📚 Documentation

- [README](https://github.com/Jesssullivan/chplcheck/blob/main/README.md)
- [Examples](https://github.com/Jesssullivan/chplcheck/tree/main/examples)
- [Tests](https://github.com/Jesssullivan/chplcheck/tree/main/tests)

## 🧪 Example

\`\`\`chapel
use quickchpl;

var prop = property(
  \"addition is commutative\",
  tupleGen(intGen(), intGen()),
  proc((a, b): (int, int)) { return a + b == b + a; }
);

var result = check(prop);
assert(result.passed);
\`\`\`

## 🔗 Links

- **Mason Registry**: https://github.com/chapel-lang/mason-registry
- **Chapel**: https://chapel-lang.org/
- **License**: MIT

## ✅ Validated

- Chapel 2.6.0..2.7.0
- All tests passing
- Examples verified
- Mason build successful"
```

**Or via GitHub Web UI**:
1. Go to: https://github.com/Jesssullivan/chplcheck/releases/new
2. Choose tag: v1.0.0
3. Release title: "v1.0.0: Initial Stable Release"
4. Description: (Use notes from above)
5. Click "Publish release"

---

### Phase 6: Future Versions

**Goal**: Prepare for subsequent releases

#### Task 6.1: Future Version Workflow

**For version 1.0.1, 1.1.0, 2.0.0, etc.**:

1. **Update version in code**:
   ```bash
   # Update Mason.toml
   version = "1.0.1"  # or appropriate next version

   # Update src/chapelcheck.chpl
   param VERSION = "1.0.1";
   param VERSION_MAJOR = 1;
   param VERSION_MINOR = 0;
   param VERSION_PATCH = 1;
   ```

2. **Update CHANGELOG.md**:
   ```markdown
   ## [1.0.1] - 2026-XX-XX

   ### Fixed
   - Bug fix description

   ### Added
   - New feature description
   ```

3. **Commit changes**:
   ```bash
   git add Mason.toml src/chapelcheck.chpl CHANGELOG.md
   git commit -m "chore: bump version to 1.0.1"
   git push origin main
   ```

4. **Create new tag**:
   ```bash
   git tag -a v1.0.1 -m "Release v1.0.1: Bug fixes and improvements"
   git push origin v1.0.1
   ```

5. **Publish to registry**:
   ```bash
   mason publish
   # This will create PR with Bricks/quickchpl/1.0.1.toml
   ```

---

## Risk Assessment

### High Risk

1. **Repository URL Mismatch**
   - **Risk**: Mason.toml references non-existent GitLab repo
   - **Impact**: Registry submission will fail
   - **Mitigation**: Resolve in Task 1.1
   - **Status**: ❌ Must fix before submission

2. **Missing Git Tag**
   - **Risk**: No v1.0.0 tag exists
   - **Impact**: Registry submission will fail
   - **Mitigation**: Create in Task 3.1
   - **Status**: ❌ Must fix before submission

### Medium Risk

1. **Version 1.0.0 vs 0.1.0**
   - **Risk**: Starting with 1.0.0 signals stable API commitment
   - **Impact**: Pressure to maintain compatibility
   - **Mitigation**: Consider starting with 0.1.0, or ensure API is stable
   - **Status**: ⚠️ Decision needed

2. **Build/Test Failures**
   - **Risk**: Tests or examples may fail
   - **Impact**: Delays submission, requires debugging
   - **Mitigation**: Validate in Phase 2
   - **Status**: ⚠️ Need to verify

### Low Risk

1. **Mason Publish Command Availability**
   - **Risk**: `mason publish` may not be available in all Mason versions
   - **Impact**: Need to use manual submission
   - **Mitigation**: Manual submission process documented (Task 4.2)
   - **Status**: ✅ Fallback available

---

## Success Criteria

### Must Have (Blocking)

- ✅ Repository URL resolved (GitHub or GitLab)
- ✅ Git tag v1.0.0 created and pushed
- ✅ Package builds successfully (`mason build`)
- ✅ All tests pass (`mason test`)
- ✅ Examples build and run (`mason build --example`)
- ✅ PR submitted to mason-registry
- ✅ CI checks pass on registry PR
- ✅ Maintainers approve and merge PR

### Should Have (Important)

- ✅ .gitignore updated and binaries removed
- ✅ Pre-publish checklist passes
- ✅ Documentation updated with Mason instructions
- ✅ CHANGELOG.md created
- ✅ GitHub release created

### Nice to Have (Optional)

- ✅ Mason.lock committed (reproducibility)
- ✅ Additional examples
- ✅ Performance benchmarks
- ✅ Extended documentation

---

## Timeline Estimate

| Phase | Tasks | Estimated Time | Dependencies |
|-------|-------|----------------|--------------|
| **Phase 1** | Repository cleanup | 30-60 min | None |
| **Phase 2** | Validation & testing | 30-60 min | Phase 1 |
| **Phase 3** | Git tagging | 15-30 min | Phase 2 |
| **Phase 4** | Registry submission | 15-30 min | Phase 3 |
| **Phase 5** | Post-submission | 30-60 min | Phase 4 |
| **Phase 6** | Future planning | 15 min | Phase 5 |
| **TOTAL** | | **2.5-4.5 hours** | |

**Note**: Timeline assumes no major bugs are found during validation. Add 1-3 hours if debugging is required.

---

## Decision Points

### Decision 1: Repository URL (REQUIRED)

**Options**:
- **A**: Use GitHub (https://github.com/Jesssullivan/chplcheck)
  - Pros: Already configured as git remote, simpler
  - Cons: Need to update Mason.toml
- **B**: Use GitLab (https://gitlab.com/tinyland/projects/quickchpl)
  - Pros: Matches current Mason.toml
  - Cons: Need to set up GitLab repo, update git remote

**Recommendation**: **Option A (GitHub)** - less work, GitHub is more common for Chapel packages

**User Input Required**: Yes

---

### Decision 2: Version Number (OPTIONAL)

**Options**:
- **A**: Keep 1.0.0
  - Pros: Signals confidence, production-ready
  - Cons: Commits to API stability
- **B**: Change to 0.1.0
  - Pros: More flexibility for API changes
  - Cons: Requires version update in code

**Recommendation**: **Option A (1.0.0)** - Code appears mature and well-designed

**User Input Required**: Optional (can proceed with 1.0.0)

---

### Decision 3: .gitignore for .claude/ (OPTIONAL)

**Options**:
- **A**: Keep .claude/ in .gitignore
  - Pros: Developer-specific files stay local
  - Cons: Useful slash commands not shared
- **B**: Remove .claude/ from .gitignore
  - Pros: Share helpful commands with other developers
  - Cons: Claude Code-specific, may confuse non-users

**Recommendation**: **Option B (track .claude/)** - Useful for all contributors

**User Input Required**: Optional

---

## Next Steps

1. **User Review**: Review this plan and make decisions
2. **User Approval**: Approve plan to proceed with implementation
3. **Execute Phase 1**: Repository & configuration cleanup
4. **Execute Phase 2**: Validation & testing
5. **Execute Phase 3**: Git tagging
6. **Execute Phase 4**: Registry submission
7. **Execute Phase 5**: Post-submission
8. **Execute Phase 6**: Future planning

---

## Appendix: Useful Commands

### Mason Commands
```bash
mason build                    # Build package
mason test                     # Run tests
mason build --example          # Build examples
mason run --example NAME       # Run specific example
mason publish --dry-run        # Preview submission
mason publish --check          # Validate package
mason publish                  # Submit to registry
mason search quickchpl         # Search registry
mason add quickchpl@1.0.0     # Add dependency
```

### Git Commands
```bash
git tag -a v1.0.0 -m "message"  # Create annotated tag
git push origin v1.0.0          # Push tag
git tag -l                      # List tags
git show v1.0.0                 # Show tag details
```

### Validation Commands
```bash
./.claude/helpers/pre-publish-checklist.sh  # Run full checklist
```

---

**Document Version**: 1.0
**Last Updated**: 2026-01-12
**Author**: Claude (Plan Mode)
**Status**: Ready for Review and Approval
