# Smart Home Dev Journal

### Device Specs
- Nortek HUSBZB-1 Z-Wave/Zigbee USB Stick
- Samsung SmartThings
    - Multipurpose Sensor

## Home Assistant Configuration
- https://www.home-assistant.io/docs/configuration/
- https://www.home-assistant.io/integrations/default_config/
- https://community.home-assistant.io/t/empty-configuration-yaml-file/126386

```yml
# Configure a default setup of Home Assistant (frontend, api, etc)
default_config:

# Text to speech
tts:
  - platform: google_translate

group: !include groups.yaml
automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml
```

## Setup Nortek HUSBZB-1 Z-Wave/Zigbee USB Stick
Resources:
- https://major.io/2019/01/14/running-home-assistant-in-a-docker-container-with-zwave-usb-stick/
- https://community.home-assistant.io/t/solved-accessing-z-wave-usb-stick-on-hass-io-installed-using-docker-on-ubuntu/90565/13
- https://community.home-assistant.io/t/home-assistant-in-docker-pass-usb-device-from-host/184674/2

```bash
# check usb devices before inserting device
$ lsusb
# insert usb device
# Check devices again
$ lsusb
# it showed up for me as "Bus 001 Device 006: ID 10c4:8a2a Silicon Labs"
# you may also check for the device path with the following
$ sudo ls /dev/
# for me it showed up as both /dev/ttyUSB0 & /dev/ttyUSB1
# it shows up as two because one is zigbee and the other is zwave
# to get more info on the device search the logs for when it connected
$ journalctl | grep -C 10 ttyUSB
# output looks like this
Oct 04 12:25:48 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: new full-speed USB device number 6 using ehci-pci
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: New USB device found, idVendor=10c4, idProduct=8a2a, bcdDevice= 1.00
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: New USB device strings: Mfr=1, Product=2, SerialNumber=5
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: Product: HubZ Smart Home Controller
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: Manufacturer: Silicon Labs
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: SerialNumber: 61302481
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: cp210x 1-1.2:1.0: cp210x converter detected
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: cp210x converter now attached to ttyUSB0
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: cp210x 1-1.2:1.1: cp210x converter detected
Oct 04 12:25:49 gian-ProLiant-MicroServer-Gen8 kernel: usb 1-1.2: cp210x converter now attached to ttyUSB1
```

The following is then added to the home-assistant.nomad job to give it access to the devices from the usb stick.
- https://www.nomadproject.io/docs/drivers/docker#devices
- https://www.nomadproject.io/docs/drivers/docker#privileged
```hcl
        devices = [
          {
            host_path = "/dev/ttyUSB0"
            container_path = "/dev/ttyUSB0"
          },
          {
            host_path = "/dev/ttyUSB1"
            container_path = "/dev/ttyUSB1"
          }
        ]
```
The following may require you to escalate the privileges for nomad/docker to access the devices. For me I didn't need to. This may have been due to the following in the client.hcl
```hcl
plugin "docker" {
        config {
                allow_caps = ["ALL"]
        }
}
```

## Setup Home Assistant with Nortek HUSBZB-1 Z-Wave/Zigbee USB Stick
- https://www.home-assistant.io/hassio/zwave/#husbzb-1
- https://community.home-assistant.io/t/zigbee-usb-path-option-deprecated/198722/8
- https://community.home-assistant.io/t/usb-path-deprecated-how-to-specify-then/197870/11

Add the following to the home-assistant configuration.yaml file.
```yml
zwave:
  usb_path: /dev/ttyUSB0

zha:
  usb_path: /dev/ttyUSB1
  database_path: /config/zigbee.db
```

## Setup SmartThings Multipurpose Sensor with HUSBZB-1
- https://community.home-assistant.io/t/smartthings-multipurpose-sensor-2018-with-husbzb-1/66683

## Hacs
- https://hacs.xyz/