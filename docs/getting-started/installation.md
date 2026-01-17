---
title: Installation
description: "Install quickchpl via Mason package manager or git clone. Requires Chapel 2.6.0+. Verify installation with a simple smoke test."
---

# Installation

## Prerequisites

- **Chapel 2.6.0** or later
- **Mason** (Chapel's package manager, included with Chapel)

## Installation Methods

=== "Mason (Recommended)"

    The easiest way to add quickchpl to your project:

    ```bash
    cd your-project
    mason add quickchpl
    ```

    Then in your Chapel code:

    ```chapel
    use quickchpl;
    ```

=== "Git Clone"

    Clone the repository and set up the module path:

    ```bash
    git clone https://github.com/Jesssullivan/quickchpl.git
    export CHPL_MODULE_PATH=$CHPL_MODULE_PATH:$PWD/quickchpl/src
    ```

=== "Git Submodule"

    Add as a submodule to your project:

    ```bash
    git submodule add https://github.com/Jesssullivan/quickchpl.git deps/quickchpl
    export CHPL_MODULE_PATH=$CHPL_MODULE_PATH:$PWD/deps/quickchpl/src
    ```

## Verification

Create a simple test file to verify installation:

```chapel title="verify_install.chpl"
use quickchpl;

writeln("quickchpl version: ", VERSION);
writeln("Installation successful!");

// Quick smoke test
var result = quickCheck(intGen(), lambda(x: int) { return x + 0 == x; });
writeln("Zero identity test: ", if result then "PASS" else "FAIL");
```

Run it:

```bash
chpl verify_install.chpl -o verify && ./verify
```

Expected output:

```
quickchpl version: 1.0.0
Installation successful!
Zero identity test: PASS
```

## Next Steps

- [Quick Start Guide](quick-start.md) - Get up and running in 5 minutes
- [First Property Test](first-test.md) - Write your first property test
