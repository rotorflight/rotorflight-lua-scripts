# Rotorflight LUA Scripts

[Rotorflight](https://github.com/rotorflight) is a Flight Control software suite designed for
single-rotor helicopters. It consists of:

- Rotorflight Flight Controller Firmware
- Rotorflight Configurator, for flashing and configuring the flight controller
- Rotorflight Blackbox Explorer, for analyzing blackbox flight logs
- Rotorflight LUA Scripts, for configuring the flight controller using a transmitter running:
  - EdgeTX/OpenTX (this repository)
  - Ethos

Built on Betaflight 4.3, Rotorflight incorporates numerous advanced features specifically
tailored for helicopters. It's important to note that Rotorflight does _not_ support multi-rotor
crafts or airplanes; it's exclusively designed for RC helicopters.

This version of Rotorflight is also known as **Rotorflight 2** or **RF2**.


## Information

Tutorials, documentation, and flight videos can be found on the [Rotorflight website](https://www.rotorflight.org/).


## Features

Rotorflight has many features:

* Many receiver protocols: CRSF, S.BUS, F.Port, DSM, IBUS, XBUS, EXBUS, GHOST, CPPM
* Support for various telemetry protocols: CSRF, S.Port, HoTT, etc.
* ESC telemetry protocols: BLHeli32, Hobbywing, Scorpion, Kontronik, OMP Hobby, ZTW, APD, YGE
* Advanced PID control tuned for helicopters
* Stabilisation modes (6D)
* Rotor speed governor
* Motorised tail support with Tail Torque Assist (TTA, also known as TALY)
* Remote configuration and tuning with the transmitter
  - With knobs / switches assigned to functions
  - With LUA scripts on EdgeTX, OpenTX and Ethos
* Extra servo/motor outputs for AUX functions
* Fully customisable servo/motor mixer
* Sensors for battery voltage, current, BEC, etc.
* Advanced gyro filtering
  - Dynamic RPM based notch filters
  - Dynamic notch filters based on FFT
  - Dynamic LPF
* High-speed Blackbox logging

Plus lots of features inherited from Betaflight:

* Configuration profiles for changing various tuning parameters
* Rates profiles for changing the stick feel and agility
* Multiple ESC protocols: PWM, DSHOT, Multishot, etc.
* Configurable buzzer sounds
* Multi-color RGB LEDs
* GPS support

And many more...


## LUA Scripts Requirements

- EdgeTX 2.5.0 or OpenTX 2.3.12 or later transmitter firmware
- A receiver supporting remote configuration:
  - a FrSky Smartport or F.Port receiver, _or_
  - a Crossfire v2.11 or newer receiver, _or_
  - an ELRS 2.0.1 or newer receiver

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
See the [LUA Scripts page](https://www.rotorflight.org/docs/Tutorial-Setup/LUA-Scripts).

## Background script
The optional background script `rf2bg.lua` features *Real Time FC Clock synchronization* and the *Adjustment Teller*. 
- RTC synchronization will send the time of the transmitter to the flight controller. The script will beep if RTC synchronization has been completed. Blackbox logs and files created by the FC will now have the correct timestamp.
- The *Adjustment Teller* will [tell you](https://www.youtube.com/watch?v=rbMiiWhzhqI) what adjustment you just made. It supports all adjustments except profile adjustments. 
  - S.port/F.port: the telemetry sensors 5110 and 5111 should be available. Discover or add them if they aren't.
  - CRSF: the telemetry sensor FM should be available. Also do a `set crsf_flight_mode_reuse = ADJFUNC` in the CLI and `save`.  

The background script can be configured as either a special or global function in EdgeTX/OpenTX. The image below illustrates how to set up the background script as a special function. This configuration ensures that the script runs automatically as soon as the model is selected.

![Background script setup](https://github.com/rotorflight/rotorflight-lua-scripts/assets/34315684/d91c69e3-1bcf-48ce-92bf-4cb9f6e9322e)


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
