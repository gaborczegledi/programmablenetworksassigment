p4c --target bmv2 --arch v1model dns_filter_good.p4

sudo simple_switch --log-console --pcap --json dns_filter_good.json &

sleep 2

sudo python3 dns_simulation.py
