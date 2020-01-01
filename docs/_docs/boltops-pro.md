---
title: What is BoltOps Pro?
nav_order: 10
---

[BoltOps Pro](https://www.boltops.com/pro) is CloudFormation as a Service. BoltOps Pro provides reusable infrastructure-as-code provided as CloudFormation templates.  The templates are tested in a daily build process. They are completely configurable to fit your needs. Essentially, they save you time.

You can also see the list of available Pro blueprints with the [lono pro blueprints]({% link _reference/lono-pro-blueprints.md %}) command.

    $ lono pro blueprints
    +-------------------+------------------------------------------------------+-----------------------------------------+
    |       Name        |                      Docs Repo                       |               Description               |
    +-------------------+------------------------------------------------------+-----------------------------------------+
    | aurora            | https://github.com/boltopspro-docs/aurora            | RDS Aurora Database Blueprint           |
    | aurora-serverless | https://github.com/boltopspro-docs/aurora-serverless | RDS Aurora Serverless Database          |
    | bastion           | https://github.com/boltopspro-docs/bastion           | Bastion jumpbox                         |
    | cloudfront        | https://github.com/boltopspro-docs/cloudfront        | CloudFront Blueprint                    |
    | ec2               | https://github.com/boltopspro-docs/ec2               | EC2 Instance Blueprint                  |
    | ecs-asg           | https://github.com/boltopspro-docs/ecs-asg           | ECS AutoScaling Blueprint               |
    | ecs-spot          | https://github.com/boltopspro-docs/ecs-spot          | ECS Spot Blueprint                      |
    | elasticache       | https://github.com/boltopspro-docs/elasticache       | Amazon Elasticache Memcached and Red... |
    | elb               | https://github.com/boltopspro-docs/elb               | ELB Blueprint: Application or Networ... |
    | rds               | https://github.com/boltopspro-docs/rds               | RDS Database Blueprint                  |
    | sns               | https://github.com/boltopspro-docs/sns               | SNS Topic Blueprint                     |
    | vpc               | https://github.com/boltopspro-docs/vpc               | VPC blueprint: Create Reference Arch... |
    | vpc-peer          | https://github.com/boltopspro-docs/vpc-peer          | Peer VPCs across multiple accounts b... |
    | vpc-peer-one      | https://github.com/boltopspro-docs/vpc-peer-one      | VPC Peering Blueprint: Peer VPCs wit... |
    +-------------------+------------------------------------------------------+-----------------------------------------+
    $

A list of the blueprint docs is also publicly available at: [boltopspro-docs](https://github.com/boltopspro-docs).  Access to the [boltops private repos](https://github.com/boltopspro) is only available to [BoltOps Pro subscribers](https://www.boltops.com/pro). BoltOps Pro also gives you access to all the boltopspro repos.

## Configsets

The BoltOps Pro also include access to [Pro Configsets repos](https://github.com/search?q=topic%3Alono-configset+org%3Aboltopspro-docs&type=Repositories).  [Configsets]({% link _docs/configsets.md %}) are essentially configuration management.  Use configsets to configure and update your EC2 instances automatically.  Some examples of things configsets can do: install packages, create files, create users, download files, run commands, ensure services are running.

{% include prev_next.md %}
