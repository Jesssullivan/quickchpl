# Containerfile for quickchpl Documentation
# Build: podman build -t quickchpl-docs -f Containerfile .
# Run:   podman run --rm -v $PWD:/workspace:Z quickchpl-docs

FROM python:3.13-slim AS base

# Create non-root user
RUN useradd -m -s /bin/bash docs && \
    mkdir -p /workspace && \
    chown -R docs:docs /workspace

# Install UV for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /workspace

# Install MkDocs dependencies
COPY docs/requirements.txt /tmp/requirements.txt
RUN uv pip install --system -r /tmp/requirements.txt

# Switch to non-root user
USER docs

# Default command: build docs with strict validation
CMD ["mkdocs", "build", "--strict"]

# Alternative commands:
# Serve locally: podman run --rm -p 8000:8000 -v $PWD:/workspace:Z quickchpl-docs mkdocs serve -a 0.0.0.0:8000
# Validate only: podman run --rm -v $PWD:/workspace:Z quickchpl-docs mkdocs build --strict --verbose
