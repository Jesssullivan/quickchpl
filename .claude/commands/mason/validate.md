Validate the ChapelCheck package for Mason registry publication.

Execute:
```bash
mason publish --dry-run && mason publish --check
```

This will:
1. Preview what would be published (--dry-run)
2. Run full validation checks (--check)

Review the output to ensure:
- All required fields are present in Mason.toml
- Package structure is correct
- Tests pass
- Git tag exists matching version
- Repository is accessible
