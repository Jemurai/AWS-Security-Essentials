## AWS Security Essentials

Aaron Bedra [@abedra](https://twitter.com/abedra)  
Chief Scientist, Jemurai

---
@title[Agenda]

## Agenda

- Setup
- Auditing
- IAM
- Network Design
- Encryption and Key Management
- Wrap Up

---

## Setup

@fa[arrow-down]

+++
@title[list]

## Checklist

- A clone of this repository
- Docker
- Terraform
- AWS Command Line (awscli)
- An AWS account with admin permissions

---

## Terraform

@fa[arrow-down]

+++

## Infrastructure Automation

+++

### As noted in the intro talk, this is an important first step

+++

### We will be using terraform throughout the workshop to setup our AWS resources

+++

## There are other automation options

+++

## To save time please use the terraform code provided

+++

## Feel free to translate this code to any other tool of your choice

+++

## And don't hesitate to ask any questions

+++

### Create a bucket for the workshop

```sh
aws s3 mb s3://abedra-tfstate --region us-east-2
```

+++

## Before we start terraform, let's look at our first script

+++?code=workshop/terraform/setup.tf
@title[Setup]

@[1-3]
@[5-12]
@[14-20]

+++

### Initialize Terraform

```sh
workshop/terraform> terraform init
```

+++

### Import the bucket we just created

```sh
workshop/terraform> terraform import             \
                    aws_s3_bucket.abedra-tfstate \
                    abedra-tfstate
```

+++

### Finally, we apply our changes

```sh
workshop/terraform> terraform plan
workshop/terraform> terraform apply
```

+++

### Throughout the workshop we will use this bucket to store our terraform state

+++

### Check the bucket

```sh
aws s3 ls s3://abedra-tfstate/setup --recursive
2018-05-18 10:19:28       1845 setup/terraform.tfstate
```

+++

### You don't have to store your `tfstate` in `S3` during this workshop

+++

### But if you are working with others in the same account it is recommended

+++

## Questions?

---

## Auditing

@fa[arrow-down]

+++

## How do we track what our users are doing?

+++

## Cloudtrail

+++

## Cloudtrail logs all activity to the AWS API

+++

### These logs provide actionable data that you can use to automate security response

+++

### This is vital to to the auditing process

+++

### And it gives you a way to track every action taken on the platform

+++

## The output of Cloudtrail will go to S3

+++

### You can use more advanced tooling to process CloudTrail events and issue alerts

+++

## One of these tools is GuardDuty

+++

### GuardDuty analyzes CloudTrail and alerts on known security issues

+++

### It monitors outbound network connections and flags contact with known bad actors

+++

### It monitors dns requests and flags queries that resolve to known bad actors

+++

## It alerts on overexposure of resources

+++

### And it alerts when overexposed resources are probed or attacked

+++

### It's new and under active development, so look for more features very soon

+++

### Initialize terraform in the auditing directory

```sh
workshop/auditing> terraform init
```

+++

## Now let's review what we are going to add

+++?code=workshop/auditing/setup.tf

@[1-3]
@[5-11]
@[13-13]
@[15-16]
@[18-21]
@[23-24]
@[28-29]
@[31-34]
@[36-37]
@[39-44]
@[48-51]
@[53-56]
@[58-64]
@[66-68]

+++

### Deploy CloudTrail and GuardDuty

```sh
workshop/auditing> terraform plan
workshop/auditing> terraform apply
```

+++

### Check the audit bucket

```sh
aws s3 ls s3://abedra-audit --recursive
2018-06-11 12:10:51          0 audit/AWSLogs/489175270805/
```

+++

### Examine the events

```json
{
  "eventVersion":"1.02","userIdentity": {
      "...SNIP..."
  },
  "eventTime":"2017-11-24T22:12:51Z",
  "eventName":"GetAccountPasswordPolicy",
  "sourceIPAddress":"199.27.255.43",
  "requestID":"9c81b384-d164-11e7-b896-bb38c46dd0a0",
  "eventID":"35ba2cdd-7b76-40bc-aeca-3b7283518bae",
  "eventType":"AwsApiCall","recipientAccountId":"489175270805"
}
```

+++

### How do we know our AWS configuration doesn't have security issues?

+++

## Questions

@ul

- Do all our users have MFA enabled?
- Do we have inactive users?
- Do we have security groups that expose too much?
- Do we have S3 buckets with improper access control?
- How do we know that our users aren't abusing their permissions?

@ulend

+++

### Let's ask!

```sh
workshop/auditing/mfa> docker build -t mfa_audit .
workshop/auditing/mfa> docker run \
-e AWS_ACCESS_KEY_ID=XXX          \
-e AWS_SECRET_ACCESS_KEY=xxx      \
mfa_audit
[]
```

```sh
workshop/auditing/inactive> docker build -t inactive_user_audit .
workshop/auditing/inactive> docker run \
-e AWS_ACCESS_KEY_ID=XXX          \
-e AWS_SECRET_ACCESS_KEY=xxx      \
inactive_user_audit
[]
```

+++

## We could go on all day with one off scripts

+++

### Let's try something a little more effective

```sh
workshop/auditing/scout2> docker build -t scout .
workshop/auditing/scout2> docker run \
-p 22222:80                   \
-e AWS_ACCESS_KEY_ID=XXX      \
-e AWS_SECRET_ACCESS_KEY=xxx  \
scout
```

+++

### Navigate to [localhost:2222](http://localhost:22222)

```fundamental
Fetching IAM config..
... Lots of output ...
*** Visit ***

http://localhost:22222

*** to view the report ***
```

+++

## What we just ran is called Scout2

+++

## Walkthrough

+++

### There is also commercial tooling, but this is a great way to get started

+++

## Exercise: Fix the issues

+++

### Pick and choose your battles, not everything you find is an emergency

+++

## Let's walk through a real world scenario

+++

[https://aws.amazon.com/blogs/security/how-to-receive-notifications-when-your-aws-accounts-root-access-keys-are-used](https://aws.amazon.com/blogs/security/how-to-receive-notifications-when-your-aws-accounts-root-access-keys-are-used)

+++

### Alarms like this are key in detecting and understanding a breach

+++

### Other Alarm Possibilities

@ul

- Unusually high amout of KMS actions
- New user created
- Access keys created for the root account
- Access keys used for the root account
- Anyone logs into the AWS console
- Anything that would signal unexpected behavior

@ulend

+++

### GuardDuty triggers alerts, but you can define alerts on additional conditions

+++

## Questions?

---

## IAM

@fa[arrow-down]

+++

## This is the foundation

+++

## Locking down access is incredibly important

+++

## In fact, users shouldn't have any permissions

+++

### They should only be able to assume roles that provide required access

+++

## This makes the console obsolete

+++

### But it requires you to have a high degree of automation

+++

### If you do it right, people won't care what cloud provider they are using

+++

## Let's take a look at the setup

+++?code=workshop/iam/setup.tf

@[1-3]
@[5-11]
@[22-24]
@[26-28]
@[30-37]
@[39-46]
@[48-48]
@[50-61]
@[63-67]
@[69-69]
@[71-71]
@[73-76]
@[78-78]
@[80-84]
@[88-92]
@[94-100]
@[102-107]
@[109-115]
@[117-122]
@[124-128]
@[130-134]
@[136-140]
@[142-146]

+++

### Deploy the changes

```sh
workshop/iam> terraform init
workshop/iam> terraform plan
workshop/iam> terraform apply
```

+++

### Verify the changes

```sh
aws iam list-roles --query 'Roles[].RoleName'
[
    "admin",
    "AWSServiceRoleForAmazonGuardDuty",
    "read_only"
]
```

```sh
aws iam list-attached-role-policies --role-name admin
{
    "AttachedPolicies": [
        {
            "PolicyName": "AdministratorAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess"
        }
    ]
}
```

+++

### Grab keys for each of the newly created users

```sh
aws iam create-access-key --user-name audit \
--query 'AccessKey.[AccessKeyId,SecretAccessKey]'
[
    "XXX",
    "XXX"
]
```

```sh
aws iam create-access-key --user-name operator \
--query 'AccessKey.[AccessKeyId,SecretAccessKey]'
[
    "XXX",
    "XXX"
]
```

+++

## How do we use these roles?

+++

## We do it through STS

+++

### Security Token Service provides temporary, limited credentials

+++

### Before we try STS we need to know the arn of the role we want to assume

+++

### List role arns

```sh
aws iam list-roles --query 'Roles[].Arn'
[
    "arn:aws:iam::489175270805:role/admin",
    "arn:aws:iam::489175270805:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty",
    "arn:aws:iam::489175270805:role/read_only"
]
```

+++

### Users use their AWS credentials to get STS tokens that are used to make API calls

+++

### Switch to audit user's credentials

```sh
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=xxx
```

+++

### Acquire STS credentials

```sh
aws sts assume-role                                 \
--role-arn arn:aws:iam::489175270805:role/read_only \
--role-session-name audit-test
{
    "Credentials": {
        "AccessKeyId": "XXX",
        "SecretAccessKey": "XXX",
        "SessionToken": "XXX",
    },
    "AssumedRoleUser": {
        "AssumedRoleId": "XXX:audit-test",
        "Arn": "XXX:assumed-role/read_only/audit-test"
    }
}
```

+++

### Set the environment

```sh
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=XXX
export AWS_SESSION_TOKEN=XXX
```

+++

### Verify

```sh
aws sts get-caller-identity
{
    "UserId": "AROAJ6TY53DCE4TYG6JWC:audit-test",
    "Account": "489175270805",
    "Arn": "arn:aws:sts::489175270805:assumed-role/read_only/audit-test"
}
```

```sh
aws s3 ls
2018-04-19 14:40:37 abedra-audit
2018-04-19 11:35:45 abedra-tfstate
```

+++

## But there's an easier way

+++

# aws-vault

+++

## This tool is effective on multiple levels

+++

## It allows you to assume roles via STS

+++

## It even handles MFA

+++

## It also moves credentials into the OS keyring

+++

## Which encrypts your credentials and keeps them protected

+++

## Let's go through the setup

+++

[https://github.com/99designs/aws-vault](https://github.com/99designs/aws-vault)

+++

#### ~/.aws/config

```toml
[default]
output = json
region = us-east-2

[profile personal-admin]
region=us-east-2
output=json
role_arn=arn:aws:iam::489175270805:role/admin
mfa_serial=arn:aws:iam::489175270805:mfa/operator

[profile personal-read_only]
region=us-east-2
output=json
role_arn=arn:aws:iam::489175270805:role/read_only
```

+++

### Now we import our credentials into vault

```sh
workshop/iam> aws-vault add personal-read_only
Enter Access Key ID: XXX
Enter Secret Access Key: XXX
Added credentials to profile "personal-read_only" in vault
workshop/iam> aws-vault add personal-admin
Enter Access Key ID: XXX
Enter Secret Access Key: XXX
Added credentials to profile "personal-admin" in vault
workshop/iam> aws-vault list
personal-read_only
personal-admin
```

+++

### Let's give it a spin

```sh
workshop/iam> aws-vault exec personal-read_only -- aws s3 ls
2018-04-19 14:40:37 abedra-audit
2018-04-19 11:35:45 abedra-tfstate
```

+++

### Now that you have things setup you can remove all other permissions

+++

### This creates a clean separation and a good audit trail

+++

## Questions?

---

## Network Design

@fa[arrow-down]

+++

## Before we get started, the number one rule...

+++

## Keep it simple

+++

## Complicated networks are complicated

+++

## And cause all kinds of problems

+++

## Now that we have that out of the way

+++

## Let's move on to the VPC

+++

## This is the foundation of your network

+++

## If you haven't been doing this, start now

+++

## Let's explore the setup

+++?code=workshop/vpc/setup.tf

@[1-3]
@[5-11]
@[13-13]
@[14-14]
@[16-19]
@[21-27]
@[30-32]
@[34-38]
@[40-40]
@[41-43]
@[45-50]
@[52-54]
@[57-57]
@[58-60]
@[62-67]
@[69-71]
@[74-80]
@[82-82]
@[83-85]
@[87-92]
@[94-96]
@[99-99]
@[100-102]
@[104-109]
@[111-113]
@[116-126]

+++

### Check security groups assigned to public instances

```sh
aws ec2 describe-instances           \
--query "Reservations[].Instances[].[InstanceId,PublicIpAddress,SecurityGroups[].GroupName]"

"i-02d6f02ed4cd65571",
"18.220.232.57",
"bastion_external_security_group"

"i-088a3499844e2f3b0",
"18.222.41.186",
"bastion_internal_security_group",
"api_security_group"
```

+++

### Or use the nmap docker image

```sh
workshop/vpc> docker build -t nmap .
workshop/vpc> docker run nmap -Pn -T5 -sS -A [bastion_ip]
```

+++

## We could keep going, but this is a good start

+++

### Remember to keep things simple, but maintain proper boundaries

+++

## Questions?

---

## Encryption and Key Management

@fa[arrow-down]

+++

## Let's set a baseline

+++

## The Problem

+++

## Encrypt an unknown amount of data at rest

+++

## We should rely on symmetric encryption for this

+++

## In particular, AES

+++

## For this workshop we will use `AES-256-GCM`

+++

## A breakdown

@ul

- AES is the cipher core
- 256 is length of the key in bits
- GCM, short for Galois Counter Mode, is the cipher block mode

@ulend

+++

### There are other AES options, but this is the strongest choice*

+++

## Local Python Example

+++?code=workshop/kms/local/local_aes&lang=python

@[8-13]
@[16-19]
@[22-29]

+++

### Test it out

```sh
workshop/kms/local> docker build -t local_aes .
workshop/kms/local> docker run local_aes
'Attack at dawn'
```

+++

## Questions

@ul

- Does this solve our encryption problem?
- How do we get a better key?
- How do we protect the key material?
- Is one encryption key enough?

@ulend

+++

## Amazon KMS

+++

### A hardware backed symmetric encryption service available via a simple API

+++

### If you are encrypting anything inside of AWS, you should be using this service

+++

### Any AWS service that stores data has a KMS option

+++

### If you can, design your system to use RDS with KMS for data at rest

+++

## Let's explore the other path

+++?code=workshop/kms/setup.tf

@[1-3]
@[5-11]
@[13-16]
@[17-20]
@[22-32]

+++

### Deploy

```sh
workshop/kms> terraform init
workshop/kms> terraform plan
workshop/kms> terraform apply
```

+++

### This creates a KMS key with an alias and a dynamodb table

+++

### We will use two types of encryption keys

@ul

- Key Encryption Keys (KEK)
- Data Encryption Keys (DEK)

@ulend

+++

### The dynamodb table is for data encryption keys

+++

## Let's encrypt with KMS

+++?code=workshop/kms/kms_master/kms_master&lang=python

@[9-12]
@[14-17]
@[19-19]
@[21-23]
@[25-25]

+++

### Build and run

```sh
workshop/kms/kms_master> docker build -t kms_master .
workshop/kms/kms_master> docker run  \
-e AWS_ACCESS_KEY_ID=XXX             \
-e AWS_SECRET_ACCESS_KEY=XXX         \
-e AWS_DEFAULT_REGION=us-east-2 \
kms_master
'base64 encoded string'
'Attack at dawn'
```

+++

### This creates black box encryption with no knowledge of key material

+++

### The downside is that it only works for data up to 4 kilobytes in size

+++

### To solve our problem we will need to combine our use of KMS and local encryption

+++

### We do this by using KMS to generate and encrypt data encryption keys

+++

### We will store our encrypted data encryption keys in dynamodb

+++

### Generate a DEK and insert it into dynamodb

+++?code=workshop/kms/dynamo/insert_dek&lang=python

@[11-17]
@[19-30]
@[32-39]
@[41-41]

+++

### Execute

```sh
workshop/kms/dynamo> docker build -t insert_dek .
workshop/kms/dynamo> docker run      \
-e AWS_ACCESS_KEY_ID=XXX             \
-e AWS_SECRET_ACCESS_KEY=XXX         \
-e AWS_DEFAULT_REGION=us-east-2 \
insert_dek

{u'Item': {u'KeyId': {u'S': u'application'},
           u'Value': {u'S': u'XXX'}},
 'ResponseMetadata': {'HTTPHeaders': { ...SNIP... }
                      'HTTPStatusCode': 200,
                      'RequestId': XXX,
                      'RetryAttempts': 0}}
```

+++

### Now we can perform end to end encryption using dynamodb and kms backed encryption

+++?code=workshop/kms/complete/dynamo_backed_aes&lang=python

@[10-15]
@[18-21]
@[24-27]
@[29-36]
@[38-40]
@[42-42]
@[45-53]

+++

### Run the complete example

```sh
workshop/kms/complete> docker build -t complete .
workshop/kms/complete> docker run    \
-e AWS_ACCESS_KEY_ID=XXX             \
-e AWS_SECRET_ACCESS_KEY=XXX         \
-e AWS_DEFAULT_REGION=us-east-2 \
complete

'Attack at dawn'
```

+++

### This assumes a single data encryption key for all data in an application

+++

### Other Options

@ul

- A DEK per customer
- A DEK per record
- A DEK per shard

@ulend

+++

### With multiple DEKs, store the key id with the record in the database

+++

## Wrap Up

@ul

- Does this solve our encryption problem?
- How do we get a better key?
- How do we protect the key material?
- Is one encryption key enough?

@ulend

+++

## Questions?

---

## Parting thoughts and questions
