## UserData cfn-init

Make sure to call the cfn-init script as part of the UserData launch script to apply the configsets.  Here's a UserData example script.

```bash
#!/bin/bash
yum install -y aws-cfn-bootstrap # install cfn-init
/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource Instance --region ${AWS::Region}
```

The `${AWS::StackName}` and `${AWS::Region}` will be substituted for their actual values at CloudFormation runtime.  The `--resource Instance` tells the `cfn-init` script the resource used to grab the `Metadata.AWS::CloudFormation::Init` attribute with the configsets.

Note: On AmazonLinux2 cfn-init is already installed.
