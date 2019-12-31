---
title: Configsets
nav_order: 20
---

Configsets are a way to configure your EC2 instances. Configsets are essentially configuration management.

They work with [AWS::CloudFormation::Init](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-init.html) and [cfn-init](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-init.html). Use configsets to configure and update your EC2 instances automatically. Lono allows you to use configsets in a reusable way.

## Configuration Management Tool

There are several configuration management tools out there: [chef](https://www.chef.io/configuration-management/), [puppet](https://puppet.com/), [ansible](https://www.ansible.com/), [salt](https://docs.saltstack.com/en/latest/), [configsets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-init.html).  They all perform these 3 steps:

1. Install a package
2. Configure it
3. Run it as a Service

{% include configsets/example.md %}

## Reusable Configsets

Typically, configsets are directly hardcoded into the CloudFormation template. Unfortunately, this makes them hard to reuse. With Lono, configsets are separate files. This allows them to be reusable. Lono takes the separate configset files and injects them into your CloudFormation templates.

## Usage

Your project configsets are located in the `app/configsets`. Example:

* app/configsets/cfn-hup/lib/configset.yml
* app/configsets/httpd/lib/configset.yml

You tell lono to add them into your CloudFormation templates with configs. Example:

configs/ec2/configsets/base.rb:

```ruby
configset("cfn-hup", resource: "Instance")
configset("httpd", resource: "Instance")
```

This installs cfn-hup and httpd on the EC2 instance.

More specifically, lono injects the 2 configsets to the CloudFormation template resource with the logical id `Instance`.  The cfn-hup and httpd configsets are added to the `Instance.Metadata.AWS::CloudFormation::Init` attribute.

You have full control over which configsets to use for each template.

{% include configsets/cfn-init.md %}

The Lono configsets concept empowers you to use configsets in a reusable and managable way.

{% include prev_next.md %}
