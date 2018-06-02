## Deploy

See [README](/README.md#deploy-to-aws) for a UI based deploy process.

To deploy programmatically, we use the [AWS Command Line Interface](https://aws.amazon.com/cli/).
In addition, install [jq](https://stedolan.github.io/jq/), e.g. `brew intsall jq`

First, create a new policy [here](https://console.aws.amazon.com/iam/home?region=eu-central-1#/policies$new?step=edit) and enter:

```sh
"Statement":[{
  "Effect":"Allow",
  "Action":[
    "cloudformation:DescribeStackEvents",
    "cloudformation:CreateStack",
    "cloudformation:GetTemplate",
    "cloudformation:DeleteStack",
    "cloudformation:DescribeStackResources",
    "cloudformation:UpdateStack",
    "cloudformation:CreateChangeSet",
    "cloudformation:CreateStackInstances",
    "cloudformation:ValidateTemplate",
    "cloudformation:GetTemplateSummary",
    "cloudformation:ListChangeSets",
    "cloudformation:DescribeStacks",
    "cloudformation:DescribeStackResource",
    "ec2:DescribeKeyPairs",
    "ec2:CreateSecurityGroup",
    "ec2:DescribeSecurityGroups",
    "ec2:DeleteSecurityGroup",
    "ec2:AuthorizeSecurityGroupIngress",
    "ec2:allocateAddress",
    "ec2:describeAddresses",
    "ec2:releaseAddress",
    "ec2:associateAddress",
    "ec2:RunInstances",
    "ec2:StartInstances",
    "ec2:StopInstances",
    "ec2:ModifyInstanceAttribute",
    "ec2:DescribeInstances",
    "ec2:DescribeInstanceStatus",
    "ec2:TerminateInstances",
    "ec2:createTags",
    "ec2:deleteTags",
    "ec2:describeTags",
    "ec2:createVolume",
    "ec2:describeVolumes",
    "ec2:deleteVolume"    
  ],
  "Resource":"*"
}]
```

Click "Review Policy", call it Matreon.

Now create an API user [here](https://console.aws.amazon.com/iam/home?region=eu-central-1#/users$new?step=details) and check "Programmatic access". On the next screen select "Attach existing policies directly" and check the box next to the policy you just created. Then proceed to "Next: Review", and "Create User".

You can then login using the credentials shown: `aws configure --profile matreon`, make sure to enter `eu-central-1` for "Default region name". Once logged in, you can deploy the template:
 
```sh
export AWS_PROFILE=matreon
export STACK=Matreon
export KEY_NAME=Matreon
export NETWORK=testnet
export HOSTNAME=http://example.com
export FROM_EMAIL=you@expample.com
export BUGS_TO=bugs@example.com
export SMTP_HOST=smtp.fastmail.com
export SMTP_PORT=587
export SMTP_USERNAME=...
export SMTP_PASSWORD=...

export GIT_URL=https://github.com/Sjors/matreon.git
export GIT_BRANCH=`git rev-parse --abbrev-ref HEAD` # don't forget to push if you're working on a branch

aws cloudformation create-stack --template-body file:///$PWD/vendor/AWS/Matreon.Template --stack-name $STACK --parameters ParameterKey=Network,ParameterValue=$NETWORK ParameterKey=KeyName,ParameterValue=$KEY_NAME ParameterKey=HostName,ParameterValue=$HOSTNAME ParameterKey=FromEmail,ParameterValue=$FROM_EMAIL ParameterKey=BugsEmail,ParameterValue=$BUGS_TO ParameterKey=SmtpHost,ParameterValue=$SMTP_HOST ParameterKey=SmtpPort,ParameterValue=$SMTP_PORT ParameterKey=SmtpUser,ParameterValue=$SMTP_USERNAME ParameterKey=SmtpPassword,ParameterValue=$SMTP_PASSWORD ParameterKey=GitURL,ParameterValue=$GIT_URL ParameterKey=GitBranch,ParameterValue=$GIT_BRANCH
```

You can follow the progress in the [management console](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks) or:

```sh
aws cloudformation describe-stack-events --stack-name=$STACK
```

Alternatively you watch the resources as they are created. 

```sh
aws cloudformation describe-stack-resources --stack-name=$STACK
```

In order to login to our new machine, we need to know its instance id:

```sh
export INSTANCE_ID=`aws cloudformation describe-stack-resources --stack-name=$STACK | jq '.StackResources[] | select(.LogicalResourceId == "WebServer").PhysicalResourceId' --raw-output`
export SSH_HOSTNAME=`aws ec2 describe-instances --instance-ids $INSTANCE_ID | jq '.Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName' --raw-output`
ssh ec2-user@$SSH_HOSTNAME -i ~/.ssh/Matreon.pem
```

To follow the provisioning process:

```sh
tail -f /var/log/cfn-init-cmd.log
```

At some point in the process the temporary IP is changed to a permanent one, so you'll have to $HOSTNAME.

Wait for the machine to finish initial blockchain download and shut itself down. Downgrade and restart:

```sh
aws ec2 stop-instances --instance-ids $INSTANCE_ID
aws ec2 describe-instance-status --instance-ids $INSTANCE_ID # Until it's stopped
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --attribute instanceType --value t2.small
aws ec2 start-instances --instance-ids $INSTANCE_ID
```

To clean up:

```sh
aws cloudformation delete-stack --stack-name=$STACK
```
