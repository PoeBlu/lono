---
title: Blueprint Configsets Lookup Locations
nav_order: 59
---

Blueprint configsets are configured within a blueprint in it's `config/configsets.rb` file.  Example:

app/blueprints/demo/config/configsets.rb:

```ruby
configset("httpd", resource: "Instance")
```

Blueprint configsets are searched for in a few locations:

Location | Type | Description
--- | --- | ---
BLUEPRINT/app/configsets | blueprint | The blueprint's local configsets
PROJECT/vendor/configsets | vendor | Frozen vendor configsets
gems folder | gem | The gems folder is the location where the configset gem is installed. You can use `bundle show GEM` to reveal the location.
gems folder | materialized | All blueprint configsets and their dependency configset are materialized as gems.

{% include materialized-configsets.md %}

{% include prev_next.md %}
