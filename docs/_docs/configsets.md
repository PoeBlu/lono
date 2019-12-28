---
title: Configsets
nav_order: 20
---

Configsets are a way to configure your EC2 instances. They work with the [AWS::CloudFormation::Init](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-init.html) and [cfn-init](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-init.html). You can use them to automatically configure and update your EC2 instances. Lono allows you to leverage configsets in a reusable way.

## Configuration Management Tool

Essentially, it's a lightweight configuration management tool.  There are several configuration management tools out there: [chef](https://www.chef.io/configuration-management/), [puppet](https://puppet.com/), [ansible](https://www.ansible.com/), [salt](https://docs.saltstack.com/en/latest/).  They all, including configsets, are usually used to perform these 3 steps:

1. Install a package
2. Configure it
3. Run it as a Service

{% include configset-example.md %}

This configset installs and ensures the httpd is running, even when the server is rebooted.

## Lono Makes Them Reusable

Typically, configsets are written directly into the CloudFormation template. Unfortunately, this makes them hard to reuse. With Lono, you instead write your configsets as separate files. Lono then to inject them into your CloudFormation templates as you wish.

## Usage

Your project configsets are located in the `app/configsets`. Example:

* app/configsets/httpd/lib/configset.yml
* app/configsets/php/lib/configset.yml

You tell lono to inject them into your CloudFormation templates with blueprint specfic configs. Example:

configs/ec2/configsets/base.rb:

```ruby
configset("httpd", resource: "Instance")
configset("php", resource: "Instance")
```

This installs httpd and php on the EC2 Instance.

More specifically, lono injects the 2 configsets, httpd and php, to the CloudFormation template resource with the logical id `Instance`.  The configsets are merged and added to the `Instance.Metadata.AWS::CloudFormation::Init` attribute.  You have full control over which configsets to use for the EC2 instance.

Just make sure to call the cfn-init script as part of the UserData launch script apply the configsets to the `Instance`.

## UserData cfn-init

Here's a UserData example script that calls cfn-init to  apply the configsets when the instance is launched.

```bash
#!/bin/bash
yum install -y aws-cfn-bootstrap # install cfn-init
/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource Instance --region ${AWS::Region}
```

The `${AWS::StackName}` and `${AWS::Region}` will be substituted for their actual values at CloudFormation runtime.  The `--resource Instance` tells the `cfn-init` script what resource to grab the configsets `Metadata.AWS::CloudFormation::Init` attribute from.

Note: On AmazonLinux2 cfn-init is already installed.

Lono empowers you to use configsets in a reusable and easy way.

{% include prev_next.md %}
