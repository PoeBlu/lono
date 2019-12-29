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

Since configset.yml is YAML, the `indent` method is ueful to help align the text correctly.

## Configset Predefined Variables

Configsets can have predefined variables in their `lib/variables.rb` file.  Example:

app/configsets/httpd/lib/variables.rb:

```ruby
@html =<<-EOL
<h1>configset predefined variables</h1>
<p>Hello there from app/configsets/httpd/lib/variables.rb:</p>
EOL
```

## Overriding Configset Variables with configset options

You can override the predefined configset variables when you configure the configset.  Example:

configs/ec2/configsets/base.rb:

```ruby
configset("httpd", resource: "Instance", html: "<h2>html custom content</h2>")
```

## Overriding Configset Variables

You can also override configset variables with configs `variables.rb` files. You can override variables globally and override them for all configsets, or locally to the specific configset. Examples:

1. configs/ec2/configsets/variables.rb - global for all configsets used in the ec2 blueprint
2. configs/ec2/configsets/httpd/variables.rb - specific only to the httpd configset

It is recommended that you override configset variables specifically for each configset. Example:

configs/ec2/configsets/httpd/variables.rb

```ruby
@html =<<-EOL
<h1>project variables.rb override</h1>
<p>Hello there from configs/ec2/configsets/httpd/variables.rb</p>
EOL
```

## Configsets Configs are Ruby

Since the configs file is Ruby, you can use Ruby organize it however you wish. Example:

configs/ec2/configsets/httpd/variables.rb

```ruby
@html = IO.read(File.expand_path("html/index.html", __dir__))
```

configs/ec2/configsets/httpd/html/index.html:

```html
<h2>My html page</h2>
<p>Hello there from configs/ec2/configsets/httpd/html/index.html</p>
```

{% include prev_next.md %}
