# Rotorflight Lua Scripts for OpenTX and EdgeTX

## Firmware Considerations

- OpenTX 2.3.12 or EdgeTX 2.5.0 or newer on the transmitter and
- a FrSky Smartport or F.Port receiver
- or a Crossfire v2.11 or newer receiver
- or an ELRS 2.0.1 or newer receiver. 

## Installation
Download the [latest release](https://github.com/rotorflight/rotorflight-lua-scripts/releases) and copy the contents of the SCRIPTS folder to your transmitter. 

### Copying the SCRIPTS folder

Bootloader Method

1. Power off your transmitter and power it back on in boot loader mode.
2. Connect a USB cable and open the SD card drive on your computer.
3. Unzip the file and copy the scripts to the root of the SD card.
4. Unplug the USB cable and power cycle your transmitter.

Manual method (varies, based on the model of your transmitter)

1. Power off your transmitter.
2. Remove the SD card and plug it into a computer
3. Unzip the file and copy the scripts to the root of the SD card.
4. Reinsert your SD card into the transmitter
5. Power up your transmitter.

If you copied the files correctly, you can now go into the OpenTx Tools screen from the main menu and access the Rotorflight Configuration tool. The first time you run the script, a message 'Compiling...' will appear in the display before the script is started - this is normal, and is done to minimise the RAM usage of the script.

## Usage
See the [Lua Scripts Wiki page](https://github.com/rotorflight/rotorflight/wiki/Lua-Scripts).

## Background script
The optional background script offers RTC synchronization and RSSI through MSP. It can be setup as a special or global function in OpenTX. The image below shows how to run the background script as a special function.

![Background script setup](docs/assets/images/background_script_setup.png)

## Building from source on Unix-like systems

- Be sure to have `make` and `luac` in version 5.2 installed in the path
- Run `make` from the root folder
- The installation files will be created in the `obj` folder. Copy the files to your transmitter as instructed in the '[Installing](#installing)' section as if you unzipped from a downloaded file.
