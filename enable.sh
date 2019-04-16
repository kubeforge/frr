#!/bin/bash
set -x
echo "Running script to set up FRR."

echo "ipv6" >> /etc/modules
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.d/01-disable-ipv6.conf

ip link set dev eth0 down
ip route add default via 10.76.59.1 dev net1
ip addr add 10.8.$tenant_id.1/24 dev net2

iptables -t nat -A POSTROUTING -s 10.8.$tenant_id.0/24 -j MASQUERADE

echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp
echo "1" > /proc/sys/net/ipv4/ip_forward

cp /etc/frr/zebra.conf.sample /etc/frr/zebra.conf
cp /etc/frr/bgpd.conf.sample /etc/frr/bgpd.conf

sed -i "s/zebra=no/zebra=yes/g" /etc/frr/daemons
sed -i "s/bgpd=no/bgpd=yes/g" /etc/frr/daemons
sed -i "s/router\sbgp\s7675/\!router\sbgp\s7675/g" /etc/frr/bgpd.conf

cat <<EOT >> /etc/frr/bgpd.conf
router bgp $local_as
  neighbor KUBEFORGE$tenant_id peer-group
  neighbor KUBEFORGE$tenant_id remote-as $remote_as
  bgp listen range $bgp_listen_range peer-group KUBEFORGE$tenant_id
EOT

echo "nameserver $nameserver" >> /etc/resolv.conf

chown -R frr:frr /etc/frr/

/etc/init.d/frr start

echo "Entering ... (success)"
tail -f /dev/null
