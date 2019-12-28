---
title: Blueprint Configsets
nav_text: Blueprint
nav_order: 24
---

Blueprint configsets are configsets added by blueprints. This allows blueprint to prepackaged configsets, so you don't have to as part of your project's configsets.

## Example

The blueprint specifies configsets to use in its `config/configsets.rb` file. Example:

app/blueprints/ec2/config/configsets.rb:

```ruby
configset("httpd")
```

This means the ec2 blueprint will use the httpd configset to install and run the httpd server.

## List Blueprint Configsets

Use the [lono blueprint configsets](/reference/lono-blueprint-configsets/) command to see what configsets the blueprint is configured with.  The command is useful to help see the configsets path resolutions.

    $ lono blueprint configsets ec2
    Final configsets being used for ec2 blueprint:
    +-------+----------------------+---------+-----------+
    | Name  |         Path         |  Type   |   From    |
    +-------+----------------------+---------+-----------+
    | httpd | app/configsets/httpd | project | blueprint |
    +-------+----------------------+---------+-----------+
    $

## Blueprint Configset Lookup Precedence

The blueprint configset definitions themselves are looked up in different locations. The search order for these locations are:

1. BLUEPRINT/app/configsets - prepackaged with the blueprint
2. PROJECT/vendor/configsets - vendorized configset, provides you control over the configset
3. PROJECT/Gemfile - configets as gems, provides you control over the configset
4. MATERIALIZED - materialized as gems. lono downloads and "materializes" the configset if necessary.

This allows blueprint configsets to be overrideable and provides you with more control if necessary.

{% include prev_next.md %}
