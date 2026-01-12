# Changelog

All notable changes to quickchpl will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
