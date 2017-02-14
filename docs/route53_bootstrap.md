# Route 53 Bootstrapping

Your Kubernetes cluster requires that there be a "hosted zone" in Amazon Route 53 which is an Amazon service that acts as a domain registrar and DNS management system. When a Kubernetes cluster is provisioned a number of DNS records are created such as "api.$CLUSTER.$DOMAIN" (e.g. `api.foobar.k736.net`). Unfortunately configuring DNS is a bit of a pain. This guide exists to walk you through the process which is as follows:

1. Get a domain (either buy one or reuse an existing domain (We *strongly* recommend buying a new one or reusing an unused one that already belongs to your Route 53 account.

2. Ensuring DNS is setup properly.

3. Updating `config.json` with the appropriate information.

## Getting a Domain 

There are a number of ways to get a domain on Route53 and it's outside of the scope of this document to show you the precise steps but in general there are three options:

1. [Purchase an unowned domain](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html)
2. [Transfer an existing domain you own from a different registrar to Route53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html)
3. [Use a domain already in Route53](#Configuring the Domain)

## Configuring the Domain

If you have the domain under Route53 control either because it already existed or because it was purchased or transferred then all you need to do is modify `config.json` and modify `"domain_name": "${YOUR_DOMAIN_NAME}"` to to point to the proper name. For example:

```json
{
  "domain_name": "k736.net",

  ... additional JSON ...
}
```
