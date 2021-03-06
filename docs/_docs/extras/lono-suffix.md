---
title: Lono Suffix
categories: extras
nav_order: 61
---

When working with CloudFormation templates and developing the source code, we must often launch stacks repeatedly as we fine tune the stack. Since we cannot launch a stack with a duplicate name it is useful to use a command like this:

    lono cfn create my-stack-$(date +%s) --template my-stack

Lono can automatically add a suffix string to the end of the stack name but use the template name without the suffix string. You can set a suffix on the stack name you create with lono to help improve your development workflow.  Here are the ways to you can set a suffix and their order of precedence from highest to lowest.

1. lono cfn create stack-name -\-suffix=random
2. LONO_SUFFIX=mysuffix
3. lono cfn current -\-suffix mysuffix
4. configs/settings.yml stack_name_suffix option. More docs in [Settings]({% link _docs/configuration/settings.md %})

## Random Suffix

When the option is set to random, then it'll create a random suffix that can help speed up your creation development workflow.  Example:

    lono cfn create autoscaling

Will create a "autoscaling-[RANDOM]" using the autoscaling template name.  The random string is a short 3 character string.  So it results in something like this:

    lono cfn create autoscaling-abc --template autoscaling

## Workflow Example

Random suffixes can help streamlined your development workflow.

    lono cfn current --suffix random
    lono cfn create demo
    lono cfn update demo-abc # generated random suffix was abc
    lono cfn current --name demo-abc
    lono cfn update
    lono cfn update # update again

In this way, you can create multiple stacks continuously and random suffixes will be appended to the stack name. Then set the current stack name to the one are focused on updating and developing.

NOTE: The suffix feature is deprecated and will be removed in future.

{% include prev_next.md %}
