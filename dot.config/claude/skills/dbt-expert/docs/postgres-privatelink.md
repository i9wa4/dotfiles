---
title: "Configure AWS PrivateLink for Postgres | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/secure/postgres-privatelink"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Secure your tenant](https://docs.getdbt.com/docs/cloud/secure/secure-your-tenant)* AWS PrivateLink for Postgres

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fsecure%2Fpostgres-privatelink+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fsecure%2Fpostgres-privatelink+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fsecure%2Fpostgres-privatelink+so+I+can+ask+questions+about+it.)

On this page

Available to certain Enterprise tiers

The private connection feature is available on the following dbt Enterprise tiers:

* Business Critical
* Virtual Private

To learn more about these tiers, contact us at [sales@getdbt.com](mailto:sales@getdbt.com).

A Postgres database, hosted either in AWS or in a properly connected on-prem data center, can be accessed through a private network connection using AWS Interface-type PrivateLink. The type of Target Group connected to the Network Load Balancer (NLB) may vary based on the location and type of Postgres instance being connected, as explained in the following steps.

Private connection endpoints can't connect across cloud providers (AWS, Azure, and GCP). For a private connection to work, both dbt and the server (like Postgres) must be hosted on the same cloud provider. For example, dbt hosted on AWS cannot connect to services hosted on Azure, and dbt hosted on Azure can’t connect to services hosted on GCP.

## Configuring Postgres interface-type PrivateLink[​](#configuring-postgres-interface-type-privatelink "Direct link to Configuring Postgres interface-type PrivateLink")

### 1. Provision AWS resources[​](#1-provision-aws-resources "Direct link to 1. Provision AWS resources")

Creating an Interface VPC PrivateLink connection requires creating multiple AWS resources in the account containing, or connected to, the Postgres instance:

* **Security Group (AWS hosted only)** — If you are connecting to an existing Postgres instance, this likely already exists, however, you may need to add or modify Security Group rules to accept traffic from the Network Load Balancer (NLB) created for this Endpoint Service.
* **Target Group** — The Target Group will be attached to the NLB to tell it where to route requests. There are various target types available for NLB Target Groups, so choose the one appropriate for your Postgres setup.

  + Target Type:

    - *[Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/)* - **IP**

      * Find the IP address of your RDS instance using a command line tool such as `nslookup <endpoint>` or `dig +short <endpoint>` with your RDS DNS endpoint
      * *Note*: With RDS Multi-AZ failover capabilities the IP address of your RDS instance can change, at which point your Target Group would need to be updated. See [this AWS blog post](https://aws.amazon.com/blogs/database/access-amazon-rds-across-vpcs-using-aws-privatelink-and-network-load-balancer/) for more details and a possible solution.
    - *On-prem Postgres server* - **IP**

      * Use the IP address of the on-prem Postgres server linked to AWS through AWS Direct Connect or a Site-to-Site VPN connection
    - *Postgres on EC2* - **Instance/ASG** (or **IP**)

      * If your Postgres instance is hosted on EC2 the *instance* Target Group type (or ideally [using the instance type to connect to an auto-scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html)) can be used to attach the instance without needing a static IP address
      * The IP type can also be used, with the understanding that the IP of the EC2 instance can change if the instance is relaunched for any reason
  + Target Group protocol: **TCP**
* **Network Load Balancer (NLB)** — Requires creating a Listener that attaches to the newly created Target Group for port `5432`

  + **Scheme:** Internal
  + **IP address type:** IPv4
  + **Network mapping:** Choose the VPC that the VPC Endpoint Service and NLB are being deployed in, and choose subnets from at least two Availability Zones.
  + **Security Groups:** The Network Load Balancer (NLB) associated with the VPC endpoint service must either not have an associated security group, or the security group must have a rule that allows requests from the appropriate dbt **private CIDR(s)**. Note that *this is different* than the static public IPs listed on the dbt [Access, Regions, & IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) page. dbt Support can provide the correct private CIDR(s) upon request. If necessary, until you can refine the rule to the smaller CIDR provided by dbt, allow connectivity by temporarily adding an allow rule of `10.0.0.0/8`.
  + **Listeners:** Create one listener per target group that maps the appropriate incoming port to the corresponding target group ([details](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html)).
* **VPC Endpoint Service** — Attach to the newly created NLB.

  + Acceptance required (optional) — Requires you to [accept our connection request](https://docs.aws.amazon.com/vpc/latest/privatelink/configure-endpoint-service.html#accept-reject-connection-requests) after dbt creates the endpoint.

Cross-Zone Load Balancing

We highly recommend cross-zone load balancing for your NLB or Target Group; some connections may require it. Cross-zone load balancing may also [improve routing distribution and connection resiliency](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html#cross-zone-load-balancing). Note that cross-zone connectivity may incur additional data transfer charges, though this should be minimal for requests from dbt.

* [Enabling cross-zone load balancing for a load balancer or target group](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/edit-target-group-attributes.html#target-group-cross-zone)

### 2. Grant dbt AWS account access to the VPC Endpoint Service[​](#2-grant-dbt-aws-account-access-to-the-vpc-endpoint-service "Direct link to 2. Grant dbt AWS account access to the VPC Endpoint Service")

On the provisioned VPC endpoint service, click the **Allow principals** tab. Click **Allow principals** to grant access. Enter the ARN of the root user in the appropriate production AWS account and save your changes.

* Principal: `arn:aws:iam::346425330055:role/MTPL_Admin`

[![Enter ARN](https://docs.getdbt.com/img/docs/dbt-cloud/privatelink-allow-principals.png?v=2 "Enter ARN")](#)Enter ARN

### 3. Obtain VPC Endpoint Service Name[​](#3-obtain-vpc-endpoint-service-name "Direct link to 3. Obtain VPC Endpoint Service Name")

Once the VPC Endpoint Service is provisioned, you can find the service name in the AWS console by navigating to **VPC** → **Endpoint Services** and selecting the appropriate endpoint service. You can copy the service name field value and include it in your communication to dbt support.

[![Get service name field value](https://docs.getdbt.com/img/docs/dbt-cloud/privatelink-endpoint-service-name.png?v=2 "Get service name field value")](#)Get service name field value

### 4. Add the required information to the template below, and submit your request to [dbt Support](https://docs.getdbt.com/community/resources/getting-help#dbt-cloud-support):[​](#4-add-the-required-information-to-the-template-below-and-submit-your-request-to-dbt-support "Direct link to 4-add-the-required-information-to-the-template-below-and-submit-your-request-to-dbt-support")

```
Subject: New Multi-Tenant PrivateLink Request
- Type: Postgres Interface-type
- VPC Endpoint Service Name:
- Postgres server AWS Region (for example, us-east-1, eu-west-2):
- dbt AWS multi-tenant environment (US, EMEA, AU):
```

dbt Labs will work on your behalf to complete the private connection setup. Please allow 3-5 business days for this process to complete. Support will contact you when the endpoint is available.

### 5. Accepting the connection request[​](#5-accepting-the-connection-request "Direct link to 5. Accepting the connection request")

When you have been notified that the resources are provisioned within the dbt environment, you must accept the endpoint connection (unless the VPC Endpoint Service is set to auto-accept connection requests). Requests can be accepted through the AWS console, as seen below, or through the AWS CLI.

[![Accept the connection request](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/accept-request.png?v=2 "Accept the connection request")](#)Accept the connection request

## Create Connection in dbt[​](#create-connection-in-dbt "Direct link to Create Connection in dbt")

Once dbt support completes the configuration, you can start creating new connections using PrivateLink.

1. Navigate to **settings** → **Create new project** → select **PostgreSQL**
2. You will see two radio buttons: **Public** and **Private.** Select **Private**.
3. Select the private endpoint from the dropdown (this will automatically populate the hostname/account field).
4. Configure the remaining data platform details.
5. Test your connection and save it.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

If the PrivateLink endpoint has been provisioned and configured in dbt but connectivity is still failing, check the following in your networking setup to ensure requests and responses can be successfully routed between dbt and the backing service.

### Configuration[​](#configuration "Direct link to Configuration")

Start with the configuration:

 1. NLB Security Group

The Network Load Balancer (NLB) associated with the VPC Endpoint Service must either not have an associated Security Group or the Security Group must have a rule that allows requests from the appropriate dbt *private CIDR(s)*. Note that this differs from the static public IPs listed on the dbt Connection page. dbt Support can provide the correct private CIDR(s) upon request.

* **Note**\*: To test if this is the issue, temporarily adding an allow rule of `10.0.0.0/8` should allow connectivity until the rule can be refined to a smaller CIDR

 2. NLB Listener and Target Group

Check that there is a Listener connected to the NLB that matches the port that dbt is trying to connect to. This Listener must have a configured action to forward to a Target Group with targets that point to your backing service. At least one (but preferably all) of these targets must be **Healthy**. Unhealthy targets could suggest that the backing service is, in fact, unhealthy or that the service is protected by a Security Group that doesn't allow requests from the NLB.

 3. Cross-zone Load Balancing

Check that *Cross-zone load balancing* is enabled for your NLB (check the **Attributes** tab of the NLB in the AWS console). If this is disabled, and the zones that dbt is connected to are misaligned with the zones where the service is running, requests may not be able to be routed correctly. Enabling cross-zone load balancing will also make the connection more resilient in the case of a failover in a zone outage scenario. Cross-zone connectivity may incur additional data transfer charges, though this should be minimal for requests from dbt.

 4. Routing tables and ACLs

If all the above check out, it may be possible that requests are not routing correctly within the private network. This could be due to a misconfiguration in the VPCs routing tables or access control lists. Review these settings with your network administrator to ensure that requests can be routed from the VPC Endpoint Service to the backing service and that the response can be returned to the VPC Endpoint Service. One way to test this is to create a VPC endpoint in another VPC in your network to test that connectivity is working independent of dbt's connection.

### Monitoring[​](#monitoring "Direct link to Monitoring")

To help isolate connection issues over a PrivateLink connection from dbt, there are a few monitoring sources that can be used to verify request activity. Requests must first be sent to the endpoint to see anything in the monitoring. Contact dbt Support to understand when connection testing occurred or request new connection attempts. Use these times to correlate with activity in the following monitoring sources.

 VPC Endpoint Service Monitoring

In the AWS Console, navigate to VPC -> Endpoint Services. Select the Endpoint Service being tested and click the **Monitoring** tab. Update the time selection to include when test connection attempts were sent. If there is activity in the *New connections* and *Bytes processed* graphs, then requests have been received by the Endpoint Service, suggesting that the dbt endpoint is routing properly.

 NLB Monitoring

In the AWS Console, navigate to EC2 -> Load Balancers. Select the Network Load Balancer (NLB) being tested and click the **Monitoring** tab. Update the time selection to include when test connection attempts were sent. If there is activity in the *New flow count* and *Processed bytes* graphs, then requests have been received by the NLB from the Endpoint Service, suggesting the NLB Listener, Target Group, and Security Group are correctly configured.

 VPC Flow Logs

VPC Flow Logs can provide various helpful information for requests being routed through your VPCs, though they can sometimes be challenging to locate and interpret. Flow logs can be written to either S3 or CloudWatch Logs, so determine the availability of these logs for your VPC and query them accordingly. Flow logs record the Elastic Network Interface (ENI) ID, source and destination IP and port, and whether the request was accepted or rejected by the security group and/or network ACL. This can be useful in understanding if a request arrived at a certain network interface and whether that request was accepted, potentially illuminating overly restrictive rules. For more information on accessing and interpreting VPC Flow Logs, see the related [AWS documentation](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

AWS PrivateLink for Redshift](https://docs.getdbt.com/docs/cloud/secure/redshift-privatelink)[Next

Private Link for Azure Database for Postgres Flexible Server](https://docs.getdbt.com/docs/cloud/secure/az-postgres-private-link)

* [Configuring Postgres interface-type PrivateLink](#configuring-postgres-interface-type-privatelink)
  + [1. Provision AWS resources](#1-provision-aws-resources)+ [2. Grant dbt AWS account access to the VPC Endpoint Service](#2-grant-dbt-aws-account-access-to-the-vpc-endpoint-service)+ [3. Obtain VPC Endpoint Service Name](#3-obtain-vpc-endpoint-service-name)+ [4. Add the required information to the template below, and submit your request to dbt Support:](#4-add-the-required-information-to-the-template-below-and-submit-your-request-to-dbt-support)+ [5. Accepting the connection request](#5-accepting-the-connection-request)* [Create Connection in dbt](#create-connection-in-dbt)* [Troubleshooting](#troubleshooting)
      + [Configuration](#configuration)+ [Monitoring](#monitoring)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/secure/postgres-privatelink.md)
