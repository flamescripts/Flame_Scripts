Scripts for Flame - Custom solutions for Flame aficionados.
<br />
<br />
**Update**: Existing projects have been seperated and migrated into individual repos which have been linked below:
<br /><br />
## Flame Projects ##

### Flame Broadcast Toggler
A simple utility to retrieve project information, select broadcast options (NDI, AJA, BMD, CoreAudio, NONE), and automatically apply settings to Video, Audio, and Preview Devices in Flame Setup. Adjusts Broadcast Preferences accordingly while keeping other settings unchanged.<br />
[The Flame Broadcast Toggler Repo](https://github.com/flamescripts/Flame_Broadcast_Toggler)<br /><br />

### Flame Archiving
Safety first kids.  Various sripts to encourage and assist in making frequent Flame Archives.<br />
[Flame_Archiving Repo](https://github.com/flamescripts/Flame_Archiving)<br /><br />

### Wacom Scripts
Collection of scripts to assist in Wacom issues on CentOS.<br />
[Flame_Wacom Scripts Repo](https://github.com/flamescripts/Wacom/tree/main)<br />
- [Wacom-Diagnostics Script](https://github.com/flamescripts/Wacom/tree/main/Wacom-Diagnostics)<br />
- [Wacom-Disable_MultiTouch Script](https://github.com/flamescripts/Wacom/tree/main/Wacom-Disable_MultiTouch)<br />
- [Wacom-Hands Script](https://github.com/flamescripts/Wacom/tree/main/Wacom-Hands)<br /><br />

### CentOS Kickstarts
Kickstart files to bypass installation issues that may occur when booting from usb drive issues.<br />
[CentOS_Kickstarts Repo](https://github.com/flamescripts/CentOS_Kickstarts)<br /><br />

### Flame Strace
Automated strace script to assist with 'micro freezes' and testing. if you are wondering what the purpose is, you are likley not the target audience.<br />
[Flame_Strace Repo](https://github.com/flamescripts/Flame_Strace)<br /><br />

## ShotGrid Projects ##

### Flow Production Combined URL Checker *
This Python 3 script checks if a list of Fully Qualified Domain Names (FQDNs), Autodesk Subscription URLs and Autodesk Identity URLs can connect to a port of your selection. It uses the data from the FPT Ecosystem help page, "Which URLs/Protocols need to be allowed for Autodesk Subscription Licensing" page and the "Which URLs/Protocols need to be allowed for Autodesk Identity Manager" help page.  The script attempts to establish a socket connection for each one. The script then shows which URLs successfully connected to the selected port and which did not.  Curl is used for the sitename check.

### Flow Production Tracking FQDN Checker
This Python 3 script checks if a list of Fully Qualified Domain Names (FQDNs) can connect to port 443. It uses the FQDNs from the FPT Ecosystem help page and tries to establish a socket connection for each one. The script then shows which FQDNs successfully connected to port 443 and which did not.<br />
[Flow Production Tracking Repo](https://github.com/flamescripts/FlowProductionTracking)<br /><br />


## Non Flame Projects

### Resolve Databases Backup
Davinci Resolve postgres database backup for use with macOS. Postgres passwords need to be stored in user ~/.pgpass. WIP.<br />
[Resolve_Databases_Backup Repo](https://github.com/flamescripts/Resolve_Databases_Backup)<br /><br />

### Client SFTP User Generator
Quick Script to Create SFTP users. Unsafe w/ no error checking and insecure as hell. Use chroot jails at minimum and common sense. Not for actual human consumption. Caution urged.<br />
[Client_SFTP_User_Generator Repo](https://github.com/flamescripts/Client_SFTP_User_Generator)<br /><br />

## Disclaimer
These are not an official Autodesk certified scripts. Neither the author nor Autodesk are
responsible for any use, misuse, unintended results, or data loss that may occur from using
these script. These scripts have not been thoroughly tested and are a work in progress.  They
were created on personal time to address specific customer requests and may not be applicable
to your workflow.

**Use at your own risk.**
The scripts in this repository are intended to provide guidance only. There is no support
provided. Caution is strongly advised as these have not been thoroughly tested.  be sure to
understand the **what** and **how** before use in any production environment.
