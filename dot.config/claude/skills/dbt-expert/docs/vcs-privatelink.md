---
title: "Configuring PrivateLink for self-hosted cloud version control systems (VCS) | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/secure/vcs-privatelink"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Secure your tenant](https://docs.getdbt.com/docs/cloud/secure/secure-your-tenant)* PrivateLink for VCS

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fsecure%2Fvcs-privatelink+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fsecure%2Fvcs-privatelink+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fsecure%2Fvcs-privatelink+so+I+can+ask+questions+about+it.)

On this page

Available to certain Enterprise tiers

The private connection feature is available on the following dbt Enterprise tiers:

* Business Critical
* Virtual Private

To learn more about these tiers, contact us at [sales@getdbt.com](mailto:sales@getdbt.com).

AWS PrivateLink provides private connectivity from dbt to your self-hosted cloud version control system (VCS) service by routing requests through your virtual private cloud (VPC). This type of connection does not require you to publicly expose an endpoint to your VCS repositories or for requests to the service to traverse the public internet, ensuring the most secure connection possible. AWS recommends PrivateLink connectivity as part of its [Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html) and details this particular pattern in the **Shared Services** section of the [AWS PrivateLink whitepaper](https://docs.aws.amazon.com/pdfs/whitepapers/latest/aws-privatelink/aws-privatelink.pdf).

You will learn, at a high level, the resources necessary to implement this solution. Cloud environments and provisioning processes vary greatly, so information from this guide may need to be adapted to fit your requirements.

## PrivateLink connection overview[​](#privatelink-connection-overview "Direct link to PrivateLink connection overview")

[![High level overview of the dbt and AWS PrivateLink for VCS architecture](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/privatelink-vcs-architecture.png?v=2 "High level overview of the dbt and AWS PrivateLink for VCS architecture")](#)High level overview of the dbt and AWS PrivateLink for VCS architecture

### Required resources for creating a connection[​](#required-resources-for-creating-a-connection "Direct link to Required resources for creating a connection")

Creating an Interface VPC PrivateLink connection requires creating multiple AWS resources in your AWS account(s) and private network containing the self-hosted VCS instance. You are responsible for provisioning and maintaining these resources. Once provisioned, connection information and permissions are shared with dbt Labs to complete the connection, allowing for direct VPC to VPC private connectivity.

This approach is distinct from and does not require you to implement VPC peering between your AWS account(s) and dbt.

### 1. Provision AWS resources[​](#1-provision-aws-resources "Direct link to 1. Provision AWS resources")

Creating an Interface VPC PrivateLink connection requires creating multiple AWS resources in the account containing, or connected to, your self-hosted cloud VCS. These resources can be created via the AWS Console, AWS CLI, or Infrastructure-as-Code such as [Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) or [AWS CloudFormation](https://aws.amazon.com/cloudformation/).

* **Security Group (AWS hosted only)** — If you are connecting to an existing VCS install, this likely already exists, however, you may need to add or modify Security Group rules to accept traffic from the Network Load Balancer (NLB) created for this Endpoint Service.
* **Target Group(s)** - A [Target Group](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html) is attached to a [Listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html) on the NLB and is responsible for routing incoming requests to healthy targets in the group. If connecting to the VCS system over both SSH and HTTPS, two **Target Groups** will need to be created.
  + **Target Type (choose most applicable):**
    - **Instance/ASG:** Select existing EC2 instance(s) where the VCS system is running, or [an autoscaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html) (ASG) to automatically attach any instances launched from that ASG.
    - **Application Load Balancer (ALB):** Select an ALB that already has VCS EC2 instances attached (HTTP/S traffic only).
    - **IP Addresses:** Select the IP address(es) of the EC2 instances where the VCS system is installed. Keep in mind that the IP of the EC2 instance can change if the instance is relaunched for any reason.
  + **Protocol/Port:** Choose one protocol and port pair per Target Group, for example:
    - TG1 - SSH: TCP/22
    - TG2 - HTTPS: TCP/443 or TLS if you want to attach a certificate to decrypt TLS connections ([details](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html)).
  + **VPC:** Choose the VPC in which the VPC Endpoint Service and NLB will be created.
  + **Health checks:** Targets must register as healthy in order for the NLB to forward requests. Configure a health check that’s appropriate for your service and the protocol of the Target Group ([details](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-health-checks.html)).
  + **Register targets:** Register the targets (see above) for the VCS service ([details](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-register-targets.html)). *It's critical to be sure targets are healthy before attempting connection from dbt.*
* **Network Load Balancer (NLB)** - Requires creating a Listener that attaches to the newly created Target Group(s) for port `443` and/or `22`, as applicable.
  + **Scheme:** Internal
  + **IP address type:** IPv4
  + **Network mapping:** Choose the VPC that the VPC Endpoint Service and NLB are being deployed in, and choose subnets from at least two Availability Zones.
  + **Security Groups:** The Network Load Balancer (NLB) associated with the VPC Endpoint Service must either not have an associated Security Group, or the Security Group must have a rule that allows requests from the appropriate dbt **private CIDR(s)**. Note that **this is different** than the static public IPs listed on the dbt [Access, Regions, & IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) page. The correct private CIDR(s) can be provided by dbt Support upon request. If necessary, temporarily adding an allow rule of `10.0.0.0/8` should allow connectivity until the rule can be refined to the smaller dbt provided CIDR.
  + **Listeners:** Create one Listener per Target Group that maps the appropriate incoming port to the corresponding Target Group ([details](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html)).
* **Endpoint Service** - The VPC Endpoint Service is what allows for the VPC to VPC connection, routing incoming requests to the configured load balancer.
  + **Load balancer type:** Network.
  + **Load balancer:** Attach the NLB created in the previous step.
  + **Acceptance required (recommended)**: When enabled, requires a new connection request to the VPC Endpoint Service to be accepted by the customer before connectivity is allowed ([details](https://docs.aws.amazon.com/vpc/latest/privatelink/configure-endpoint-service.html#accept-reject-connection-requests)).

Cross-Zone Load Balancing

We highly recommend cross-zone load balancing for your NLB or Target Group; some connections may require it. Cross-zone load balancing may also [improve routing distribution and connection resiliency](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html#cross-zone-load-balancing). Note that cross-zone connectivity may incur additional data transfer charges, though this should be minimal for requests from dbt.

* [Enabling cross-zone load balancing for a load balancer or target group](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/edit-target-group-attributes.html#target-group-cross-zone)

### 2. Grant dbt AWS account access to the VPC Endpoint Service[​](#2-grant-dbt-aws-account-access-to-the-vpc-endpoint-service "Direct link to 2. Grant dbt AWS account access to the VPC Endpoint Service")

Once these resources have been provisioned, access needs to be granted for the dbt Labs AWS account to create a VPC Endpoint in our VPC. On the provisioned VPC endpoint service, click the **Allow principals** tab. Click **Allow principals** to grant access. Enter the ARN of the following IAM role in the appropriate production AWS account and save your changes ([details](https://docs.aws.amazon.com/vpc/latest/privatelink/configure-endpoint-service.html#add-remove-permissions)).

* Principal: `arn:aws:iam::346425330055:role/MTPL_Admin`

[![Enter ARN](https://docs.getdbt.com/img/docs/dbt-cloud/privatelink-allow-principals.png?v=2 "Enter ARN")](#)Enter ARN

### 3. Obtain VPC Endpoint Service Name[​](#3-obtain-vpc-endpoint-service-name "Direct link to 3. Obtain VPC Endpoint Service Name")

Once the VPC Endpoint Service is provisioned and configured find the service name in the AWS console by navigating to **VPC** → **Endpoint Services** and selecting the appropriate endpoint service. Copy the service name field value and include it in your communication to dbt support.

[![Get service name field value](https://docs.getdbt.com/img/docs/dbt-cloud/privatelink-endpoint-service-name.png?v=2 "Get service name field value")](#)Get service name field value

Custom DNS configuration

If the connection to the VCS service requires a custom domain and/or URL for TLS, a private hosted zone can be configured by the dbt Labs Infrastructure team in the dbt private network. For example:

* Private hosted zone: examplecorp.com
* DNS record: github.examplecorp.com

### 4. Add the required information to the template below, and submit your request to [dbt Support](https://docs.getdbt.com/community/resources/getting-help#dbt-cloud-support):[​](#4-add-the-required-information-to-the-template-below-and-submit-your-request-to-dbt-support "Direct link to 4-add-the-required-information-to-the-template-below-and-submit-your-request-to-dbt-support")

```
Subject: New Multi-Tenant PrivateLink Request
- Type: VCS Interface-type
- VPC Endpoint Service Name:
- Custom DNS (if HTTPS)
    - Private hosted zone:
    - DNS record:
- VCS install AWS Region (for example, us-east-1, eu-west-2):
- dbt AWS multi-tenant environment (US, EMEA, AU):
```

dbt Labs will work on your behalf to complete the private connection setup. Please allow 3-5 business days for this process to complete. Support will contact you when the endpoint is available.

### 5. Accepting the connection request[​](#5-accepting-the-connection-request "Direct link to 5. Accepting the connection request")

When you have been notified that the resources are provisioned within the dbt environment, you must accept the endpoint connection (unless the VPC Endpoint Service is set to auto-accept connection requests). Requests can be accepted through the AWS console, as seen below, or through the AWS CLI.

[![Accept the connection request](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/accept-request.png?v=2 "Accept the connection request")](#)Accept the connection request

Once you accept the endpoint connection request, you can use the PrivateLink endpoint in dbt.

## Configure in dbt[​](#configure-in-dbt "Direct link to Configure in dbt")

Once dbt confirms that the PrivateLink integration is complete, you can use it in a new or existing git configuration.

**To configure a new git integration with PrivateLink:**

1. Click your account name at the bottom left-hand menu and go to **Account settings** > **Projects**.
2. Click **New project**.
3. Name your project and configure your development environment.
4. Under **Set up repository**, click **Git clone**.
5. Select **PrivateLink Endpoint** as the connection type.
   Your configured integrations will appear in the dropdown menu.
6. Select the configured endpoint from the dropdown list.
7. Click **Save**.

**To configure an existing git integration with PrivateLink:**

1. Click your account name at the bottom left-hand menu and go to **Account settings** > **Integrations**.
2. Under **Gitlab**, select **PrivateLink Endpoint** as the connection type.
   Your configured integrations will appear in the dropdown menu.
3. Select the configured endpoint from the dropdown list.
4. Click **Save**.

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

GCP Private Service Connect for BigQuery](https://docs.getdbt.com/docs/cloud/secure/bigquery-psc)[Next

About dbt installation](https://docs.getdbt.com/docs/about-dbt-install)

* [PrivateLink connection overview](#privatelink-connection-overview)
  + [Required resources for creating a connection](#required-resources-for-creating-a-connection)+ [1. Provision AWS resources](#1-provision-aws-resources)+ [2. Grant dbt AWS account access to the VPC Endpoint Service](#2-grant-dbt-aws-account-access-to-the-vpc-endpoint-service)+ [3. Obtain VPC Endpoint Service Name](#3-obtain-vpc-endpoint-service-name)+ [4. Add the required information to the template below, and submit your request to dbt Support:](#4-add-the-required-information-to-the-template-below-and-submit-your-request-to-dbt-support)+ [5. Accepting the connection request](#5-accepting-the-connection-request)* [Configure in dbt](#configure-in-dbt)* [Troubleshooting](#troubleshooting)
      + [Configuration](#configuration)+ [Monitoring](#monitoring)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/secure/vcs-privatelink.md)
