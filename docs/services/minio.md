# Minio s3 compliant object storage

## TimeZone

s3 is very sensitive to datetime settings between the server and the client. You must make sure that the kubernetes hosts time is correct and that the correct timezone value is exposed to the minio container or you may encounter the following error: `RequestTimeTooSkewed: The difference between the request time and the server's time is too large.`

https://medium.com/@yildirimabdrhm/kubernetes-timezone-management-8cc139b01f9d

```yaml
          volumeMounts:
          - name: tz-config
            mountPath: /etc/localtime
...
      volumes:
      - name: tz-config
        hostPath:
          path: /usr/share/zoneinfo/America/Los_Angeles
          type: File
```

You may also need to run the timezone sync on k3OS to make sure your time is set properly:
```bash
# ssh into your k3OS host
$ ssh rancher@192.168.WhateverYourIpAddressIs
# run NTP sync
$ sudo service ntpd start
```