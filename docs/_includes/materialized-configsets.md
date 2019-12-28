## Materialized Configsets

Usually, you specify a configset in Gemfile. Then you use `bundle` to install the configset gem locally.

Sometimes configsets are not specified by you though. Instead they are inferred by a blueprint or dependency of another configset.  These types of configsets are automatically downloaded or "materialized" as required.