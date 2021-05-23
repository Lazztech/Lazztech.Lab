# Smart Home Dev Journal

### Devices

| Kind | Hubs |
|---------|---------|
| Zigbee/Z-Wave | Nortek HUSBZB-1 Z-Wave/Zigbee USB Stick |

| Zigbee Repeating Devices |
|---------|
| IKEA Tradfri lights |

| Zigbee Devices |
|---------|
| Samsung SmartThings Multipurpose Sensor |


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
- https://hacs.xyz/docs/installation/manual
- https://hacs.xyz/docs/faq/custom_repositories

Note I actually installed this dependency with this:
- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack

```
sudo curl -o /opt/home-assistant/config/custom_components/hacs.zip "https://github.com/hacs/integration/releases/download/1.6.0/hacs.zip"
sudo unzip hacs.zip -d "hacs"
rm -f hacs.zip
```

## Circadian Lighting
- https://www.reddit.com/r/homeassistant/comments/akztvn/whats_your_solution_for_flux_circadian_lighting/
- https://github.com/claytonjn/hass-circadian_lighting

Add the following to the custom repos in hacs:
- https://github.com/basnijholt/adaptive-lighting

Video of setting up adaptive-lighting integration
- https://www.reddit.com/r/homeassistant/comments/jabhso/ha_has_it_before_apple_has_even_finished_it_i/

UI card for adaptive lighting:
- https://www.reddit.com/r/homeassistant/comments/enpeik/i_keep_seeing_my_own_theme_on_reddit_so_now_its/

## HomeKit
- https://www.home-assistant.io/integrations/homekit/
- https://community.home-assistant.io/t/using-homekit-component-inside-docker/45409/25
- https://community.home-assistant.io/t/unable-to-setup-homekit-bridge/235520/12
- https://community.home-assistant.io/t/homekit-no-response/170974/4

Ensure Multicast DNS is allowed in Unifi gateway.
- Disable Auto-Optimimize Network
  - This setting blocks multicast dns
- Enable Multicast DNS
- Disable Multicast and Broadcast Filtering
- Enable multicast enhancement

Ensure the docker container is set to host mode with the following entries in the nomad job:

```
config {
  image = "homeassistant/home-assistant:stable"
  network_mode = "host"
  ...

network {
  mbits = 10
  mode = "host"
  port "http" {
    static = 8123
  }
}
```


Add the following to the home-assistant configuration.yml

```
zeroconf:
  default_interface: true

logger:
  default: warning
  logs:
    homeassistant.components.homekit: debug
    pyhap: debug

homekit:
```

Reboot home assistant and you should receive a notification with a qr code you can scan in the homekit app.

**troubleshooting**
```
# delete homekit state & restart home-assistant
ls /opt/home-assistant/config/.storage/
sudo rm /opt/home-assistant/config/.storage/homekit.XXXXXXXXXXXX.state
```

## Casting
- https://cast.home-assistant.io/
- https://www.home-assistant.io/blog/2019/08/06/home-assistant-cast/

## Inspiration
- https://github.com/basnijholt/home-assistant-config/