---
title: Parameter
category: dsl
desc: Use the optional Parameters section to customize your templates. Parameters
  enable you to input custom values to your template each time you create or update
  a stack.
nav_order: 24
---

The `parameter` method maps to the CloudFormation Template Anatomy [Parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html) section.

## Example Snippets

There are 3 forms for conditions.  Here are example snippets:

```ruby
# short form
parameter(:ami_id)            # no default, so this is a required parameter
parameter(:image_id, "ami-123") # default is ami-123

# medium form
parameter(:company, default: "boltops", description: "instance type")

# long form
parameter(instance_type: {
  default: "t2.micro" ,
  description: "instance type" ,
})
```

## Example Outputs

```yaml
Parameters:
  AmiId:
    Type: String
  ImageId:
    Default: ami-123
    Type: String
  Company:
    Default: boltops
    Description: instance type
    Type: String
  InstanceType:
    Default: t2.micro
    Description: instance type
    Type: String
```

{% include back_to/dsl.md %}

{% include prev_next.md %}