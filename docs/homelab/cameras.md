# Cameras

This document seeks to cover topics such as network camera setup, network video recorders(NVR), object detection, & visualizing or integrating with this information.

## IP Cameras


## Home Assistant
- https://www.home-assistant.io/integrations/camera/
- https://community.home-assistant.io/t/live-camera-stream-as-a-card-on-lovelace-is-this-possible/107292/29

Example camera config for hls streams for configuration.yml:

```yaml
camera:
  - platform: generic
    name: Seattle 4th & Olive
    still_image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Seattle%2C_looking_east_from_Third_Ave_at_Stewart_and_Olive_Streets%2C_circa_1920s.jpg/1600px-Seattle%2C_>le%2C_looking_east_from_Third_Ave_at_Stewart_and_Olive_Streets%2C_circa_1920s.jpg"
    stream_source: "https://58cc2dce193dd.streamlock.net/live/4_Olive_NS.stream/playlist.m3u8"
```

The following can then be viewed live from HASS lovelace with the following card:

```yaml
      - type: picture-entity
        camera_view: live
        entity: camera.seattle_4th_olive
```

