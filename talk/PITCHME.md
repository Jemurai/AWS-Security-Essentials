## AWS Security Essentials

Aaron Bedra [@abedra](https://twitter.com/abedra)  
Chief Scientist, Jemurai

---

## Before we get started

---

## Cloud infrastructure offers some incredible benefits

---

## There are many reasons to take the leap

---

## But there are a lot of misconceptions about how to approach it

---

### This talk will focus on AWS, but the concepts are transferrable

---

## It's easy to get caugh up in mirroring your datacenter

---

## Just say no to lift and shift

---

## This is not a traditional datacenter

---

## And you shouldn't treat it that way

---

## There are aspects you want to keep

---

## And some you want to throw away

---

## Getting security right in the cloud requires change

---

## Key Areas

@ul

- Automation
- IAM
- Network Design
- Encryption
- Auditing
- Continuous Integration

@ulend

---

## Automation

@fa[arrow-down]

+++

# TODO: devops rainbow picture

+++

## This is a critical step

+++

## There's no excuse for ignoring automation

+++

## The platforms are built for it

+++

## Humans clicking buttons is what causes security issues

+++

## It also causes blockers, frustration, and lower velocity

+++

## If you want to keep clicking buttons, stay where you are

+++

## You shouldn't be logging into the AWS console

+++

## In fact, page the security team when it happens

+++

## Or just disable access entirely*

+++

## Infrastructure as code is step 1

+++

## It allows for review, analysis, and audit

+++

## It creates a culture of describing systems as data

+++

## The cloud is an abstraction, talk about it as one

+++

## Make peer review the only blocker between you and the end result

+++

## Automation Checklist

@ul

- All infrastructure is recorded as code
- All infrastructure changes are made by automated tools
- Console logins are restricted to administrators
- Teams are educated and empowered to make necessary changes through automation

@ulend

---

## IAM

@fa[arrow-down]

+++

## Get a grip on users and permissions

+++

## I've seen some things...

+++

## A mistake here could provide control over everything

+++

## How do we get to a good place?

+++

## Use a directory!

+++

## If you already have a directory, replicate or extend trust into AWS

+++

## Avoid keeping multiple systems of record for user accounts

+++

## This solves onboarding and offboarding issues

+++

## And automatically propagates modifications

+++

## If you don't have a directory, make sure to establish strong account requirements

+++?code=assets/snippets/password_policy.tf

@[1-1]
@[2-2]
@[3-3]
@[4-4]
@[5-5]
@[6-6]
@[7-7]

+++

## The root account

+++

## Don't use it!

+++

## Page security when it is used

+++

## There are only a handful of things you should use the root account for

+++

[https://docs.aws.amazon.com/general/latest/gr/aws_tasks-that-require-root.html](https://docs.aws.amazon.com/general/latest/gr/aws_tasks-that-require-root.html)

+++

## If it's not on that list, it's not acceptable

+++

## Now for the IAM users

+++

## The only permission IAM accounts should have is assume role

+++

## Security Token Service should be the gateway to everything

+++

## This reduces direct exposure of credentials

+++

## And forces everyone to think about the permissions required to perform a task

+++

## IAM Checklist

@ul

- Root account has MFA enabled
- Root account has no access keys*
- Users have no permissions outside of STS assume role and establish MFA device
- Users have no inline policies
- Your directory is used as the system of record
- MFA is required for all human users
- MFA is required to access privileged roles
- Users are trained and provided tools to make role assumption seamless

@ulend

---

## Network Design

@fa[arrow-down]

+++

## Network design is situation dependent

+++

## But there are a few things that matter

+++

## Create a boundary

+++

## VPC should be that boundary

+++

## Isolate environments and scope with a VPC

+++

## Monitor what comes in and out of a subnet

+++

## Be conscious about entry points

+++

## There should only be one way in

+++

## VPN or Bastion Host

+++

## Do not expose management of all machines directly!

+++

## Use tools to report on external footprint

+++

### Example

```sh
aws ec2 describe-instances
--query "Reservations[].Instances[]
.[InstanceId,PublicIpAddress,SecurityGroups[].GroupName]"

"i-02d6f02ed4cd65571",
"18.220.232.57",
"bastion_external_security_group"

"i-088a3499844e2f3b0",
"18.222.41.186",
"bastion_internal_security_group",
"api_security_group"
```

+++

## Network Design Checklist

@ul

- Everything is deployed inside a custom VPC
- Flow logs are enabled for all subnets
- Flow logs are monitored
- Everything that can has a security group attached
- Any security group with public facing 0.0.0.0/0 access justification and approval
- Remote administration is restricted to bastion hosts or internal network via VPN

@ulend

---

## Encryption

@fa[arrow-down]

+++

## TODO: IMAGE

+++

## We can all acknowledge that this is difficult

+++

## But we can reduce the chance for mistakes

+++

## KMS

+++

## This is your new default

+++

## All your encryption keys should originate from KMS

+++

## Any AWS service that stores data should have a KMS key attached

+++?code=assets/snippets/rds_plain.tf

+++?code=assets/snippets/rds_encrypted.tf

@[12-12]

+++

## There are limitations

+++

## KMS has a message limit of 4k

+++

## But it allows you to generate data encryption keys

+++

## Which provides strong randomness for key generation

+++

### This pushes you towards attaching keys to an AWS service or local crypto

+++

## Favor AWS managed encryption via KMS

+++

### If you have to move to local encryption, stick with KMS for key generation

+++

## Encryption Checklist

@ul

- All encryption keys are generated using KMS
- All KMS key have rotation enabled
- All AWS services that have a KMS option should use KMS

@ul

---

## Auditing 

@fa[arrow-down]

+++

## How do you know things are configured correctly?

+++

## Scout2

+++

## Scout2 audits configurations across all regions

+++

## It produces a report of dangerous issues

+++

## TODO Scout2 Report Image

+++

## Run this tool to see what you find

+++

## You will likely be surprised

+++

## Take some time to discuss and correct these issues

+++

## This helps with audit of configuration

+++

## But what about user activity?

+++

## CloudTrail/CloudWatch

+++

## These tools are invaluable

+++

## They are an absolute must for anyone taking security seriously

+++

## Enable CloudTrail for all regions

+++

## Use CloudWatch to establish alerts on behavior

+++

## Alert Examples

@ul

- Root account login
- Root account key usage
- New user created
- User added to administrative roles

@ul

+++

## Or better yet, use a third party

+++

## You don't have to manage everything on your own

+++

## AWS GuardDuty

+++

## TODO: Explanation

+++
