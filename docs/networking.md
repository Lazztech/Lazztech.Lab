# Networking

## Equipment
- https://store.ui.com/collections/unifi-network-routing-switching/products/unifi-dream-machine
- https://store.ui.com/collections/unifi-accessories/products/unifi-smart-power

## Network Wall

- https://imgur.com/r/Ubiquiti/rnCSoPy
- https://www.thingiverse.com/thing:4429931
- https://www.wallcontrol.com/12in-x-16in-black-metal-pegboard-tile-fun-size-tool-board-panel/

## UDM Configuration

**UDM DNS/HOSTS CONFIG:**
- https://community.ui.com/questions/UDM-UDMPro-Is-it-possible-to-redirect-Hard-coded-DNS-request-by-clients/00088d27-c8b0-42fa-9665-71988d7dbd15
```
$ ssh root@192.168.1.1

# echo "192.168.1.11 my.dns.name" >> /etc/hosts

# pkill -HUP dnsmasq  # tell dnsmasq to reload the hosts file

# nslookup my.dns.name  # confirm the address has been mapped as you expect
Name:      my.dns.nz
Address 1: 192.168.1.11 my.dns.name
```
- https://community.ui.com/questions/UDM-DNS-Configuration/cb79f4ad-04c1-47a2-b3cc-6d3739426bf1
- https://community.ui.com/questions/Dream-Machine-Host-Names/111bd201-e2d0-454e-b592-5b2332492cdd
- https://www.reddit.com/r/Ubiquiti/comments/d9dd8p/udm_pihole/
- https://www.reddit.com/r/Ubiquiti/comments/fw6whf/udm_pro_redirect_all_dns_queries_through_pihole/
- Potentially helpful:
  - https://github.com/wicol/unifi-dns