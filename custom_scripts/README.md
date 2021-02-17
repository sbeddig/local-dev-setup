# Custom Scripts

1. [Cheat.sh](#cheatsh)
1. [AWS-Login](#aws-login)

## cheat.sh

A small script to wrap the cheat.sh functionality.

### Usage

```shell
./cheat.sh awk
```

### Links

- https://github.com/chubin/cheat.sh

## aws login

### Prerequisites

Role `custom-admin-role` with `AdministratorAccess` exists.

User `mfa_user` with the following policy exists:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::ACCOUNT_ID:role/custom-admin-role"
    }
  ]
}
```

With this policy, the user mfa_user is allowed to assumeRole custom-admin-role and get access to all aws services.

### Usage

Just call the script with the account id and the TOTP.

Example:

```shell
./login-aws.sh 123456789012 123456
```

**ALTERNATIVE**:

Add access key and secret access key for the mfa user to file .aws/credentials and create a profile for the mfa and
admin user in the file .aws/config.

config:

```shell
[profile mfa]
region = eu-west-1
output = json

[profile admin]
role_arn = ROLE_ARN (custom admin role arn)
mfa_serial = MFA_SERIAL
source_profile = mfa
region = eu-west-1
cli_pager = (to fix problem with cli2 if output is sent to vi)
```

credentials:

```shell
[mfa]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = SECRET_ACCESS_KEY
```

## Links

- https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html




