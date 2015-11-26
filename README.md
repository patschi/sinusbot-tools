# sinusbot-tools

This repository contains some various tools or scripts for TeamSpeak 3 music bot named "Sinusbot". For more information about the bot, please visit [sinusbot.com](https://sinusbot.com). The forum is available at [forum.sinusbot.com](https://forum.sinusbot.com).

Any feedback, suggestions, ideas and - ofcourse - pull requests are welcome.

## diagSinusbot

[diagSinusbot.sh](https://github.com/patschi/sinusbot-tools/blob/master/tools/diagSinusbot.sh) collects some important diagnostic data about the operating system and the bot installation. When finished it returns informative information, ready to copy and paste it in the right section in the sinusbot forum. The main purpose of this script is to solve bugs and any other issues easier and faster with more details about the situation - easily collected with this script.

**Remember**: This script does not send any data to anywhere. It is only collecting some details offline about the system and the bot. Then it generates a text output, which can be copied and pasted in the forum.

**Some information which may be scanned:**
 * System
  - Operating system
  - Kernel
  - Load average
  - Uptime
  - CPU model, cores and speed
  - RAM usage
  - SWAP usage
  - DISK usage
  - Bot autostart script checks
 * Bot
  - Status of bot and webinterface
  - Version
  - Performs ts3client checks
  - Some configuration pre-checks
  - Checks if bot plugin is installed to ts3client
  - Checks LogLevel
  - Checks youtube-dl and installed version
  - Installed bot scripts (filenames only)
  - Checks if all required OS packages got installed

**Requirements:**
 * Operating System: Debian, Ubuntu
 * Installed Packages: `bc binutils coreutils lsb-release util-linux`
   - Install: `apt-get install bc binutils coreutils lsb-release util-linux`
   - (Most packages are already pre-installed by default on the most systems.)

**Usage:**
```
$ wget https://raw.githubusercontent.com/patschi/sinusbot-tools/master/tools/diagSinusbot.sh
$ bash diagSinusbot.sh
```

**Example output:**
```
==========================================================
SINUSBOT RELATED
SYSTEM INFORMATION
 - Operating System: Debian GNU/Linux 8.1 (jessie)
 - Kernel: Linux 3.16.0-4-amd64 x86_64
 - Load Average: 0.24 0.32 0.32
 - Uptime: 58 days, 23 hours, 44 minutes, 32 seconds
 - OS Updates: 0 (well done!)
 - OS Missing Packages: None (v1)
 - OS APT Last Update: 23.08.2015 00:41:12 CEST +02:00:00
 - Bot Start Script: found at /etc/init.d/sinusbot [perms: 0644]
 - CPU:
    Architecture:          x86_64
    CPU(s):                2
    Thread(s) per core:    1
    Core(s) per socket:    1
    Socket(s):             2
    Model name:            Intel(R) Xeon(R) CPU E5-1650 v2 @ 3.50GHz
    CPU MHz:               3499.999
    Hypervisor vendor:     VMware
    Virtualization type:   full
 - RAM: 449.76 MB/1000.32 MB in use (44%)
 - SWAP: 0 B/871.99 MB in use (0%)
 - DISK: 2.01 GB/15.73 GB in use (12%)
 - Report date: 26.11.2015 21:13:47 CET +01:00:00 (timezone: Europe/Berlin)

BOT INFORMATION
 - Status: running (PIDs: 23012 23011, User: sinusbot)
 - Webinterface: port locally reachable (Port: 8087)
 - Binary: /home/sinusbot/sinusbot/sinusbot (Hash: dfaa2dae26ee80b782b8b4b6cbf9fa5e)
 - Version: 0.9.9-4965f0f
 - TS3 Plugin: installed (md5 hash match)
   - Bot Plugin: 4f888043455d865231047616da069ed8
   - TS3 Client: 4f888043455d865231047616da069ed8
 - Config:
   - LogLevel = 4
   - TS3Path = /home/sinusbot/ts3/TeamSpeak3-Client-linux_amd64/ts3client_linux_amd64 (Version 3.0.18.2)
   - YoutubeDLPath = /usr/local/bin/youtube-dl (does exist, version: 2015.08.16.1)
 - Installed Scripts: advertising.js; aloneMode.js; badchan.js; bookmark.js; covatar.js; dev.js; followme.js; idle.js; metadata.js; norecording.js; showcase.js; welcometext.js
==========================================================
```

**Notice**: Because this script does also collect information like CPU, RAM, SWAP, DISK usage and more, this script needs to be executed with root privileges.
