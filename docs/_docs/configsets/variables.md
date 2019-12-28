---
title: Configset Variables
nav_text: Variables
categories: configsets
order: 3
nav_order: 25
---

When you use the `configset` method to add a configset to your blueprint, you can pass it variables.  Example:

configs/ec2/configsets/base.rb:

```ruby
configset("httpd", resource: "Instance", var1: "foo", var2: "bar")
```

This makes `var1` and `var2` available as instance variables in the `configset.yml` definition.

## Configset ERB

The `configset.yml` is processed as ERB before being loaded into the CloudFormation template.  You can ERB to refer to the variables:

Example:

```yaml
AWS::CloudFormation::Init:
  config:
    packages:
      yum:
        httpd: []
    services:
      sysvinit:
       httpd:
        enabled: 'true'
        ensureRunning: 'true'
```

{% include prev_next.md %}
