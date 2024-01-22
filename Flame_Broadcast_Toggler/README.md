# The Flame Broadcast Toggler

A simple utility that retrieves the name and application version of the most recently loaded
Flame project, along with configuration files and allows Flame artists to select their
broadcast options; NDI, AJA, BMD, NONE or CoreAudio, and have those selections automatically
applied to the Video Device, Audio Device, and Preview Devices in Flame Setup. Additionally,
the script adjusts the Flame Broadcast Preferences to align with the Device selection. All
other preferences should remain unchanged.

By implementing automation for these configurations, the script streamlines the procedure
of modifying and tailoring Flame broadcast settings while transitioning between different
locations or workflows. User input can be bypassed to aid in automation by implementing
options like macOS networksetup.

The script creates timestamped backups of the 'init.cfg' and 'broadcastCurrent.pref' files,
enabling the option to revert to previous versions in case of any script-related problems.
The amount of backup iterations can be modified by editing 'max_backup_files'.
The default value is 5.

**Note:** The available modes may require adjustments to accommodate specific hardware devices
such as 'AJA_IO4K_PLUS', splitting the Audio and Video device output, or using Pulse.  Email 
me if you have a need for these to be added.

## Disclaimer

This is not an official Autodesk certified script. Neither the author nor Autodesk are
responsible for any use, misuse, unintended results, or data loss that may occur from using
this script. This script has not been thoroughly tested and is a work in progress. It was
created on personal time to address a specific customer request and may not be applicable
to your workflow.

**Use at your own risk.**
This script is intended for providing guidance only. There is no support provided. Caution
is strongly advised as this has not been thoroughly tested.

## Test Environment

- Operating System: macOS 13.6.2
- Flame Family: 2024.1

## Usage
```
./flame_broadcast_toggler.sh
```

## Requirements

- Sudo credentials will be required after launching the script, however, please avoid executing it as sudo or root.
- Flame Family application

## Helpful Links

- [Flame User Guide > Configure the application](https://help.autodesk.com/view/FLAME/2024/ENU/?guid=FLAME_install_software_os_installation_Configure_the_application_html)
- [Outputting audio and video from AJA or BMD in Flame](https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Outputting-video-from-AJA-Io-4K-Plus-in-Flame.html)

## Always Current Version

[FlameScripts on GitHub](https://github.com/flamescripts/Flame_Scripts)
