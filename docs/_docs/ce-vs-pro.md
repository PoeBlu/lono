---
title: Community Edition vs Pro
nav_order: 7
---

Lono Community Edition is the core of lono.  It is available for free under a [Source Available license](https://www.boltops.com/boltops-community-license).

Lono Pro is an addon that adds extra commands to lono that are helpful for [BoltOps Pro subscribers](https://boltops.com/pro). The lono-pro addon is also available for free.

## What's the Difference Between the Community Edition vs Pro?

&nbsp; | Community | Pro
--- | --- | ---
CFN Lifecycle commands | ![](/img/features/yes.svg) | ![](/img/features/yes.svg)
ERB Template Generator | ![](/img/features/yes.svg) | ![](/img/features/yes.svg)
DSL Generator | ![](/img/features/yes.svg) | ![](/img/features/yes.svg)
Reusable Blueprints Structure | ![](/img/features/yes.svg) | ![](/img/features/yes.svg)
Import and Convert commands | ![](/img/features/no.svg) | ![](/img/features/yes.svg)
BoltOps Pro related commands | ![](/img/features/no.svg) | ![](/img/features/yes.svg)

## Lono Pro Addon: Code Import and Convert Commands

Lono features a powerful DSL to build CloudFormation templates. The Lono DSL builds on top of the CloudFormation declarative nature and allows you to write **Infrastructure as Code**. The Lono DSL results in more maintainable code. Most CloudFormation templates in the wild are written in JSON or YAML though.

The [lono code convert](https://lono.cloud/reference/lono-code-convert/) and [lono code import](https://lono.cloud/reference/lono-code-import/) commands allow you to take JSON or YAML templates and convert it to the Lono DSL code. The conversion process saves you engineering time writing it yourself.

## What are BoltOps Pro Blueprints?

BoltOps Pro blueprints are reusable CloudFormation templates built and managed by BoltOps.  They are configurable to fit your needs. They are also documented and tested in a daily build process. Essentially, they save you time.

A list of the blueprints is available at: [boltopspro-docs](https://github.com/boltopspro-docs).  Access to the [boltops repos](https://github.com/boltopspro) is only avaiable to [BoltOps Pro subscribers](https://www.boltops.com/pro).

## Docs

The docs for both Lono Community Edition and additional Pro commands are on [lono.cloud](https://lono.cloud). Pro commands are noted accordingly.

{% include prev_next.md %}
