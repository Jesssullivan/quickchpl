---
title: Generators Concept
description: "Generators create random test data. Basic types: intGen, realGen, boolGen, stringGen. Composite: tupleGen, listGen. Transform with map, filter, oneOf."
---

# Generators

Generators are the heart of property-based testing. They create random test data that exercises your properties.

## Overview

```mermaid
graph TB
    subgraph "Basic Generators"
        INT[intGen]
        REAL[realGen]
        BOOL[boolGen]
        STR[stringGen]
    end

    subgraph "Composite Generators"
        TUPLE[tupleGen]
        LIST[listGen]
    end

    subgraph "Combinators"
        MAP[map]
        FILTER[filter]
        ONEOF[oneOf]
        FREQ[frequency]
    end

    INT --> TUPLE
    REAL --> TUPLE
    BOOL --> TUPLE
    STR --> LIST
    TUPLE --> MAP
    LIST --> FILTER
    MAP --> ONEOF
