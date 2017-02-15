# Amazon Web Services ("AWS") Bootstrapping

In order to get started with this basic AWS + Kubernetes infrastructure fabric three things are absolutely required: 

1. An Amazon Web Services ("AWS") account.
2. An AWS user account with administrator privileges that allow you to provision the infrastructure fabric.
3. Install the official AWS command line tool.

## Get an AWS account

If you're part of an organization you should check and see if you're already paying for an AWS account and if you are then you can skip to [Setup an AWS user and API access](#Setup an AWS user and API access). If you do not already have an AWS account then you can follow these handy instructions to get on the right path:

1. Goto https://aws.amazon.com/
2. Select "Create an AWS Account"
3. Follow the instructions provided by Amazon.

## Setup an AWS user and API access

**NOTE:** The following instructions are written for bootstrapping quickly rather than ideal security. Proper configuration of an IAM user's access policy is an advanced topic not covered here.

**NOTE:** Documenting a User Interface is difficult. If you think this could be clearer or the UI seems to have changed since the guide was written please open an Issue and we'll update the docs accordingly.

### Brand New Account

1. Sign into your AWS account then go to the [User Management Screen](https://console.aws.amazon.com/iam/home#/users).
2. Click "Add User" and on the screen that appears enter a username then select both **Programmatic access** and **AWS Management Console access**.
3. Set a password for the new user. This password is used for accessing the AWS Management Console only.
4. Unselect "Require password reset"
5. Select "Next: Permissions" on the bottom of the screen.
6. Select "Attach existing policies directly"
7. Search for "AdministratorAccess" then select the single result that is returned. The description should read "Provides full access to AWS services and resources."
8. Select "Next: Review" on the bottom of the screen.
9. Ensure the following facts are correct on the next screen.

  | Field | Value |
  | ----- | ----- |
  | User name | $NAME_ENTERED_IN_STEP_2 |
  | AWS access type | Programmatic access and AWS Management Console access |
  | Console password type | Custom |
  | Require password reset | No |
  | Permission summary | Managed Policy -> AdministratorAccess |

10. Select "Create User" on the bottom of the screen.
11. AWS will dump the API Access Key ID and Secret Access Key on the next screen. Copy the ID and secret to a text file temporarily. It is impossible to retrieve the Secret Access Key again after you leave this screen.

### Existing Account

1. Sign into your AWS account then go to the [User Management Screen](https://console.aws.amazon.com/iam/home#/users).

#### Option 1: New User

If you want to create a brand new user for AWS then start from [Brand New Account - Step 2](#brand-new-account).

#### Option 2: Update Existing User

1. Find and select the user in the list.
2. Go to the "Permissions" tab and select "Add Permissions".
3. Select "Attach existing policies directly"
4. Search for "AdministratorAccess" then select the single result that is returned. The description should read "Provides full access to AWS services and resources."
5. Select "Next: Review" on the bottom of the screen.
6. Ensure the following facts are correct on the next screen.

  | Field | Value |
  | ----- | ----- |
  | Permission summary | Managed Policy -> AdministratorAccess |

7. Select "Add permissions".
8. Go to the "Security Credentials" tab and select "Create Access Key". Copy the ID and secret to a text file temporarily. It is impossible to retrieve the Secret Access Key again after you leave this screen.

## Install AWS command line tool

The easiest way to get and use the `aws` command is to install it into the user's Python environment with `pip`. See the [official documentation](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) for available options if this is not suitable for some reason.

### Linux

`pip install --upgrade --user awscli`

### macOS / Mac OS X

`sudo pip install --upgrade --user awscli --ignore-installed six`

## Configure the AWS CLI

Run `aws configure` and input the following for the prompted values

| Prompt | Input Value |
| AWS Access Key ID | The AWS Access Key ID from [Setup an AWS user and API access](#setup-an-aws-user-and-api-access) |
| AWS Secret Access Key | The AWS Secret Access Key from [Setup an AWS user and API access](#setup-an-aws-user-and-api-access) |
| Default Region Name | us-east-2 |
| Default Output Format | json |
