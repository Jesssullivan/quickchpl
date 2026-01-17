---
title: Contributing Guidelines
description: "How to contribute to quickchpl. Bug reports, feature requests, pull request process. Commit message conventions. Code of conduct and licensing."
---

# Contributing Guidelines

Thank you for your interest in contributing to quickchpl!

## Ways to Contribute

- **Bug Reports**: Open an issue describing the bug
- **Feature Requests**: Open an issue describing the feature
- **Documentation**: Improve docs, examples, or comments
- **Code**: Fix bugs or implement features
- **Testing**: Add property tests or unit tests

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/quickchpl.git
   ```
3. Set up development environment:
   ```bash
   cd quickchpl
   ./scripts/setup-local-mason-dev.sh
   ```
4. Create a branch:
   ```bash
   git checkout -b feature/my-feature
   ```

## Development Workflow

### Building

```bash
mason build
```

### Testing

```bash
# Run all tests
mason test

# Run specific test
chpl tests/unit/GeneratorTests.chpl src/*.chpl -o test && ./test
```

### Code Style

- Follow Chapel conventions
- Use descriptive variable names
- Add doc comments for public APIs
- Keep functions focused and small

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `test`: Adding tests
- `refactor`: Code restructuring
- `style`: Formatting changes
- `chore`: Build/tooling changes

Examples:
```
feat(generators): add weighted boolean generator
fix(shrinkers): handle empty string edge case
docs(readme): add installation instructions
```

## Pull Request Process

1. Update documentation if needed
2. Add tests for new functionality
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Submit PR with clear description

### PR Checklist

- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commit messages follow convention
- [ ] No breaking changes (or documented)

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Assume good intentions
- Help others learn

## Questions?

- Open an issue with the "question" label
- Check existing issues and documentation first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
