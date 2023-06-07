import grpc
from scapy.all import *
from mininet.net import Mininet
from mininet.cli import CLI
from mininet.node import RemoteController

# Create Mininet network
net = Mininet(controller=RemoteController)

# Add hosts and switch to the network
client1 = net.addHost('client1')
client2 = net.addHost('client2')
switch = net.addSwitch('s1')

# Add links between hosts and switch
net.addLink(client1, switch)
net.addLink(client2, switch)

# Start the network
net.start()


# Set up the default gateway for each host
client1.cmd('ip route add default via 10.0.0.1')
client2.cmd('ip route add default via 10.0.0.2')



# Build the packet
packet = Ether()/IP(src='10.0.0.1',dst='10.0.0.2')/UDP(dport=53)/DNS(rd=0,qd=DNSQR(qname="a.com"))
# Send the packet from client1 to client2
sendp(packet)
# Start the command-line interface (CLI)
CLI(net)

# Stop the network
# net.stop()
