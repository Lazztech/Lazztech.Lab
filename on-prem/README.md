# On Prem

## HP Microserver Gen 8
- appears to already have grub boot usb drive setup
    - http://blog.thestateofme.com/2015/01/21/howto-factory-reset-ilo-4-on-hp-microserver-gen8/
- installing new os requires inserting live usb and rebooting. thats it.
- ubuntu 20 lts minimal desktop install
- linux nomad install
- linux docker install
  - https://www.nomadproject.io/docs/drivers/docker.html#client-requirements
- docker user group permissions
  - sudo usermod -G docker -a nomad
- nomad server.hcl example
- nomad client1.hcl example
- traefik.nomad container based job works
- with non-dev setup containers are accessible outside the machines localhost
- linux consul install
```bash
$ sudo mkdir /etc/consul.d
$ sudo chmod a+w /etc/consul.d
$ consul agent \
  -server \
  -bootstrap-expect=1 \
  -node=agent-one \
  -data-dir=/tmp/consul \
  -config-dir=/etc/consul.d
```
- setup wireguard vpn
  - add `allow_caps = ["ALL"]` to nomad client.hcl plugin "docker" config

## UDM
- https://community.ui.com/questions/UDM-UDMPro-Is-it-possible-to-redirect-Hard-coded-DNS-request-by-clients/00088d27-c8b0-42fa-9665-71988d7dbd15
```
$ ssh root@192.168.1.1

# echo "192.168.1.11 my.dns.name" >> /etc/hosts

# pkill -HUP dnsmasq  # tell dnsmasq to reload the hosts file

# nslookup my.dns.name  # confirm the address has been mapped as you expect
Name:      my.dns.nz
Address 1: 192.168.1.11 my.dns.name
```