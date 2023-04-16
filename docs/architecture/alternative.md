This section discusses some tweaks of the Orthweb architecture that are worth consideration.

## VPN connection
To ensure that DICOM traffic travels through private connection, consider using VPN connection. There are two types of VPN connections: 

* Site-to-site VPN: requiring either a physical device or software application to act as a customer gateway. 
* Client VPN: requiring OpenVPN-based client.

Once VPN connection is implemented, the two EC2 instances can be moved to private subnets. 


## Network Load Balancer
If cost allows, consider placing a network load balancer in front of the EC2 instances. We would be able to configure the network load balancer so it automatically sends the traffic to a functional EC2 instance, thereby eliminating the manual fail over procedure.