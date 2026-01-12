#!/bin/bash

set -euo pipefail

PROJECT_NAME="quickchpl"
PROJECT_PATH="/Users/jsullivan2/git/quickchpl"
VERSION="1.0.0"
LOCAL_REGISTRY="$HOME/mason-local-dev"

echo "=== Setting up Local Mason Development Environment ==="
echo ""

echo "Creating local registry at $LOCAL_REGISTRY..."
mkdir -p "$LOCAL_REGISTRY/Bricks/$PROJECT_NAME"
cd "$LOCAL_REGISTRY"

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

if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    echo "✓ Initialized git repository"
fi

git add "Bricks/$PROJECT_NAME/$VERSION.toml"
if git diff --cached --quiet; then
    echo "✓ Manifest already committed"
else
    git commit -m "Add $PROJECT_NAME v$VERSION to local registry"
    echo "✓ Committed manifest"
fi

SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q "MASON_REGISTRY.*mason-local-dev" "$SHELL_RC" 2>/dev/null; then
    echo ""
    echo "Adding MASON_REGISTRY to $SHELL_RC..."
    cat >> "$SHELL_RC" <<'EOF'

# Mason local development registry
export MASON_REGISTRY="local-dev|$HOME/mason-local-dev,mason-registry|https://github.com/chapel-lang/mason-registry"
EOF
    echo "✓ Added MASON_REGISTRY to $SHELL_RC"
    echo ""
    echo "⚠️  IMPORTANT: Run 'source $SHELL_RC' to activate!"
else
    echo "✓ MASON_REGISTRY already configured in $SHELL_RC"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. source $SHELL_RC"
echo "  2. cd /Users/jsullivan2/git/aoc-2025-chapel-27"
echo "  3. mason init  # if not already a Mason project"
echo "  4. mason add $PROJECT_NAME"
echo "  5. mason update && mason build"
echo ""
echo "Development workflow:"
echo "  - Edit files in $PROJECT_PATH"
echo "  - Run 'mason update' in consumer project"
echo "  - Changes reflected immediately (no git commit needed!)"
echo ""
