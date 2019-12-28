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
configset("httpd", resource: "Instance", var1: "foo", var2: "bar", html: "<h2>html content</h2>")
```

This makes `var1`, `var2`, and `html` available as instance variables in the `configset.yml` definition.

## Configset ERB

The `configset.yml` is processed as ERB before being loaded into the CloudFormation template.  You can ERB to refer to the variables:

Example:

```yaml
AWS::CloudFormation::Init:
  config:
    packages:
      yum:
        httpd: []
    files:
      "/var/www/html/index.html":
        content: |
<%= indent(@html, 10) %>
    services:
      sysvinit:
       httpd:
        enabled: 'true'
        ensureRunning: 'true'
```

Since configset.yml is YAML, the `indent` method is ueful to help the text correctly.

## Configset Predefined Variables

Configsets can have predefined variables in their `lib/variables.rb` file.  Example:

app/configsets/httpd/lib/variables.rb:

@html =<<-EOL
<h1>hello there from variables.rb</h1>
<p>This is my page</p>
EOL

{% include prev_next.md %}
