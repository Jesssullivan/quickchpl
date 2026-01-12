# Claude Code Configuration - ChapelCheck Property-Based Testing Framework

## 🚨 CRITICAL: CONCURRENT EXECUTION & FILE MANAGEMENT

**ABSOLUTE RULES**:
1. ALL operations MUST be concurrent/parallel in a single message
2. **NEVER save working files to the root folder**
3. ALWAYS organize files in appropriate subdirectories
4. **USE CLAUDE CODE'S TASK TOOL** for spawning agents concurrently

### ⚡ GOLDEN RULE: "1 MESSAGE = ALL RELATED OPERATIONS"

**MANDATORY PATTERNS:**
- **TodoWrite**: ALWAYS batch ALL todos in ONE call (5-10+ todos minimum)
- **Task tool**: ALWAYS spawn ALL agents in ONE message with full instructions
- **File operations**: ALWAYS batch ALL reads/writes/edits in ONE message
- **Bash commands**: ALWAYS batch ALL terminal operations in ONE message
- **MCP operations**: ALWAYS batch related MCP calls in ONE message

### 📁 File Organization Rules

**NEVER save to root folder. Use these directories:**
- `/docs` - Documentation and markdown files
- `/examples` - Example Chapel programs demonstrating ChapelCheck usage
- `/tests` - Test files (unit, properties, integration)
- `/src` - Source code for ChapelCheck modules
- `/scripts` - Shell scripts and utilities
- `/.claude` - Claude Code configuration

---

## 📚 Project-Specific Context

### Project Overview

**ChapelCheck** is a property-based testing framework for Chapel, inspired by QuickCheck and Hypothesis. It provides:
- **Generators**: Create random test data
- **Properties**: Define invariants that should hold
- **Shrinkers**: Minimize failing cases
- **Reporters**: Format test results
- **Combinators**: Compose generators and properties
- **Patterns**: Common testing patterns

### Chapel Version

**Target**: Chapel 2.6.0+
**Local Docs**: `docs/chapel-2.6/rst/` (if available, gitignored)

### Chapel Reserved Words (CRITICAL)

**NEVER use these as variable/function names**:
`config`, `domain`, `bytes`, `type`, `index`, `align`, `as`, `atomic`, `begin`, `bool`, `borrowed`, `break`, `by`, `catch`, `class`, `cobegin`, `coforall`, `complex`, `const`, `continue`, `defer`, `delete`, `dmapped`, `do`, `else`, `enum`, `except`, `export`, `extern`, `false`, `for`, `forall`, `foreach`, `forwarding`, `if`, `imag`, `import`, `in`, `inline`, `inout`, `int`, `iter`, `label`, `lambda`, `let`, `lifetime`, `local`, `locale`, `manage`, `module`, `new`, `nil`, `noinit`, `none`, `nothing`, `on`, `only`, `operator`, `otherwise`, `out`, `override`, `owned`, `param`, `pragma`, `private`, `proc`, `prototype`, `public`, `real`, `record`, `reduce`, `ref`, `require`, `return`, `scan`, `select`, `serial`, `shared`, `single`, `sparse`, `string`, `subdomain`, `sync`, `then`, `this`, `throw`, `throws`, `true`, `try`, `uint`, `union`, `unmanaged`, `use`, `var`, `void`, `when`, `where`, `while`, `with`, `yield`, `zip`

**Common Naming Conflicts to Avoid:**
- `config` → use `cfg`, `settings`, `testConfig`
- `domain` → use `testDomain`, `dataDomain`, `propertyDomain`
- `bytes` → use `byteData`, `rawBytes`, `data`
- `type` → use `typeKind`, `dataType`, `genType`
- `index` → use `idx`, `pos`, `offset`

---

## 🔧 Mason Build System

### Mason.toml Configuration

**Current Configuration**:
```toml
[brick]
name = "chapelcheck"
version = "0.1.0"
authors = ["Your Name <your.email@example.com>"]
license = "MIT"
chplVersion = "2.6.0"

[dependencies]
# Zero dependencies - good for adoption!
```

### Common Mason Commands

```bash
# Build the library
mason build

# Run tests
mason test

# Run specific test
mason test tests/unit/GeneratorTests.chpl

# Build examples
mason build --example

# Run specific example
mason run --example GettingStarted

# Update dependencies (none currently)
mason update

# Validate package for publishing
mason publish --dry-run
mason publish --check

# Publish to registry
mason publish
```

### Mason Slash Commands

Available via `.claude/commands/mason/`:
- `/mason-build` - Build the ChapelCheck library
- `/mason-test` - Run all tests
- `/mason-example` - Build and run examples
- `/mason-validate` - Validate package for publishing
- `/mason-publish` - Publish to Mason registry

---

## 📦 Mason Registry Submission

### Publication Checklist

Before publishing to mason-registry:

- [ ] All tests passing: `mason test`
- [ ] Examples build and run: `mason build --example && mason run --example`
- [ ] Documentation is complete (README.md, code comments)
- [ ] Mason.toml has all required fields
- [ ] License file exists (MIT)
- [ ] Git tag created: `git tag v0.1.0 && git push origin v0.1.0`
- [ ] GitHub repository is public
- [ ] Validation passes: `mason publish --check`

### Submission Process

**Automated** (Recommended):
```bash
mason publish --dry-run    # Preview
mason publish --check      # Full validation
mason publish              # Submit PR to mason-registry
```

**Manual**:
1. Fork `chapel-lang/mason-registry`
2. Create `Bricks/chapelcheck/0.1.0.toml` with `source` field
3. Submit PR titled: "Adding chapelcheck@0.1.0 package to registry via mason publish"

**Documentation**: See `MASON_PUBLISHING_GUIDE.md` for complete details

---

## 🧪 Testing Strategy

### Test Organization

```
tests/
├── unit/                    # Unit tests for individual modules
│   ├── GeneratorTests.chpl  # Test generators
│   ├── PropertyTests.chpl   # Test property execution
│   └── ShrinkerTests.chpl   # Test shrinking
└── properties/              # Self-tests using property-based testing
    └── SelfTests.chpl       # ChapelCheck testing itself
```

### Testing Best Practices

1. **Unit Tests**: Test individual components in isolation
2. **Property Tests**: Use ChapelCheck to test ChapelCheck (dogfooding)
3. **Example Tests**: Ensure examples compile and run
4. **Documentation Tests**: Verify README examples work

### Test Slash Commands

Available via `.claude/commands/testing/`:
- `/run-tests` - Run all tests with detailed output
- `/test-generators` - Test generator module only
- `/test-properties` - Test property module only
- `/test-examples` - Build and run all examples
- `/coverage` - Analyze test coverage

---

## 📖 Documentation Standards

### Code Documentation

**Chapel Doc Comments**:
```chapel
/*
  Generates random integers in a specified range.

  :arg min: Minimum value (inclusive)
  :arg max: Maximum value (inclusive)
  :returns: Random integer in [min, max]
*/
proc intGen(min: int, max: int): int {
  // Implementation
}
```

### README Requirements

- **Overview**: What is ChapelCheck?
- **Installation**: How to add to Mason project
- **Quick Start**: Simple example
- **API Reference**: Core functions and modules
- **Examples**: Links to example/ directory
- **License**: MIT license information
- **Contributing**: How to contribute

### Documentation Files

- `README.md` - Main documentation
- `MASON_PUBLISHING_GUIDE.md` - Mason registry submission guide
- `CHANGELOG.md` - Version history
- `CONTRIBUTING.md` - Contribution guidelines
- `docs/` - Extended documentation (API, tutorials, guides)

---

## 🎯 Development Workflow

### Adding New Features

1. **Plan**: Use TodoWrite to break down tasks
2. **Implement**: Add code to appropriate `src/` module
3. **Test**: Add unit tests in `tests/unit/`
4. **Example**: Add usage example in `examples/`
5. **Document**: Update README and code comments
6. **Validate**: Run `mason build && mason test`

### Example Feature Development Flow

```javascript
// ✅ CORRECT: Batch all operations
[Single Message]:
  TodoWrite({ todos: [
    {content: "Implement new string generator", status: "in_progress"},
    {content: "Add unit tests for string generator", status: "pending"},
    {content: "Add example using string generator", status: "pending"},
    {content: "Update README with string generator docs", status: "pending"}
  ]})

  Edit("src/Generators.chpl", old_string, new_string)
  Write("tests/unit/StringGenTests.chpl", test_code)
  Write("examples/StringProperties.chpl", example_code)
  Edit("README.md", old_docs, new_docs)

  Bash("mason build && mason test")
```

### Git Workflow

**Branch Strategy**:
- `main` - Stable releases
- `develop` - Development branch
- `feature/<name>` - New features
- `bugfix/<name>` - Bug fixes

**Commit Messages**:
```bash
# Feature
git commit -m "feat: add string generator"

# Bug fix
git commit -m "fix: correct shrinking logic for nested lists"

# Documentation
git commit -m "docs: update README with advanced examples"

# Tests
git commit -m "test: add property tests for combinators"
```

**NEVER commit**:
- `target/` - Build artifacts
- `Mason.lock` - Optional (decision needed)
- Compiled binaries (`.o`, executables)

---

## 🚀 Agent Usage for ChapelCheck

### Recommended Agents

**Core Development**:
- `coder` - Implement new generators, properties, shrinkers
- `reviewer` - Review code quality and Chapel idioms
- `tester` - Write comprehensive tests
- `planner` - Plan complex features

**Testing Specialists**:
- `tdd-london-swarm` - Test-driven development approach
- `production-validator` - Validate release readiness

**Documentation**:
- `researcher` - Research testing patterns and examples
- `api-docs` - Generate API documentation

**GitHub Operations**:
- `pr-manager` - Manage pull requests
- `release-manager` - Handle releases and versioning

### Agent Execution Pattern

```javascript
// ✅ CORRECT: Spawn multiple agents concurrently
[Single Message]:
  Task("Coder", "Implement float generator with edge cases", "coder")
  Task("Tester", "Write property tests for float generator", "tester")
  Task("Reviewer", "Review Chapel best practices compliance", "reviewer")

  TodoWrite({ todos: [
    {content: "Implement float generator", status: "in_progress"},
    {content: "Write tests", status: "pending"},
    {content: "Code review", status: "pending"}
  ]})
```

---

## 🔍 Quality Standards

### Code Quality

**Checklist**:
- [ ] Follows Chapel style conventions
- [ ] No reserved word conflicts
- [ ] Comprehensive error handling
- [ ] Clear, descriptive variable names
- [ ] Functions are small and focused
- [ ] No hardcoded values (use params/configs)

### Testing Quality

**Checklist**:
- [ ] Unit tests for all public APIs
- [ ] Property tests using ChapelCheck itself
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Examples demonstrate real usage

### Documentation Quality

**Checklist**:
- [ ] README is clear and comprehensive
- [ ] Code has Chapel doc comments
- [ ] Examples are well-commented
- [ ] Installation instructions work
- [ ] API reference is complete

---

## 🎨 ChapelCheck Design Principles

### Core Philosophy

1. **Simplicity**: Easy to learn and use
2. **Composability**: Generators and properties should compose
3. **Expressiveness**: Tests should read like specifications
4. **Debuggability**: Shrinking helps find minimal failing cases
5. **Zero Dependencies**: Easy to adopt in any Chapel project

### API Design Goals

- **Intuitive**: Match Chapel conventions
- **Discoverable**: Use clear naming
- **Flexible**: Support multiple use cases
- **Efficient**: Minimize overhead

### Code Organization

```
src/
├── chapelcheck.chpl     # Main module (re-exports all submodules)
├── Generators.chpl      # Random data generators
├── Properties.chpl      # Property testing framework
├── Shrinkers.chpl       # Test case minimization
├── Reporters.chpl       # Test result formatting
├── Combinators.chpl     # Composition utilities
└── Patterns.chpl        # Common testing patterns
```

---

## 📋 Project Roadmap

### Version 0.1.0 (Initial Release)

- [x] Core generator types (int, bool, float, string)
- [x] Property testing framework
- [x] Basic shrinkers
- [x] Console reporter
- [x] Example programs
- [ ] Comprehensive documentation
- [ ] Mason registry submission

### Version 0.2.0 (Enhanced Generators)

- [ ] Collection generators (arrays, lists, sets)
- [ ] Tuple and record generators
- [ ] Custom generator combinators
- [ ] Generator transformations

### Version 1.0.0 (Stable API)

- [ ] Complete API surface
- [ ] Performance optimizations
- [ ] Extensive test suite
- [ ] Tutorial documentation
- [ ] Adoption by Chapel projects

---

## 🛠️ Slash Commands Reference

### Mason Commands (`/mason-*`)

- `/mason-build` - Build ChapelCheck library
- `/mason-test` - Run all tests
- `/mason-example` - Build and run examples
- `/mason-validate` - Validate for publishing
- `/mason-publish` - Publish to registry

### Testing Commands (`/test-*`)

- `/run-tests` - Run all tests with output
- `/test-generators` - Test generators only
- `/test-properties` - Test properties only
- `/test-examples` - Test all examples

### Development Commands

- `/analyze-coverage` - Check test coverage
- `/check-style` - Validate code style
- `/build-docs` - Generate documentation

---

## 📚 Reference Documentation

### External Resources

- **Chapel Documentation**: https://chapel-lang.org/docs/
- **Mason Guide**: https://chapel-lang.org/docs/tools/mason/mason.html
- **Mason Registry**: https://github.com/chapel-lang/mason-registry
- **Chapel Discourse**: https://chapel.discourse.group/

### Project Documentation

- `README.md` - Main documentation
- `MASON_PUBLISHING_GUIDE.md` - Publishing guide (600+ lines)
- `Mason.toml` - Package manifest
- `LICENSE` - MIT license

### Similar Projects (Inspiration)

- **QuickCheck** (Haskell) - Original property-based testing
- **Hypothesis** (Python) - Modern property-based testing
- **fast-check** (JavaScript) - Property-based testing for JS
- **PropEr** (Erlang) - Property-based testing for BEAM

---

## 🎯 Best Practices Summary

### Development

1. **Batch operations** - Single message for related work
2. **Use TodoWrite** - Track multi-step tasks
3. **Organize files** - Never save to root
4. **Test thoroughly** - Unit, property, and example tests
5. **Document clearly** - Code comments and README

### Chapel Idioms

1. **Avoid reserved words** - Use naming alternatives
2. **Use Chapel types** - `int`, `real`, `bool`, `string`
3. **Leverage iterators** - For generator composition
4. **Domain expertise** - Use domains and ranges appropriately
5. **Module organization** - Clear module boundaries

### Testing Philosophy

1. **Test what matters** - Focus on invariants
2. **Shrink failures** - Minimize failing test cases
3. **Dogfood your tool** - Use ChapelCheck to test ChapelCheck
4. **Diverse examples** - Show multiple use cases
5. **Clear reporting** - Make failures easy to understand

---

## Important Reminders

1. **NEVER save to root folder** - Use docs/, examples/, tests/, src/
2. **ALWAYS batch operations** - Single message for related work
3. **Use Task tool for agents** - Spawn all agents concurrently
4. **Follow Chapel conventions** - Avoid reserved words
5. **Test comprehensively** - Unit, property, and examples
6. **Document thoroughly** - README, code comments, guides
7. **Validate before push** - `mason build && mason test`

---

**Remember**: Concurrent execution, proper organization, thorough testing, and clear documentation!
