# 2.1.0-RC1

This is the _first Release Candidate_ of the *Rotorflight 2.1 Lua Scripts for EdgeTX and OpenTX*.

**NOTE:** The final 2.1.0 Lua Scripts will be released _after_ a few release candidates. Please don't use RCs once the final release is out.

## Downloads

The download locations are:

- [Rotorflight Configurator](https://github.com/rotorflight/rotorflight-configurator/releases/tag/release/2.1.0-RC1)
- [Rotorflight Blackbox](https://github.com/rotorflight/rotorflight-blackbox/releases/tag/release/2.1.0-RC1)
- [Lua Scripts for EdgeTX and OpenTX](https://github.com/rotorflight/rotorflight-lua-scripts/releases/tag/release/2.1.0-RC1)
- [Lua Scripts for FrSky Ethos](https://github.com/rotorflight/rotorflight-lua-ethos/releases/tag/release/2.1.0-RC1)
- [Lua Suite for FrSky Ethos](https://github.com/rotorflight/rotorflight-lua-ethos-suite/releases/tag/release/2.1.0-RC1)

## Notes

- Rotorflight setup instructions can be found on the RF website [www.rotorflight.org](https://www.rotorflight.org/).
- RF 2.1 *is* backward compatible with RF 2.0. You *can* load your configuration dump from RF 2.0 into 2.1.
- If updating from RF1, please setup your helicopter from scratch. Follow the instructions on the website.
- As always, please double check your configuration on the bench before flying!

## Changes from 2.0.0

- Added support for custom CRSF/ELRS telemetry
- Added support for 480x320 (Jumper T15)
- Added automatic profile switching to all *Profile* pages
- Added a *Status* page which
  - Shows the currently active PID and rate profile numbers
  - Shows *Arming Disabled Flags*, if any
  - Shows the amount of free space on a dataflash, if available. It also offers the option to erase the dataflash.
  - Shows Real-time and CPU load
- The *PIDs* and *Rates* pages
  - Now also show the currently active profile
  - You can change and copy the currently active profile
- *Servo* page
  - Changing the center of a servo now automatically sets servo override for the servo being editted
  - Added button *Override All Servos*
- Added *Model on TX* page, with which you can automatically set model name, timers or global variables on your transmitter. Data is stored on the heli, so you can have different timers for your helis while using just one model on the transmitter.
- Added *Experimental* page for firmware testing purposes
- Added page *ESC - FlyRotor*
- Added page *ESC - HW Platinum V5*
- Added page *ESC - Scorpion Tribunus*
- Added page *ESC - YGE*
- Added *Settings* page for hiding irrelevant pages
- Changing a value using the scroll wheel will go quicker if you scroll fast
- If you try to Save while armed a warning will be given
- Reformatted the *Rescue* page, so the different rescue stages are now more clear
- Improved accessibility by reordering some pages and fields
- Improved MSP handling and processing
- *Adjustment Teller*: added support for accelerometer adjustments

## Changes since 2.1.0-20240929

- Added page *ESC - FlyRotor*
- Added *Settings* page
- Added *Experimental* page for firmware testing purposes
- Various custom CRSF/ELRS telemetry fixes


***

# 2.1.0-20240929

This is a _development snapshot_ of the Rotorflight 2.1 Lua Scripts for EdgeTX/OpenTX.

## Notes

This version is intended to be used for beta-testing only.
It is not fully working nor stable, and should not be used by end-users.

For more information, please join the Rotorflight Discord chat.

## Downloads

The download locations are:

- [Rotorflight Configurator](https://github.com/rotorflight/rotorflight-configurator/releases/tag/snapshot/2.1.0-20240929)
- [Rotorflight Blackbox](https://github.com/rotorflight/rotorflight-blackbox/releases/tag/snapshot/2.1.0-20240929)
- [Lua Scripts for EdgeTx and OpenTx](https://github.com/rotorflight/rotorflight-lua-scripts/releases/tag/snapshot/2.1.0-20240929)
- [Lua Scripts for FrSky Ethos](https://github.com/rotorflight/rotorflight-lua-ethos/releases/tag/snapshot/2.1.0-20240929)


## Changes since 2.1.0 20240828

- Added automatic profile switching to all Profile pages
- Added _Model on TX_ page, with which you can automatically set model name, timers or global variables on your transmitter. Data is stored on the heli, so you can have different timers for your helis while using just one model on the transmitter. Note: rf2bg.lua should be enabled for this to work.
- Adjustment Teller: added support for ELRS custom telemetry
- Adjustment Teller: added support for accelerometer adjustments
- Improved MSP handling


***

# 2.1.0-20240828

This is a _development snapshot_ of the Rotorflight 2.1 Lua Scripts for EdgeTX/OpenTX.

## Notes

This version is intended to be used for beta-testing only.
It is not fully working nor stable, and should not be used by end-users.

For more information, please join the Rotorflight Discord chat.

## Downloads

The download locations are:

- [Rotorflight Configurator](https://github.com/rotorflight/rotorflight-configurator/releases/tag/snapshot/2.1.0-20240828)
- [Rotorflight Blackbox](https://github.com/rotorflight/rotorflight-blackbox/releases/tag/snapshot/2.1.0-20240828)
- [Lua Scripts for EdgeTx and OpenTx](https://github.com/rotorflight/rotorflight-lua-scripts/releases/tag/snapshot/2.1.0-20240828)
- [Lua Scripts for FrSky Ethos](https://github.com/rotorflight/rotorflight-lua-ethos/releases/tag/snapshot/2.1.0-20240828)


## Changes since 2.0.0

- Simplified MSP processing by using a message queue.
- Added support for chained (multiple) MSP calls.
- Added MSP message support for use in transmitter simulators.
- Fields now support preEdit, change and postEdit events.
- Changing a value using the scroll wheel will go faster if you scroll fast.
- Added support for 480x320 (Jumper T15).
- Added a new Status page which
  - Shows the currently active PID and rate profile numbers.
  - Show Arming Disabled Flags, if any.
  - Shows the amount of free space on a dataflash, if available. It also offers the option to erase the dataflash.
  - Shows Real-time and CPU load.
- The PIDs and Rates pages
  - Now also show the currently active profile.
  - You can also change and copy the currently active profile.
  - If the active profile has been changed externally (e.g. by using Adjustments), the page will now automatically refresh.
- Servo page:
  - Changing the center of a servo now automatically sets servo override for the servo being editted.
  - Added button 'Override All Servos'.
- Reformatted the Rescue page, so the different rescue stages are now more clear.
- Improved accessibility by reordering pages and fields.
- If you try to Save while armed a warning will be given.
- Added page 'ESC - HW Platinum V5'.
- Added page 'ESC - Scorpion Tribunus'.
- Added page 'ESC - YGE'.


***

# 2.0.0

This is the 2.0.0 release of the Rotorflight Lua Scripts for EdgeTx/OpenTx.


## Instructions

For instructions and other details, please read the [README](https://github.com/rotorflight/rotorflight-lua-scripts#readme).


## Downloads

The official download locations for Rotorflight 2.0.0 are:

- [Rotorflight Configurator](https://github.com/rotorflight/rotorflight-configurator/releases/tag/release/2.0.0)
- [Rotorflight Blackbox](https://github.com/rotorflight/rotorflight-blackbox/releases/tag/release/2.0.0)
- [Lua Scripts for EdgeTx and OpenTx](https://github.com/rotorflight/rotorflight-lua-scripts/releases/tag/release/2.0.0)
- [Lua Scripts for FrSky Ethos](https://github.com/rotorflight/rotorflight-lua-ethos/releases/tag/release/2.0.0)


## Notes

1. There is a new website [www.rotorflight.org](https://www.rotorflight.org/) for Rotorflight 2.
   The old Wiki in GitHub is deprecated and is for Rotorflight 1 only.
   Big thanks to the documentation team for setting this up!

1. Rotorflight 2 is **NOT** backward compatible with RF1. You **MUST NOT** load your configuration dump from RF1 into RF2.

1. If coming from RF1, please setup your helicopter from scratch for RF2. Follow the instructions on the website!

1. As always, please double check your configuration on the bench before flying!


## Support

The main source of Rotorflight information and instructions is now the [website](https://www.rotorflight.org/).

Rotorflight has a strong presence on the Discord platform - you can join us [here](https://discord.gg/FyfMF4RwSA/).
Discord is the primary location for support, questions and discussions. The developers are all active there,
and so are the manufacturers of RF Flight Controllers. Many pro pilots are also there.
This is a great place to ask for advice or discuss any complicated problems or even new ideas.

There is also a [Rotorflight Facebook Group](https://www.facebook.com/groups/876445460825093) for hanging out with other Rotorflight pilots.


## Changes

A full changelog can be found online.


### Changes since 2.0.0-RC2

- None


***

# 2.0.0-RC2

This is the _second_ Release Candidate of the Rotorflight Lua Scripts for EdgeTx/OpenTx.


## Instructions

For instructions and other details, please read the [README](https://github.com/rotorflight/rotorflight-lua-scripts#readme).


## Downloads

The official download locations for Rotorflight 2.0.0-RC2 are:

- [Rotorflight Configurator](https://github.com/rotorflight/rotorflight-configurator/releases/tag/release/2.0.0-RC2)
- [Rotorflight Blackbox](https://github.com/rotorflight/rotorflight-blackbox/releases/tag/release/2.0.0-RC2)
- [Lua Scripts for EdgeTx and OpenTx](https://github.com/rotorflight/rotorflight-lua-scripts/releases/tag/release/2.0.0-RC2)
- [Lua Scripts for FrSky Ethos](https://github.com/rotorflight/rotorflight-lua-ethos/releases/tag/release/2.0.0-RC2)


## Notes

1. There is a new website [www.rotorflight.org](https://www.rotorflight.org/) for Rotorflight 2.
   The old Wiki in github is deprecated, and is for Rotorflight-1 only.
   Big thanks to the documentation team for setting this up!

1. Rotorflight-2 is **NOT** backward compatible with RF1. You **MUST NOT** load your configuration dump from RF1 into RF2.

1. If coming from RF1, please setup your helicopter from scratch for RF2. Follow the instructions on the website!

1. As always, please double check your configuration on the bench before flying!


## Support

The main source of Rotorflight information and instructions is now the [website](https://www.rotorflight.org/).

Rotorflight has a strong presence on the Discord platform - you can join us [here](https://discord.gg/FyfMF4RwSA/).
Discord is the primary location for support, questions and discussions. The developers are all active there,
and so are the manufacturers of RF Flight Controllers. Many pro pilots are also there.
This is a great place to ask for advice or discuss any complicated problems or even new ideas.

There is also a [Rotorflight Facebook Group](https://www.facebook.com/groups/876445460825093) for hanging out with other Rotorflight pilots.


## Changes

A full changelog can be found online later.


### Changes since 2.0.0-RC2

- Remove cyclic (swash) ring
- Remove Rescue Altitude hold
- Remove PID mode
- Update README.md


***

# 2.0.0-RC1

This is the first Release Candidate of the Rotorflight 2 Lua Scripts for EdgeTx/OpenTx.

## Instructions

For instructions and other details, please read the [README](https://github.com/rotorflight/rotorflight-lua-scripts#readme).


## Downloads

The official download locations for Rotorflight 2.0.0-RC1 are:

- [Rotorflight Configurator](https://github.com/rotorflight/rotorflight-configurator/releases/tag/release/2.0.0-RC1)
- [Rotorflight Blackbox](https://github.com/rotorflight/rotorflight-blackbox/releases/tag/release/2.0.0-RC1)
- [Lua Scripts for EdgeTx](https://github.com/rotorflight/rotorflight-lua-scripts/releases/tag/release/2.0.0-RC1)
- [Lua Scripts for Ethos](https://github.com/rotorflight/rotorflight-lua-ethos/releases/tag/release/2.0.0-RC1)


## Notes

1. There is a new website [www.rotorflight.org](https://www.rotorflight.org/) for Rotorflight 2.
   The old Wiki in github is deprecated, and is for Rotorflight-1 only.
   Big thanks to the documentation team for setting this up!

1. Rotorflight 2 is **NOT** backward compatible with RF1. You **MUST NOT** load your configuration dump from RF1 into RF2.

1. If coming from RF1, please setup your helicopter from scratch for RF2. Follow the instructions on the website!

1. As always, please double check your configuration on the bench before flying!


## Support

The main source of Rotorflight information and instructions is now the [website](https://www.rotorflight.org/).

Rotorflight has a strong presence on the Discord platform - you can join us [here](https://discord.gg/FyfMF4RwSA/).
Discord is the primary location for support, questions and discussions. The developers are all active there,
and so are the manufacturers of RF Flight Controllers. Many pro pilots are also there.
This is a great place to ask for advice or discuss any complicated problems or even new ideas.

There is also a [Rotorflight Facebook Group](https://www.facebook.com/groups/876445460825093) for hanging out with other Rotorflight pilots.


## Changes

A full changelog can be found online later.

### Changes since 2.0.0-20240218

- Added Servos page
- Aligned MSP messages with the firmware
