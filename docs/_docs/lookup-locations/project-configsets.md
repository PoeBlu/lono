---
title: Project Configsets Lookup Locations
nav_order: 51
---

Project configsets are configured by you in one of the configs/BLUEPRINT/configsets folders.  Example:

configs/demo/configsets/base.rb:

```ruby
configset("httpd", resource: "Instance")
```

Project configsets are searched for in a few locations:

Location | Type | Description
--- | --- | ---
PROJECT/app/configsets | project | Your project configsets
PROJECT/vendor/configsets | vendor | Frozen vendor configsets
gems folder | gem | The gems folder is the location where the configset gem is installed. You can use `bundle show GEM` to reveal the location.
gems folder | materialized | Configsets that are dependencies of your configsets get materialized into the gems folder also.

{% include materialized-configsets.md %}

{% include prev_next.md %}
