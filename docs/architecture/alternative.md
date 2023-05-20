This section discusses some tweaks of the Orthweb architecture that are worth consideration.

## Private Connection

For private network connection between DICOM source and Orthweb, consider AWS Direct connect or VPN connection. VPN connection has lower cost. There are two types of VPN connections:

* Site-to-site VPN: requiring either a physical device or software application to act as a customer gateway. 
* Client VPN: requiring OpenVPN-based client on a workstation.

If you're sending imaging data from a workstation. You may connect the workstation to the VPN using client VPN. Orthweb does not automate this configuration. Follow [this instruction](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html) to configure client VPN between the workstation and the VPC. Here are some supplementary notes:

1. the VPN client and the VPN endpoint use certificate based mutual authentication. Many use OpenSSL to create certificates but AWS instruction uses "easyrsa3" to create them.
2. When creating the VPN endpoint, specify a separate CIDR range for client IPs, e.g. `192.168.0.0/22` In this context, the client IP is the workstation's IP once it connects to the VPC via client VPN.
3. create a new security group (e.g. vpn-ep-sg) with outbound rule allowing all types of traffic to destination CIDR 0.0.0.0/0
4. When creating the VPN endpoint, associate it with the two private subnets as target network (which adds the required routes under the hood). Set vpn-ep-sg as the security group. Create the authorization rules as instructed.

Once the VPC client software (OpenVPN or AWS VPN client) is configured and connected from the workstation, the connection between the EC2 instance and the client will become secured at the IP layer. The EC2 instances can be moved to private subnets and the public subnets are no longer necessary.

As for site-to-site VPN and Direct Connect, their requirement should be reviewed with the organizations network team.

## Network Load Balancer
If cost allows, consider placing a network load balancer in front of the EC2 instances. We would be able to configure the network load balancer so it automatically sends the traffic to a functional EC2 instance, thereby eliminating the manual fail over procedure.