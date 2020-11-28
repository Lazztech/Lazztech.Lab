// https://github.com/blakeblackshear/frigate
// docker run --rm \
// --name frigate \
// --privileged \
// -v /dev/bus/usb:/dev/bus/usb \
// -v <path_to_config_dir>:/config:ro \
// -v /etc/localtime:/etc/localtime:ro \
// -p 5000:5000 \
// -e FRIGATE_RTSP_PASSWORD='password' \
// blakeblackshear/frigate:stable-amd64

job "frigate" {
  datacenters = ["dc1"]
  type = "service"

  group "frigate" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "frigate" {
      driver = "docker"
      env {
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "blakeblackshear/frigate:stable-amd64"
        port_map {
          http = 5000
        }
        volumes = [
          "local:/config", # Contains all relevant configuration files.
          "/opt/frigate/clips:/clips",
          "/etc/localtime:/etc/localtime:ro",
        ]
        devices = [
          {
            host_path = "/dev/bus/usb"
            container_path = "/dev/bus/usb"
          },
        ]
      }
      template {
      destination = "local/config.yml"
      data = <<EOH
# Optional: port for http server (default: shown below)
web_port: 5000

# Optional: detectors configuration
# USB Coral devices will be auto detected with CPU fallback
detectors:
  # Required: name of the detector
  coral:
    # Required: type of the detector
    # Valid values are 'edgetpu' (requires device property below) and 'cpu'.
    type: edgetpu
    # Optional: device name as defined here: https://coral.ai/docs/edgetpu/multiple-edgetpu/#using-the-tensorflow-lite-python-api
    device: usb

# Required: mqtt configuration
mqtt:
  # Required: host name
  host: 192.168.1.11
  # Optional: port (default: shown below)
  port: 25170
  # Optional: topic prefix (default: shown below)
  # WARNING: must be unique if you are running multiple instances
  topic_prefix: frigate
  # Optional: client id (default: shown below)
  # WARNING: must be unique if you are running multiple instances
  client_id: frigate
  # Optional: user
#  user: mqtt_user
  # Optional: password
  # NOTE: Environment variables that begin with 'FRIGATE_' may be referenced in {}. 
  #       eg. password: '{FRIGATE_MQTT_PASSWORD}'
#  password: password

# Optional: Global configuration for saving clips
save_clips:
  # Optional: Maximum length of time to retain video during long events. (default: shown below)
  # NOTE: If an object is being tracked for longer than this amount of time, the cache
  #       will begin to expire and the resulting clip will be the last x seconds of the event.
  max_seconds: 300
  # Optional: Location to save event clips. (default: shown below)
  clips_dir: /clips
  # Optional: Location to save cache files for creating clips. (default: shown below)
  # NOTE: To reduce wear on SSDs and SD cards, use a tmpfs volume.
  cache_dir: /cache

# Optional: Global ffmpeg args
# "ffmpeg" + global_args + input_args + "-i" + input + output_args
ffmpeg:
  # Optional: global ffmpeg args (default: shown below)
  global_args:
    - -hide_banner
    - -loglevel
    - panic
  # Optional: global hwaccel args (default: shown below)
  # NOTE: See hardware acceleration docs for your specific device
#  hwaccel_args: []
  # Optional: global input args (default: shown below)
  input_args:
    - -avoid_negative_ts
    - make_zero
    - -fflags
    - nobuffer
    - -flags
    - low_delay
    - -strict
    - experimental
    - -fflags
    - +genpts+discardcorrupt
    - -rtsp_transport
    - tcp
    - -stimeout
    - '5000000'
    - -use_wallclock_as_timestamps
    - '1'
  # Optional: global output args (default: shown below)
  output_args:
    - -f
    - rawvideo
    - -pix_fmt
    - yuv420p

# Optional: Global object filters for all cameras.
# NOTE: can be overridden at the camera level
objects:
  # Optional: list of objects to track from labelmap.txt (default: shown below)
  track:
    - person
  # Optional: filters to reduce false positives for specific object types
  filters:
    person:
      # Optional: minimum width*height of the bounding box for the detected object (default: 0)
      min_area: 5000
      # Optional: maximum width*height of the bounding box for the detected object (default: max_int)
      max_area: 100000
      # Optional: minimum score for the object to initiate tracking (default: shown below)
      min_score: 0.5
      # Optional: minimum decimal percentage for tracked object's computed score to be considered a true positive (default: shown below)
      threshold: 0.85

# Required: configuration section for cameras
cameras:
  # Required: name of the camera
  back:
    # Required: ffmpeg settings for the camera
    ffmpeg:
      # Required: Source passed to ffmpeg after the -i parameter.
      # NOTE: Environment variables that begin with 'FRIGATE_' may be referenced in {}
      input: rtsp://admin:password@192.168.1.166/live
      # Optional: camera specific global args (default: inherit)
#      global_args:
      # Optional: camera specific hwaccel args (default: inherit)
#      hwaccel_args:
      # Optional: camera specific input args (default: inherit)
#      input_args:
      # Optional: camera specific output args (default: inherit)
#      output_args:
    
    # Optional: height of the frame
    # NOTE: Recommended to set this value, but frigate will attempt to autodetect.
    height: 1080
    # Optional: width of the frame
    # NOTE: Recommended to set this value, but frigate will attempt to autodetect.
    width: 1920
    # Optional: desired fps for your camera
    # NOTE: Recommended value of 5. Ideally, try and reduce your FPS on the camera.
    #       Frigate will attempt to autodetect if not specified.
    fps: 5

    # Optional: motion mask
    # NOTE: see docs for more detailed info on creating masks
#    mask: poly,0,900,1080,900,1080,1920,0,1920

    # Optional: timeout for highest scoring image before allowing it
    # to be replaced by a newer image. (default: shown below)
    best_image_timeout: 60

    # Optional: camera specific mqtt settings
    mqtt:
      # Optional: crop the camera frame to the detection region of the object (default: False)
      crop_to_region: True
      # Optional: resize the image before publishing over mqtt
      snapshot_height: 300

    # Optional: zones for this camera
#    zones:
#      # Required: name of the zone
#      # NOTE: This must be different than any camera names, but can match with another zone on another
#      #       camera.
#      front_steps:
#        # Required: List of x,y coordinates to define the polygon of the zone.
#        # NOTE: Coordinates can be generated at https://www.image-map.net/
#        coordinates: 545,1077,747,939,788,805
#        # Optional: Zone level object filters.
#        # NOTE: The global and camera filters are applied upstream.
#        filters:
#          person:
#            min_area: 5000
#            max_area: 100000
#            threshold: 0.8

    # Optional: save clips configuration
    # NOTE: This feature does not work if you have added "-vsync drop" in your input params. 
    #       This will only work for camera feeds that can be copied into the mp4 container format without
    #       encoding such as h264. It may not work for some types of streams.
    save_clips:
      # Required: enables clips for the camera (default: shown below)
      enabled: False
      # Optional: Number of seconds before the event to include in the clips (default: shown below)
      pre_capture: 30
      # Optional: Objects to save clips for. (default: all tracked objects)
      objects:
        - person      

    # Optional: Configuration for the snapshots in the debug view and mqtt
    snapshots:
      # Optional: print a timestamp on the snapshots (default: shown below)
      show_timestamp: True
      # Optional: draw zones on the debug mjpeg feed (default: shown below)
      draw_zones: False
      # Optional: draw bounding boxes on the mqtt snapshots (default: shown below)
      draw_bounding_boxes: True

    # Optional: Camera level object filters config. If defined, this is used instead of the global config.
    objects:
      track:
        - person
        - car
      filters:
        person:
          min_area: 5000
          max_area: 100000
          min_score: 0.5
          threshold: 0.85
EOH
      }

      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "frigate"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.frigate.rule=HostRegexp(`frigate.lazz.tech`)",
          "traefik.http.routers.frigate.tls.certresolver=cloudflare"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "10s"
        }
      }
    }
  }
}
