---
title: Configset Structure
nav_text: Structure
categories: configsets
order: 1
nav_order: 21
---

Here's an example lono configset structure:

```sh
├── lib
│   ├── configset.yml
│   └── meta.rb
└── httpd.gemspec
```

File | Description
--- | ---
configset.yml | The configset code.  The top-level key should be `AWS::CloudFormation::Init`. This is required.
meta.rb | Additional meta info about the configset. Currently supports `depends_on`, to specify other configsets as dependencies. This is optional.
httpd.gemspec | A standard gemspec definition, allows configsets to be packaged as gems.  This is required.

## lono configset new

{% include lono-configset-new.md %}

{% include configset-example.md %}

## meta.rb example

lib/meta.rb

```ruby
depends_on "amazon-linux-extras"
```

{% include prev_next.md %}
