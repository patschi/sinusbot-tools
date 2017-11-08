# SinusBot Tools

This repository contains some various tools or scripts for TeamSpeak 3 music bot named "SinusBot". For more information about the bot, please visit [sinusbot.com](https://www.sinusbot.com). The forum is available at [forum.sinusbot.com](https://forum.sinusbot.com).

Any feedback, suggestions, ideas and - of course - pull requests are welcome.

## diagSinusbot

[diagSinusbot.sh](https://github.com/patschi/sinusbot-tools/blob/master/tools/diagSinusbot.sh) collects some important diagnostic data about the operating system and the bot installation. When finished it returns informative information, ready to copy and paste it in the right section in the SinusBot forum. The main purpose of this script is to solve bugs and any other issues easier and faster by giving a overview about the environment - easily collected with this script. Additionally some pre-checks are built-in, which may give you some ideas what could be possibly wrong or not best-practise - like a outdated TS3 client.

**Remember**: This script does not send any data to anywhere. It is only collecting some details offline about the system and the bot. Then it generates a text output, which can be copied and pasted in the forum. (This tool is not officially developed from the Sinusbot team.)

**Links:**
 * [SinusBot forums](https://forum.sinusbot.com)
 * [SinusBot english forum thread](https://forum.sinusbot.com/threads/diagsinusbot-sh-sinusbot-diagnostic-script.831/#post-4418)
 * [SinusBot german forum thread](https://forum.sinusbot.com/threads/diagsinusbot-sh-sinusbot-diagnostik-script.832/#post-4419)

**Some information which will be scanned:**

- System:
  - Operating system
  - Kernel
  - Load average
  - Uptime
  - CPU model, cores and speed
  - RAM usage
  - SWAP usage
  - DISK usage
  - Bot autostart script checks
  - Check if DNS resolution is working
  
- Bot:
  - Status of bot and webinterface
  - Version
  - Performs ts3client checks
  - Some configuration pre-checks
  - Autostart script checks
  - Checks if bot plugin is installed in ts3client
  - Checks LogLevel
  - Checks youtube-dl and the installed version
  - Installed bot scripts (filenames only)
  - Checks if all required OS packages got installed

**Requirements:**
 * Operating Systems: Debian, Ubuntu
   - (Any other OS are not supported yet. Feel free to contribute.)
 * Installed Packages: `bc binutils coreutils lsb-release util-linux`
   - Install: `apt-get install bc binutils coreutils lsb-release util-linux`
   - (Most packages are already pre-installed by default on the most systems.)

**Usage:**
```bash
$ cd /path/to/sinusbot/ # usually /opt/ts3bot/
$ curl -O https://raw.githubusercontent.com/patschi/sinusbot-tools/master/tools/diagSinusbot.sh
$ bash diagSinusbot.sh
```

**Example output:**
```
==========================================================
SINUSBOT RELATED
SYSTEM INFORMATION
 - Operating System: Debian GNU/Linux 8.3 (jessie)
 - OS x64 check: OK
 - Kernel: Linux 3.16.0-4-amd64 x86_64
 - Load Average: 0.29 0.36 0.35
 - Uptime: 3 days, 21 hours, 12 minutes, 39 seconds
 - OS Updates: 0 (well done!)
 - OS Missing Packages: None (v1)
 - OS APT Last Update: 21.02.2016 00:49:02 CET +01:00:00
 - Bot Start Script: found at /etc/init.d/sinusbot [perms: 644]
 - DNS resolution check: google.com -> OK
 - CPU:
    Architecture:          x86_64
    CPU(s):                4
    Thread(s) per core:    1
    Core(s) per socket:    1
    Socket(s):             4
    Model name:            Intel(R) Xeon(R) CPU E5-1650 v2 @ 3.50GHz
    CPU MHz:               3499.999
    Hypervisor vendor:     VMware
    Virtualization type:   full
 - RAM: 654.02 MB/1.96 GB in use (32%)
 - SWAP: 0 B/871.99 MB in use (0%)
 - DISK: 4.75 GB/12.98 GB in use (36%)
 - Package versions:
   > libglib: 2.42.1-1

BOT INFORMATION
 - Status: running (PIDs: 537 534, User: sinusbot)
 - Webinterface: port locally reachable (Port: 8087)
 - Binary: /home/sinusbot/sinusbot/sinusbot (Hash: a48069da6b637c88fceb92244e8df116)
 - Version: 0.9.11-6e331b1
 - TS3 Plugin: installed (md5 hash match)
   - Bot Plugin: d1ddcca9fd7ace3caf85821656b425c2
   - TS3 Client: d1ddcca9fd7ace3caf85821656b425c2
 - Config:
   - LogLevel = 10 (debug log active)
   - TS3Path = /home/sinusbot/ts3/TeamSpeak3-Client-linux_amd64/ts3client_linux_amd64 (Version 3.0.18.2)
   - YoutubeDLPath = /usr/local/bin/youtube-dl (does exist, version: 2016.02.13)
 - Installed scripts: advertising.js; aloneMode.js; badchan.js; bookmark.js; clock.js; come.js; covatar.js; dev.js; followme.js; greeting-on-join.js; idle.js; metadata.js; musicList.js; norecording.js; playOnJoin.js; rememberChannel.js; showcase.js; sound.js; speech.js; twitch_status.js; welcometext.js

OTHER INFORMATION
 - Report date: 28.04.2016 20:25:36 CEST +02:00:00 (timezone: Europe/Berlin)
 - TeamSpeak 3 Version: 3.0.18.2
 - youtube-dl Version: 2016.04.24
 - DiagScript version: 0.4.5
==========================================================
```

**Notice**: Because this script does also collect information like CPU, RAM, SWAP, DISK usage and more, this script needs to be executed with root privileges. The script is not installing or changing any files without explicit asking before.
