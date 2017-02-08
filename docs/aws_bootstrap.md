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

### Brand New Account

... TBD ...

### Existing Account

If you already had an AWS account then the following steps may or may not apply depending on how much control you have over your AWS account.

... TBD ...

## Setup AWS command line tool

The easiest way to get and use the `aws` command is to install it into the user's Python environment with `pip`. See the [official documentation](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) for available options if this is not suitable for some reason.

### Linux

`pip install --upgrade --user awscli`

### macOS / Mac OS X

`sudo pip install --upgrade --user awscli --ignore-installed six`
