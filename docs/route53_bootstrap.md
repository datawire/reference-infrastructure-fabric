# Route 53 Bootstrapping

Your Kubernetes cluster requires that there be a "hosted zone" in Amazon Route 53 which is an Amazon service that acts as a domain registrar and DNS management system. When a Kubernetes cluster is provisioned a number of DNS records are created such as "api.$CLUSTER_NAME.$DOMAIN" (e.g. `api.foobar.example.org`). Unfortunately configuring DNS is a bit of a pain. This guide exists to walk you through the process which is as follows:

1. Get a domain (either buy one or reuse an existing domain (We *strongly* recommend buying a new one or reusing an unused one that already belongs to your Route 53 account.

2. Ensure DNS is setup properly.

3. Update `config.json` with the appropriate information.

## Getting a Domain 

There are a number of ways to get a domain on Route53 and it's outside of the scope of this document to show you the precise steps but in general there are three options:

1. [Purchase an unowned domain](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html)
2. [Transfer an existing domain you own from a different registrar to Route53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html)
3. [Use a domain already in Route53](#Configuring the Domain)

## Configuring the Domain

If you have the domain under Route53 control either because it already existed or because it was purchased or transferred then all you need to do is modify `config.json` and modify `"domain_name": "${YOUR_DOMAIN_NAME}"` to to point to the proper name, for example:

```json
{
  "domain_name": "example.org",

  ... additional JSON ...
}
```

## FAQ

**Q:** Can I use a subdomain of an existing domain as the base domain (e.g. `k8s.example.org` would yield `api.foobar.k8s.example.org`)?
**A:** Yes, but it's beyond the scope of this guide. An outline of the process is:

  1. Create another hosted zone in Route53 for the subdomain (e.g. `k8s.example.org`)
  2. Create a new NS record on the "parent" zone `example.org` and add the nameservers for `k8s.example.org` into this record.
