## Configset Example

Here's an simple configset example:

```yaml
AWS::CloudFormation::Init:
  config:
    packages:
      yum:
        httpd: []
    services:
      sysvinit:
       httpd:
        enabled: 'true'
        ensureRunning: 'true'
```
