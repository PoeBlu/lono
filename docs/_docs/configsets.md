---
title: Configsets
nav_order: 20
---

Configsets are a way to configure your EC2 instances. They work with the [AWS::CloudFormation::Init](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-init.html) and [cfn-init](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-init.html). You can use them to configure and update your EC2 instances automatically. Lono allows you to leverage configsets in a reusable way.

## Configuration Management Tool

Essentially, it's a lightweight configuration management tool.  There are several configuration management tools out there: [chef](https://www.chef.io/configuration-management/), [puppet](https://puppet.com/), [ansible](https://www.ansible.com/), [salt](https://docs.saltstack.com/en/latest/).  They all, including configsets, can do these 3 steps:

1. Install a package
2. Configure it
3. Run it as a Service

{% include configset-example.md %}

This configset installs and ensures the httpd is running, even after the server is rebooted.

## Lono Makes Them Reusable

Typically, configsets are directly hardcoded into the CloudFormation template. Unfortunately, this makes them hard to reuse. With Lono, you instead write your configsets as separate files. Lono injects them into your CloudFormation templates as you wish.

## Usage

Your project configsets are located in the `app/configsets`. Example:

* app/configsets/httpd/lib/configset.yml
* app/configsets/php/lib/configset.yml

You tell lono to inject them into your CloudFormation templates with configs. Example:

configs/ec2/configsets/base.rb:

```ruby
configset("httpd", resource: "Instance")
configset("php", resource: "Instance")
```

This installs httpd and php on the EC2 instance.

More specifically, lono injects the 2 configsets to the CloudFormation template resource with the logical id `Instance`.  The httpd and php configsets are merged and added to the `Instance.Metadata.AWS::CloudFormation::Init` attribute.

By using `configs/ec2/configsets/base.rb`, you have full control over which configsets to use.

{% include cfn-init.md %}

The Lono configsets concept empowers you to use configsets in a reusable and easy way.

{% include prev_next.md %}
