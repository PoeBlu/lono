---
title: lono sets
categories: stack-sets
---

Lono supports [CloudFormation stack sets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html).  This allows you to deploy stacks to multiple accounts and regions.

## Commands Summary

The main commands for stack sets are:

    lono sets deploy
    lono sets instances sync

The `lono sets deploy` command deploys the stack set. You then use the `lono sets instances sync` command to add or remove stack instances.

## Example

First, deploy a stack set.

    lono sets deploy my-set --blueprint demo

Then configure the accounts and regions to add stacks instances. You can do this with the configs files.

configs/demo/accounts/development/my-set.txt

    112233445566

configs/demo/regions/development/my-set.txt

    us-east-1
    us-east-2

Then add the stack sets:

    lono sets instances sync my-set --blueprint demo

The `lono sets instances sync` calculates that stack instances needed to be added accordingly. If you remove regions from the configs and rerun it, it will remove the appropriate stack instances.

Later if you need to update the stack set main template itself. You can update your blueprint and use `lono sets deploy` to deploy to all the current stack instances.  Example:

    lono sets deploy my-set --blueprint demo

Note: the `lono sets deploy` will not *sync* stack instances. It only deploys to the current stack instances. To sync stack instances, you must explicitly use the `lono sets instances sync` command.

## Deleting Stack Sets

To delete a stack set, you must first delete all the stack instances associated with the set. Then you can delete the stack set. Here's an example

    lono sets instances delete my-set --all
    lono sets delete my-set

{% include prev_next.md %}
