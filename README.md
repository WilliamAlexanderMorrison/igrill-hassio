# igrill-hassio
Tutorial for establishing a connection between an iGrill temperature probe and Hass.io Home Assistant

## Introduction of my Use Case
I like the iGrill device, and have invested in four probes. I do not like my phone, and thereby me, being tied to the bluetooth range of my grill when using Weber's application to monitor the iGrill. I also do not like the features creeping into Weber's application that tie out to Weber properties and that require a 'Weber-ID'. 

My objectives were:
* Be able to walk away from my grill and continue monitoring temperatures
* Keep data within my home network when possible

## Hardware Components
* iGrill v2
* 2x Raspberry Pi 4 Model B, both running [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
  * *Home Assistant*: The first maintains [Hass.io](https://www.home-assistant.io/hassio) and the [Mosquitto broker](https://github.com/home-assistant/hassio-addons/blob/master/mosquitto/README.md)
  * *iGrill Monitor*: The second maintains the [iGrill monitoring and data publishing scripts](https://github.com/bendikwa/igrill)
    * This tutorial also works on a single Raspberry Pi. I have two because my grill is not within Bluetooth range of my primary Pi.

## Step-by-Step Instructions to Configure the Broker
* Install Hass.io as a docker container following instructions in the [documentation](https://github.com/home-assistant/hassio-installer)
* In the Hass.io Add-On Store, install the [Mosquitto broker](https://github.com/home-assistant/hassio-addons/blob/master/mosquitto/README.md)
  * Follow all of the documentation in the `Installation` and `How to use` sections of the documentation
  * In addition, navigate to the configuration section on the add-ons page and create a `USERNAME` and `PASSWORD` in the logins array that matches the `USERNAME` and `PASSWORD` you created for Home Assistant, as follows:
```json
{
  "logins": [
    {
      "username": "USERNAME",
      "password": "PASSWORD"
    }
  ],
  "anonymous": false,
  "customize": {
    "active": false,
    "folder": "mosquitto"
  },
  "certfile": "fullchain.pem",
  "keyfile": "privkey.pem",
  "require_certificate": false
}
```
    * _While the documentation explicitly notes that this is not required, I found discussion suggesting it on [Reddit](https://www.reddit.com/r/homeassistant/comments/c8r8fc/mqtt_hassio_embedded_broker_need_help/esqlhq3/) and it resolved one of my issues.
* Test that the broker is listening for published data by following the Home Assistant [MQTT testing documentation](https://www.home-assistant.io/docs/mqtt/testing/)
  * Skip the first two paragraphs, and use the `Developer Tools` method built within Home Assistant

## Step-by-Step Instructions to Install  Configure bendiwka's [iGrill Monitor](https://github.com/bendikwa/igrill)
* Install [Docker and Docker Compose](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html)
* Create a directory with the docker and monitor configuration files by using the command `git clone https://github.com/WilliamAlexanderMorrison/igrill-hassio`
* Navigate into the igrill-hassio directory 
* Open the `device.yaml` configuration file 
  * Replace `XX:XX:XX:XX:XX:XX` with the Bluetooth MAC address of your iGrill as needed
    * I was able to obtain this in Raspbian with the command `sudo hcitool lescan`
  * Make any other configuration changes as desired
* Open the `mqtt.yaml` configuration file
  * Replace `IPHOSTNAME` with the IP of your Raspberry Pi with the Broker
  * Replace `USERNAME` to match the `USERNAME` you created for Home Assistant/Mosquitto broker
  * Replace `PASSWORD` to match the `PASSWORD` you created for Home Assistant/Mosquitto broker
  * Make any other configuration changes as desired
* Follow both of the [troubleshooting](https://github.com/bendikwa/igrill#troubleshooting) instructions provided by bendikwa
  * Reboot your Raspberry Pi
* Build the docker with the command `docker-compose build`
  * This will create a docker container with bendiwka's iGrill Monitor repo
* Turn on your iGrill, plug in a probe, and make sure no devices automatically connected to it (a mobile phone running the Weber app, for example)
* Start the docker container with the command `docker-compose up -d`
* Test that the monitor is pushing data to the Mosquitto broker by navigating to the MQTT Developer Tools on your Home Assistant and Start Listening to `#` (all) channels
  * You should see a temperature update and a battery update about every 20 seconds

## Recommendation for Sensor Configuration and Lovelace UI/UX
* Use stog's post on the [Home Assistant community boards](https://community.home-assistant.io/t/weber-igrill-2-integration-with-lovelace-ui/61880) for inspiration
