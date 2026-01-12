#!/usr/bin/env bash
# Pre-publish checklist for ChapelCheck Mason registry submission

set -euo pipefail

echo "🔍 ChapelCheck Pre-Publish Checklist"
echo "====================================="
echo

# Check git status
echo "📋 Checking git status..."
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Working directory is not clean. Commit or stash changes first."
    exit 1
fi
echo "✅ Working directory is clean"
echo

# Check Mason.toml exists
echo "📋 Checking Mason.toml..."
if [[ ! -f "Mason.toml" ]]; then
    echo "❌ Mason.toml not found"
    exit 1
fi
echo "✅ Mason.toml exists"
echo

# Extract version from Mason.toml
VERSION=$(grep '^version = ' Mason.toml | cut -d'"' -f2)
echo "📋 Package version: $VERSION"
echo

# Check git tag
echo "📋 Checking git tag v$VERSION..."
if ! git tag | grep -q "^v$VERSION$"; then
    echo "❌ Git tag v$VERSION not found"
    echo "   Create it with: git tag v$VERSION && git push origin v$VERSION"
    exit 1
fi
echo "✅ Git tag v$VERSION exists"
echo

# Check remote
echo "📋 Checking git remote..."
REMOTE=$(git remote get-url origin || echo "")
if [[ -z "$REMOTE" ]]; then
    echo "❌ No git remote origin configured"
    exit 1
fi
echo "✅ Remote origin: $REMOTE"
echo

# Build
echo "📋 Building package..."
if ! mason build; then
    echo "❌ Build failed"
    exit 1
fi
echo "✅ Build successful"
echo

# Test
echo "📋 Running tests..."
if ! mason test; then
    echo "❌ Tests failed"
    exit 1
fi
echo "✅ Tests passed"
echo

# Check examples
echo "📋 Building examples..."
if ! mason build --example; then
    echo "❌ Example build failed"
    exit 1
fi
echo "✅ Examples built successfully"
echo

# Check LICENSE
echo "📋 Checking LICENSE file..."
if [[ ! -f "LICENSE" ]]; then
    echo "❌ LICENSE file not found"
    exit 1
fi
echo "✅ LICENSE file exists"
echo

# Check README
echo "📋 Checking README.md..."
if [[ ! -f "README.md" ]]; then
    echo "❌ README.md not found"
    exit 1
fi
echo "✅ README.md exists"
echo

# Dry run publish
echo "📋 Running publish dry-run..."
if ! mason publish --dry-run; then
    echo "❌ Publish dry-run failed"
    exit 1
fi
echo "✅ Publish dry-run successful"
echo

echo "🎉 All Pre-Publish Checks Passed!"
echo
echo "Next steps:"
echo "1. Review the output above"
echo "2. Run: mason publish --check (full validation)"
echo "3. Run: mason publish (submit to registry)"
echo
