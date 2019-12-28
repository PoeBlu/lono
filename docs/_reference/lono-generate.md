---
title: lono generate
reference: true
---

## Usage

    lono generate

## Description

Generate both CloudFormation templates and parameters files.

Generates CloudFormation template, parameter files, and scripts in lono project and writes them to the `output` folder.

## Examples

    lono generate
    lono generate --clean
    lono g --clean # shortcut

## Example Output

    $ lono generate
    Generating CloudFormation templates, parameters, and scripts
    Generating CloudFormation templates:
      output/templates/ec2.yml
    Generating parameter files:
      output/params/ec2.json
    $


## Options

```
[--clean], [--no-clean]  # remove all output files before generating
[--quiet], [--no-quiet]  # silence the output
[--stack=STACK]          # stack name. defaults to blueprint name.
[--source=SOURCE]        # url or path to file with template

Runtime options:
-f, [--force]                    # Overwrite files that already exist
-p, [--pretend], [--no-pretend]  # Run but do not make any changes
-q, [--quiet], [--no-quiet]      # Suppress status output
-s, [--skip], [--no-skip]        # Skip files that already exist
```

