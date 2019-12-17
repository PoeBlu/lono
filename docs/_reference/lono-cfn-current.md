---
title: lono cfn current
reference: true
---

## Usage

    lono cfn current

## Description

Current stack that you're working with.

Set current values like stack name and suffix.

{% include current-options.md %}

## Static Example

    lono cfn create demo
    lono cfn current --name demo
    lono cfn update

## Options

```
[--rm], [--no-rm]            # Remove all current settings. Removes `.lono/current`
[--name=NAME]                # Current stack name.
[--verbose], [--no-verbose]
[--noop], [--no-noop]
```

