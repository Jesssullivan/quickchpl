# Changelog

All notable changes to quickchpl will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.2] - 2026-01-15

### Fixed
- Generic type warnings: Added `Property(?)` syntax for generic formal parameters
- Unstable symbol warnings: Replaced `_unused` loop variables with bare `for 1..n` syntax
- Mason main module check: Restructured to proper submodule convention

### Changed
- Moved submodules to `src/quickchpl/` directory per Mason package conventions
- Updated `quickchpl.chpl` to use `include module` statements before `public use`
- Test files now import via `use quickchpl` instead of direct submodule imports
- CI acceptable violations reduced from 30 to 9 (removed UnusedLoopIndex)
- Chapel version compatibility extended to 2.8.0

### Infrastructure
- Updated GitHub Actions and GitLab CI paths for new module structure
- Fixed Mason.toml trailing newline (Mason bug workaround)

[1.0.2]: https://github.com/Jesssullivan/quickchpl/releases/tag/v1.0.2

## [1.0.1] - 2026-01-12

### Fixed
- README examples updated to match actual API signatures
- Tuple destructuring syntax corrected for Chapel 2.6+
- Removed references to non-existent Pattern template functions

### Changed
- Consolidated `tests/` directory to `test/` (Mason convention)
- Added chplcheck linting integration to CI

### Infrastructure
- Added GitLab CI/CD configuration
- Fixed release workflow permissions and URLs

[1.0.1]: https://github.com/Jesssullivan/quickchpl/releases/tag/v1.0.1

## [1.0.0] - 2026-01-12

### Added
- Initial stable release of quickchpl property-based testing framework
- Core generators: `intGen()`, `realGen()`, `boolGen()`, `stringGen()`
- Composite generators: `tupleGen()`, `listGen()`, `constantGen()`
- Generator combinators: `map()`, `filter()`, `zip()`, `oneOf()`, `frequency()`
- Property testing framework with automatic shrinking
- Shrinking strategies for integers, reals, strings, lists, and tuples
- Pattern library: commutative, associative, identity, idempotent, involution, round-trip
- Comprehensive test suite (unit tests + property-based self-tests)
- Three example programs demonstrating usage
- Zero external dependencies (pure Chapel implementation)
- Chapel 2.6.0..2.7.0 compatibility

### Documentation
- Complete README with API reference and examples
- Code documentation throughout source files
- Three detailed example programs with comments

### Infrastructure
- GitHub Actions CI/CD pipeline
- Local Mason registry development workflow
- Release automation
- Multi-version Chapel testing (2.6.0, 2.7.0)

### Project Structure
- `docs/` - Comprehensive documentation (local, docs still in progress)
- `examples/` - Working example programs (to be laced into Mason examples flow)
- `src/` - Source modules (7 modules)
- `tests/` - Unit and property tests
- `scripts/` - Helper scripts for development

[1.0.0]: https://github.com/Jesssullivan/quickchpl/releases/tag/v1.0.0
