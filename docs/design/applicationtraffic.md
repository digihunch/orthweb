
Application traffic management addresses the ingress path of DICOM and web traffic to the network interface of Orthanc EC2 instances. 

The Orthweb solution does not provide a prescriptive design pattern or implementation on application traffic management. This is because the user requirements around application traffic can vary so significantly that no two users would share the same pattern. 

This section discusses some possible customization options for application traffic management. Note, these patterns are not the only viable options. Please discuss the most suitable design with us.

## Out-of-box Configuration

The out-of-box configuration functions without application traffic management service. However, it comes with two difference DNS names, one for each EC2 instance, as illustrated below.

![Diagram](../assets/images/AppTraffic0.png)

This is not always convinient because there are two DNS names, even though both are connected to the same underlying data store (S3 and PostgreSQL database). In the event that one instance becomes unavailable, users and modalities have to use the alternative site DNS name.

## DNS Service
Consider introducign a DNS service to point to both EC2 instances. The DNS resolution result determins which EC2 instance the client connects to. So each EC2 instance must still open 443 and 11112 ports. This pattern is illustrated as below:

![Diagram](../assets/images/AppTraffic1.png)

In this pattern, the DNS can resolves to the public DNS name for both EC2 instances. The result of DNS resolution can rotate, round robin or based on availability. In this option you will bring your own DNS name, and manage your own TLS certificate, instead of using the self-signed certificate provisioned during automation.

## Load Balancer
As cost allows, consider placing a network load balancer in front of the EC2 instances. We would be able to configure the network load balancer so it automatically sends the traffic to a functional EC2 instance, thereby eliminating the manual fail over procedure. This pattern is illustrated as below:

![Diagram](../assets/images/AppTraffic2.png)

This configuration has several advantages. The security group of the EC2 instances can be narrowed down to only open to the load balancer. You can use Application Load Balancer or Network Load Balancer in AWS. The former supports integration with Web Application Firewall but only for HTTPS traffic. The latter supports both DICOM and HTTPS traffic. Both options supports integration with AWS Certificate Manager to automatically manage TLS certificate. 

## Private Connection

Some users need private connection between modality and the Orthanc service. Consider AWS Direct connect or VPN connection. VPN connection has lower cost, with two types:

* Site-to-site VPN: requiring either a physical device or software application to act as a customer gateway. 
* Client VPN: requiring OpenVPN-based client on a workstation.

If you're sending imaging data from a workstation. You may connect the workstation to the VPN using client VPN. Orthweb does not automate this configuration. Follow [this instruction](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html) to configure client VPN between the workstation and the VPC. Here are some supplementary notes:

1. the VPN client and the VPN endpoint use certificate based mutual authentication. Many use OpenSSL to create certificates but AWS instruction uses "easyrsa3" to create them.
2. When creating the VPN endpoint, specify a separate CIDR range for client IPs, e.g. `192.168.0.0/22` In this context, the client IP is the workstation's IP once it connects to the VPC via client VPN.
3. create a new security group (e.g. vpn-ep-sg) with outbound rule allowing all types of traffic to destination CIDR 0.0.0.0/0
4. When creating the VPN endpoint, associate it with the two private subnets as target network (which adds the required routes under the hood). Set vpn-ep-sg as the security group. Create the authorization rules as instructed.

Once the VPC client software (OpenVPN or AWS VPN client) is configured and connected from the workstation, the connection between the EC2 instance and the client will become secured at the IP layer. The EC2 instances can be moved to private subnets and the public subnets are no longer necessary.

As for site-to-site VPN and Direct Connect, their requirement should be reviewed with the network team of the user's organization.