# Wireguard

## Troubleshooting
> "Failed to send handshake initiation write udp4 0.0.0.0:54164->:51820: sendto: no route to host"
This was fixed by changing the allowed ips in the .conf file for the tunnel. [1.]

```
[Interface]
PrivateKey = redacted
Address = 10.44.0.3/32
DNS = 10.44.0.1

[Peer]
PublicKey = redacted
AllowedIPs = 0.0.0.0/0
Endpoint = 24.18.203.15:51820
```

## Resources
1. https://www.reddit.com/r/WireGuard/comments/dttnej/wireguard_connection_working_on_windows_but_not/