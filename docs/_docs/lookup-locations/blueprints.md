---
title: Blueprint Lookup Locations
nav_order: 50
---

Blueprints encapsulation CloudFormation templates in a convenient and reusable way.  Blueprints are searched for in a few locations:

Location | Type | Description
--- | --- | ---
PROJECT/app/blueprints | project | Your project blueprints
PROJECT/vendor/blueprints | vendor | Frozen vendor blueprints
gems folder | gem | The gems folder is the location where the blueprint gem is installed. You can use `bundle show GEM` to reveal the location.

{% include prev_next.md %}
