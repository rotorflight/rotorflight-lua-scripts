# Rotorflight Lua Scripts

[Rotorflight](https://github.com/rotorflight) is a Flight Control software suite designed for
single-rotor helicopters. It consists of:

- Rotorflight Flight Controller Firmware
- Rotorflight Configurator, for flashing and configuring the flight controller
- Rotorflight Blackbox Explorer, for analyzing blackbox flight logs
- Rotorflight Lua Scripts, for configuring the flight controller using a transmitter running:
  - EdgeTX/OpenTX (this repository)
  - Ethos

Built on Betaflight 4.3, Rotorflight incorporates numerous advanced features specifically
tailored for helicopters. It's important to note that Rotorflight does _not_ support multi-rotor
crafts or airplanes; it's exclusively designed for RC helicopters.

This version of Rotorflight is also known as **Rotorflight 2** or **RF2**.


## Information

Tutorials, documentation, and flight videos can be found on the [Rotorflight website](https://www.rotorflight.org/).

## Lua Scripts Requirements

- EdgeTX 2.5.0 or OpenTX 2.3.12 or later transmitter firmware
- A receiver supporting remote configuration:
  - a FrSky Smartport or F.Port receiver, _or_
  - a Crossfire v2.11 or newer receiver, _or_
  - an ELRS 2.0.1 or newer receiver

> [!IMPORTANT]
> If you're using ELRS, make sure to set the baudrate to 1.87M or higher in the *Hardware* menu of your transmitter.

## Installation

Please download the latest version from [GitHub](https://github.com/rotorflight/rotorflight-lua-scripts/releases/) and copy the contents of the `SCRIPTS` folder to your transmitter. You will know that you've done it correctly when you find the `rf2.lua` file located in the `/SCRIPTS/TOOLS` directory. Plus, you should now see *Rotorflight 2* listed in the *Tools* menu of your transmitter.

### Copying the SCRIPTS folder

USB Method

1. Connect your transmitter to a computer with an USB cable
2. Open the new drive on your computer
3. Unzip the file and copy the `SCRIPTS` folder to the root the new drive
4. Eject the drive
5. Unplug the USB cable

SD Card Method

1. Power off your transmitter
2. Remove the SD card and plug it into a computer
3. Unzip the file and copy the `SCRIPTS` folder to the root of the SD card
4. Eject the SD card
5. Reinsert your SD card into the transmitter
6. Power up your transmitter

If you copied the files correctly, you can now go into the *Tools* menu on your transmitter and access the *Rotorflight 2* tool. The first time you run the script, a message 'Compiling...' will appear in the display before the script is started. This is normal and is done to minimise the RAM usage of the script.

## Usage
See the [Lua Scripts page](https://www.rotorflight.org/docs/Tutorial-Setup/Lua-Scripts).

## Background script
The optional background script `rf2bg.lua` features *Real Time FC Clock synchronization*, the *Adjustment Teller* and *CRSF/ELRS custom telemetry*.
- RTC synchronization will send the time of the transmitter to the flight controller. The script will beep if RTC synchronization has been completed. Blackbox logs and files created by the FC will now have the correct timestamp.
- *CRSF/ELRS custom telemetry* enables all available Rotorflight telemetry sensors when using ELRS.
- The *Adjustment Teller* will [tell you](https://www.youtube.com/watch?v=rbMiiWhzhqI) what adjustment you just made. It supports all adjustments except profile adjustments.

The background script can be configured as either a special or global function in EdgeTX/OpenTX.

In OpenTX, configure your special function as follows to run the script automatically as soon as the model is selected ('ON').

![OpenTX script setup](https://github.com/rotorflight/rotorflight-lua-scripts/assets/34315684/d91c69e3-1bcf-48ce-92bf-4cb9f6e9322e)

On EdgeTX, make also sure to set repeat to *On*:

![EdgeTX script setup](https://raw.githubusercontent.com/rotorflight/rotorflight-lua-scripts/master/docs/assets/images/background_script_edgetx.png)

The *Adjustment Teller* can be enabled under Settings > Rf2bg Options > Adjustment Teller. The teller uses telemetry for getting the adjustment function and value:
- S.port/F.port: the telemetry sensors 5110 and 5111 should be available. Discover or add them if they aren't.
- RF 2.0 CRSF: the telemetry sensor FM should be available. Also do a `set crsf_flight_mode_reuse = ADJFUNC` in the CLI and `save`.
- RF 2.1+ with CRSF/ELRS custom telemetry: make sure you include the *Adjustment Function* sensor.

> [!IMPORTANT]
> Some black & white radios (e.g. the Jumper T-LITE running EdgeTX 2.11) don't have enough memory for running both the *Adjustment Teller* and *CRSF/ELRS custom telemetry*. The user interface will then randomly freeze.


## Building from source on Linux

- Be sure to have `make` and `luac` in version 5.2 installed in the path.
- Run `make` from the root folder.
- The installation files will be created in the `obj` folder. Copy the files to your transmitter as instructed in the [Installation](#installation) section as if you unzipped from a downloaded file.


## Contributing

Rotorflight is an open-source community project. Anybody can join in and help to make it better by:

* Helping other users on Rotorflight Discord or other online forums
* [Reporting](https://github.com/rotorflight?tab=repositories) bugs and issues, and suggesting improvements
* Testing new software versions, new features and fixes; and providing feedback
* Participating in discussions on new features
* Create or update content on the [Website](https://www.rotorflight.org)
* [Contributing](https://www.rotorflight.org/docs/Contributing/intro) to the software development - fixing bugs, implementing new features and improvements
* [Translating](https://www.rotorflight.org/docs/Contributing/intro#translations) Rotorflight Configurator into a new language, or helping to maintain an existing translation


## Origins

Rotorflight is software that is **open source** and is available free of charge without warranty.

Rotorflight is forked from [Betaflight](https://github.com/betaflight), which in turn is forked from [Cleanflight](https://github.com/cleanflight).
Rotorflight borrows ideas and code also from [HeliFlight3D](https://github.com/heliflight3d/), another Betaflight fork for helicopters.

Big thanks to everyone who has contributed along the journey!


## Contact

Team Rotorflight can be contacted by email at rotorflightfc@gmail.com.
