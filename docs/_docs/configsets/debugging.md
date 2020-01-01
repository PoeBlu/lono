---
title: 'Debugging Tips: cfn-init and configsets'
nav_text: Debugging Tips
categories: configsets
order: 4
nav_order: 27
---

Here are some debugging tips that will help when working with cfn-init.

## How It Works

The cfn-init script is usually called by the UserData script to kick off a bootstrap process.

{% include configsets/cfn-init.md %}

## Run Manually

The UserData script runs at launch time automatically.  But you can also invoke the `cfn-init` script manually. Just log into the instance and call it.  This can be especially useful for debugging. Here's an example of running the script.

    /opt/aws/bin/cfn-init -v --stack my-stack --resource Instance --region us-west-2

The command above downloads the Configset from CloudFormation template `Instance` resource and applies it.

## Where is the metadata.json downloaded?

The `cfn-init` downloads the configset metadata to:

    /var/lib/cfn-init/data/metadata.json

Note, this file gets overwritten each time `cfn-init` runs.

## Run With a File

One quick way to debug configsets is to copy the generated `/var/lib/cfn-init/data/metadata.json`, modify it, and provide it directly to the `cfn-init` command. Example:

    cp /var/lib/cfn-init/data/metadata.json /root/configset.json
    /opt/aws/bin/cfn-init -v /root/configset.json

The cfn-init script itself only supports JSON when providing a file.

Here's a [YAML to JSON One Liner](https://blog.boltops.com/2017/09/16/json-to-yaml-one-liner) to to help you convert it.

    ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))' < configset.yml > configset.json

And vice-versa:

    ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))' < configset.json > configset.yml

## Where are the Logs?

Knowing where the cfn-init related logs are can also save a ton of time.

Path | Description
--- | ---
/var/log/cfn-init-cmd.log | cfn-init and command output with timestamps.
/var/log/cfn-init.log | cfn-init and command output. Useful for when cfn-init is manually ran.
/var/log/cloud-init.log | cloud-init logs from UserData launch script.
/var/log/cloud-init-output.log | Output from the cloud-init UserData commands themselves. Useful for when the instance is launched for the first time.

## cfn-hup reloader

The UserData script runs **only** at launch time.  This means if you make changes to the CloudFormation `Metadata.AWS::CloudFormation::Init` configset, they do not magically get applied.  The [cfn-hup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-hup.html) daemon must be set up. The cfn-hup daemon listens for changes in the metadata and applies them automatically.

It is recommended to set up cfn-hup reloader, so you do not have to log into the instance and kick off the cfn-init script manually.

Here's an [example cfn-hup configset](https://gist.github.com/tongueroo/2c6db800d262ac87eef5196a5b5abe01) that will set up the cfn-hup reloader.  Remember to replace `RESOURCE_ID` in the example with the actual CloudFormation template resource that holds the metadata.  The [cfn-hup configset] is also available as a [BoltOps Pro configset](https://github.com/boltopspro-docs/cfn-hup)

{% include prev_next.md %}
