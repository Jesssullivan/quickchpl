---
title: Development Setup
description: "Set up quickchpl development environment. Install Chapel 2.6+, clone repo, run mason build/test. IDE setup for VS Code and Vim. Troubleshooting guide."
---

# Development Setup

Set up your environment for quickchpl development.

## Prerequisites

- **Chapel 2.6.0+**: [Installation Guide](https://chapel-lang.org/docs/usingchapel/QUICKSTART.html)
- **Git**: For version control
- **Text Editor**: With Chapel syntax support (VS Code recommended)

## Quick Setup

```bash
# Clone the repository
git clone https://github.com/Jesssullivan/quickchpl.git
cd quickchpl

# Run the setup script
./scripts/setup-local-mason-dev.sh

# Verify installation
mason build
mason test
```

## Manual Setup

### 1. Install Chapel

=== "macOS (Homebrew)"

    ```bash
    brew install chapel
    ```

=== "Linux (apt)"

    ```bash
    # Add Chapel PPA
    sudo add-apt-repository ppa:chapel-lang/chapel
    sudo apt update
    sudo apt install chapel
    ```

=== "From Source"

    ```bash
    git clone https://github.com/chapel-lang/chapel.git
    cd chapel
    source util/quickstart/setchplenv.bash
    make
    ```

### 2. Verify Chapel

```bash
chpl --version
mason --version
```

### 3. Clone Repository

```bash
git clone https://github.com/Jesssullivan/quickchpl.git
cd quickchpl
```

### 4. Build and Test

```bash
mason build
mason test
```

## Project Structure

```
quickchpl/
├── src/                    # Source code
│   ├── chapelcheck.chpl   # Main module
│   ├── Generators.chpl    # Generators
│   ├── Properties.chpl    # Properties
│   ├── Shrinkers.chpl     # Shrinkers
│   ├── Reporters.chpl     # Reporters
│   ├── Combinators.chpl   # Combinators
│   └── Patterns.chpl      # Patterns
├── tests/                  # Tests
│   ├── unit/              # Unit tests
│   └── properties/        # Property tests
├── examples/              # Example programs
├── docs/                  # Documentation
├── scripts/               # Development scripts
├── Mason.toml             # Package manifest
└── README.md
```

## Development Commands

### Build

```bash
# Build library
mason build

# Build with optimizations
mason build --release
```

### Test

```bash
# Run all tests
mason test

# Run specific test file
chpl tests/unit/GeneratorTests.chpl src/*.chpl -o test
./test
```

### Examples

```bash
# Build all examples
mason build --example

# Run specific example
mason run --example GettingStarted
```

### Documentation

```bash
# Generate API docs
mason doc

# Serve mkdocs locally
pip install mkdocs-material
mkdocs serve
```

## IDE Setup

### VS Code

1. Install Chapel extension
2. Configure settings:
   ```json
   {
     "chapel.chplHome": "/path/to/chapel",
     "editor.tabSize": 2
   }
   ```

### Vim/Neovim

```vim
" Chapel syntax
au BufRead,BufNewFile *.chpl set filetype=chapel
```

## Troubleshooting

### Mason not found

```bash
# Ensure Chapel is in PATH
export PATH=$PATH:$CHPL_HOME/bin/$(uname -m)-$(uname -s | tr A-Z a-z)
```

### Build failures

```bash
# Clean and rebuild
rm -rf target/
mason build
```

### Test failures

```bash
# Run with verbose output
./test --verbose=true
```

## Next Steps

- [Contributing Guidelines](guidelines.md)
- [Code Style](style.md)
