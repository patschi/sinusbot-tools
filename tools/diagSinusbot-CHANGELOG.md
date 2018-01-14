# CHANGELOG

* **v0.1.0**: [2015-11-25 12:00]
  * Release: Alpha.
  * New: Basic functionality.
* **v0.2.0**: [2015-11-25 14:00]
  * New: OpenVZ checks
  * New: YouTubeDL support
  * New: welcome header
  * New: asking for automated package install
  * New: Missing operating system packages check
  * New: Check when package manager was updated last time
  * New: parameter support
  * New: parameter: '-w|--no-welcome' to hide welcome text
  * New: parameter: '-u|--no-os-update-check' to skip OS update check
* **v0.2.1**: [2015-11-25 18:00]
  * Fixed: Corrected calculating RAM usage (now without cached RAM)
  * New: Added time as prefix to log messages
  * New: Added report date including timezone to output
* **v0.2.5**: [2015-11-25 21:00]
  * New: Added help with '-h|--help' parameter
  * New: More colorful output (everyone likes colors... and cookies.)
  * Fixed: TS3Path check if exists
  * Fixed: 'cpu model' was shown multiple times if more processors exists (even when different processors)
  * New: Fallback for bot location when binary not found to /opt/ts3bot/
  * Changed: Output style. From BBCode to clean text.
  * New: Added '-v|--version' parameter
  * New: Added '-c|--credits' parameter
  * Improved: own function for trimming whitespaces
* **v0.3.0**: [2015-11-26 19:00]
  * Release: Beta.
  * New: Added TS3Client version to output.
  * New: Added support to retrieve SinusBot version by 'sinusbot -version' parameter (including fallback to old method)
  * New: Added SWAP info display
  * New: Added DISK info display
  * New: Added KERNEL info display
  * New: Added LOAD AVERAGE info display
  * New: Added UPTIME info display
  * New: Added 'installed bot scripts' display
  * New: Added TS3client bot-plugin checks
  * New: Added bot running checks (and under which user it is running)
  * New: Added bot webinterface port checks
  * Improved: Supported operating system checks.
* **v0.3.1**: [2015-11-26 21:00]
  * Changed: Using 'lscpu' for determining CPU data now
  * New: Check for bot autostart script (/etc/init.d/sinusbot)
* **v0.3.2**: [2015-11-26 21:20]
  * New: Added advanced permissions checks for the autostart script
* **v0.3.3**: [2015-12-02 10:00]
  * New: Check if x64 bit operating system
  * New: Added DNS resolution check of google.com
* **v0.3.4**: [2015-12-04 18:15]
  * Changed: Switched from 'nc' to 'netstat' to determine if webinterface port is up
  * Improved: Some text changes
* **v0.3.5**: [2016-01-01 04:00]
  * Happy new year!
  * Changed: Added CODE-tags for forum to output
  * Changed copyright year
* **v0.3.6**: [2016-01-16 13:55]
  * Fixed some bugs in operating system package detection function
  * Fixed lsb_release errors when checking OS support before checking package installation of lsb-release
  * Fixed dpkg-query errors when package was never installed before (when package detection)
* **v0.3.7**: [2016-01-29 00:45]
  * Fixed retrieving of youtube-dl version when binary exists and is set in the bot configuration (Thanks Xuxe!, see PR #1 on Github)
* **v0.3.8**: [2016-01-30 12:55]
  * Added detection for LXC & Docker (Thanks Xuxe!, see PR #2 on Github)
* **v0.3.9**: [2016-02-03 20:30]
  * Mostly a bug fix release.
  * Added check if the scripts-folder does exist. (which hopefully fixes the issue of displaying files of a wrong folder)
  * Fixed issue with detecting SinusBot version with "--version" parameter on some pre-release SinusBot versions.
  * Changed the uppercase "S" in "Installed Scripts" to lowercase. Whyever I mention this here in the changelog.
* **v0.3.10**: [2016-02-03 20:35]
  * Fixed a little issue with collecting installed scripts
* **v0.3.11**: [2016-02-03 20:45]
  * Fixed LXC-detection bug
* **v0.4.0**: [2016-02-08 16:40]
  * Added 'known issues' section to the top of the script.
  * Added version check for this script.
  * Added automated updater for this script.
  * (The script is checking for a newer version of the diagnostic script on every start.)
  * Added diagSinusBot script version to code output.
  * Added check for vulnerable and outdated ts3client versions.
  * Added optional display of changelog for every update (if changelog file does exist).
  * New: New parameter '-o|--skip-update-check' to skip script update check.
  * New: New parameter '-u|--only-update-check|--update' to only check for script update and then abort.
  * Changed: Renamed parameter '--no-os-update-check' to '--skip-os-update-check'.
  * Changed: Renamed short parameter '-u' to '-a' (for skipping APT OS update checks).
  * Changed: Renamed parameter '--no-welcome' to '--skip-welcome-text'. Short parameter stays the same.
  * Changed: Optimized say-function to be able to output bold text.
  * Some cosmetic and overall little improvements.
  * Fixed LXC detection (finally).
* **v0.4.1**: [2016-03-21 13:15]
  * Added check if webinterface is listening either on IPv4 or IPv6 localhost.
  * Fixed detection if libglib2.0-0 package is installed properly. (Thanks for testing iTaskmanager)
  * Improved installed-package detection a bit.
* **v0.4.2**: [2016-04-14 13:15]
  * *This is just a bugfix release, fixing some issues on non-english operating system-setups.* Thanks for testing and letting me know about the issues, MaxS! [from the SinusBot forum]*
  * Added connection timeout for outgoing web requests (e.g. for script update checks).
  * Added some checks of RAM, SWAP and DISK parsing functions when any errors happens.
  * Reworked the way how RAM and SWAP information gets read from the system (not OS language-dependend anymore).
  * Changed: Calculate md5 hash of installed TS3 plugin even if the bot plugin does not exist in the bot directory.
  * Fixed: Reading out RAM and SWAP-data was not possible when the operating system had any other language than english.
  * Fixed: Retrieving permissions of the SinusBot init.d script did not work on systems with any other language than english.
  * Known issue: Getting DISK data on OpenVZ machines and non-english systems may still not work. Not critical, fix may be released in the future.
* **v0.4.3**: [2016-04-14 13:30]
  * *This is just a very very small and silent micro-release making some non-mentionable improvements.*
  * Updated: Added simple warning/notice to SWAP output when SWAP is disabled.
  * Updated: 'Known issues' section in script file itself.
* **v0.4.4**: [2016-04-28 20:26]
  * *Some little improvements and new version check for recent 3.0.19 TS3 client and glibc library.*
  * Added glibc version check and output.
  * Added warning for TS3 client 3.0.19 on Debian 8 and older.
  * Added commands "sort" and "head" to required commands for this diagnostic script.
  * Improved bot binary search functionality.
* **v0.4.5**: [2016-04-28 22:25]
  * Fixed wrong calculation of RAM usage.
* **v0.4.6**: [2016-09-04 16:30]
  * Added: Additionally search the bot binary in /opt/ts3soundboard/
  * Added: Additionally search the bot binary in /opt/sinusbot/
  * Added messages when not using x64 arch or DNS resolution is broken.
  * Updated some messages and various text output
  * Moved TS3 client version functionality into own seperate function.
  * Disabled "TS3 v3.0.19-outdated"-warning on Debian 8 systems. (Does work on this OS)
  * Improved overall syntax.
  * Cleaned up script.
* **v0.4.7**: [2017-03-01 15:10]
  * Restricted scripts listening to files with *.js extension. (Thanks @maxibanki, PR#4)
  * Fixed detection of local reachable webinterface port. (finally! Issue was that passing the var to awk failed)
  * Updated copyright.
* **v0.5.0**: [2017-03-01 22:15]
  * Added check mechanism if using TS3 client 3.1 and later with Sinusbot 0.9.18 and older, which is not working due to TS3 client API changes.
  * Added outgoing HTTPS access checks, IPv4- and IPv6-only modes.
  * Additionally searching for initd-script at /etc/init.d/ts3bot, and systemd config at /etc/systemd/system/sinusbot.service.
  * Now checking DNS resolution of sinusbot.com instead of Google.com.
  * Now displaying the URL where all changelogs can be found when viewing the latest changelog during the script update process.
  * Improved version compare handling.
  * Fixed some typos.
* **v0.5.1**: [2017-03-14 20:30]
  * Added some required dependencies for the script to execute.
  * Clarify warn messages of HTTPS access checks.
  * Fixed docker integration.
  * Some under-the-hood improvements.
* **v0.6.0**: [2017-11-06 20:45]
  * Added internal flag to change if HTTPS access using IPv6 check should be performed
  * Added locales info output
  * Added few checks if data was correctly retrieved
  * Added time checking and check for time difference
  * Improved CURL checks and also added error code support
  * Increased waiting time for important messages
  * Now using YYYY-mm-dd as date format for changelog
  * Some few fixes and improvements
* **v0.6.1**: [2017-11-07 01:30]
  * Added binary info like permission and file owner
  * Changed critical time difference range from 5-30 to 10-30 secs
  * Removed `screen` package as dependency
  * Some output text improvements
* **v0.7.0**: [2018-01-14 18:00 UTC]
  * Updated year dates to 2018 - happy new year!
  * Added '-m|--skip-wait-messages' parameter to skip waiting time after important messages
  * Added error handling for NTP time checks
  * Added special warning message when OpenVZ is being detected as it is causing a lot of problems in the past
  * Display default value when shell locale LANG is not set
  * Removed old BOT_REQ_PACKAGES_VER variable, was deprecated anyway
  * Removed old bot package dependencies
  * Some internal improvements regarding NTP check
  * Moved changelog to own file resulting in smaller filesize
  * Several improvements and fixes