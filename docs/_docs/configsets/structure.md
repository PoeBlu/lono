---
title: Configset Structure
categories: configsets
order: 1
nav_order: 21
---

Here's an example configset structure:

```sh
├── lib
│   ├── configset.yml
│   └── meta.rb
└── httpd.gemspec
```

File | Description
--- | ---
configset.yml | The configset code.  The top-level key should be `AWS::CloudFormation::Init`.
meta.rb | Meta info about the configset. Currently supports one method `depends_on`. You can use to specify other configsets as dependencies.
httpd.gemspec | A standard gemspec definition. Configsets can be packaged as gems.

{% include configset-example.md %}

## meta.rb example

lib/meta.rb

```ruby
depends_on "amazon-linux-extras"
```

{% include prev_next.md %}
