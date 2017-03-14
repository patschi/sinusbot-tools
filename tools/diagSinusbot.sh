#!/bin/bash
#
### AUTHOR INFO
# (C) Patrik Kernstock
#  Website: pkern.at
#
### SCRIPT INFO
# Version: see in changelog
# Licence: GNU GPL v2
# Description:
#  Collects some important diagnostic data about
#  the operating system and the bot installation.
#  When finished it returns informative information,
#  ready to copy and paste it in the right section
#  in the sinusbot forum to your forum post.
#
# Important links:
#  Development of this script: https://github.com/patschi/sinusbot-tools
#  TeamSpeak: https://www.teamspeak.com
#  Sinusbot forum: https://forum.sinusbot.com
#  Sinusbot forum thread [english]: https://forum.sinusbot.com/threads/diagsinusbot-sh-sinusbot-diagnostic-script.831/#post-4418
#  Sinusbot forum thread [german]: https://forum.sinusbot.com/threads/diagsinusbot-sh-sinusbot-diagnostik-script.832/#post-4419
#
### CHANGELOG
#  v0.1.0:  [25.11.2015 12:00]
#           Release: Alpha.
#           New: Basic functionality.
#  v0.2.0:  [25.11.2015 14:00]
#           New: OpenVZ checks
#           New: YouTubeDL support
#           New: welcome header
#           New: asking for automated package install
#           New: Missing operating system packages check
#           New: Check when package manager was updated last time
#           New: parameter support
#           New: parameter: '-w|--no-welcome' to hide welcome text
#           New: parameter: '-u|--no-os-update-check' to skip OS update check
#  v0.2.1:  [25.11.2015 18:00]
#           Fixed: Corrected calculating RAM usage (now without cached RAM)
#           New: Added time as prefix to log messages
#           New: Added report date including timezone to output
#  v0.2.5:  [25.11.2015 21:00]
#           New: Added help with '-h|--help' parameter
#           New: More colorful output (everyone likes colors... and cookies.)
#           Fixed: TS3Path check if exists
#           Fixed: 'cpu model' was shown multiple times if more processors exists (even when different processors)
#           New: Fallback for bot location when binary not found to /opt/ts3bot/
#           Changed: Output style. From BBCode to clean text.
#           New: Added '-v|--version' parameter
#           New: Added '-c|--credits' parameter
#           Improved: own function for trimming whitespaces
#  v0.3.0:  [26.11.2015 19:00]
#           Release: Beta.
#           New: Added TS3Client version to output.
#           New: Added support to retrieve sinusbot version by 'sinusbot --version' parameter (including fallback to old method)
#           New: Added SWAP info display
#           New: Added DISK info display
#           New: Added KERNEL info display
#           New: Added LOAD AVERAGE info display
#           New: Added UPTIME info display
#           New: Added 'installed bot scripts' display
#           New: Added TS3client bot-plugin checks
#           New: Added bot running checks (and under which user it is running)
#           New: Added bot webinterface port checks
#           Improved: Supported operating system checks.
#  v0.3.1:  [26.11.2015 21:00]
#           Changed: Using 'lscpu' for determining CPU data now
#           New: Check for bot autostart script (/etc/init.d/sinusbot)
#  v0.3.2:  [26.11.2015 21:20]
#           New: Added advanced permissions checks for the autostart script
#  v0.3.3:  [02.12.2015 10:00]
#           New: Check if x64 bit operating system
#           New: Added DNS resolution check of google.com
#  v0.3.4:  [04.12.2015 18:15]
#           Changed: Switched from 'nc' to 'netstat' to determine if webinterface port is up
#           Improved: Some text changes
#  v0.3.5:  [01.01.2016 04:00]
#           Happy new year!
#           Changed: Added CODE-tags for forum to output
#           Changed copyright year
#  v0.3.6:  [16.01.2016 13:55]
#           Fixed some bugs in operating system package detection function
#           Fixed lsb_release errors when checking OS support before checking package installation of lsb-release
#           Fixed dpkg-query errors when package was never installed before (when package detection)
#  v0.3.7:  [29.01.2016 00:45]
#           Fixed retrieving of youtube-dl version when binary exists and is set in the bot configuration (Thanks Xuxe!, see PR #1 on Github)
#  v0.3.8:  [30.01.2016 12:55]
#           Added detection for LXC & Docker (Thanks Xuxe!, see PR #2 on Github)
#  v0.3.9:  [03.02.2016 20:30]
#           Mostly a bug fix release.
#           Added check if the scripts-folder does exist. (which hopefully fixes the issue of displaying files of a wrong folder)
#           Fixed issue with detecting Sinusbot version with "--version" parameter on some pre-release Sinusbot versions.
#           Changed the uppercase "S" in "Installed Scripts" to lowercase. Whyever I mention this here in the changelog.
#  v0.3.10: [03.02.2016 20:35]
#           Fixed a little issue with collecting installed scripts
#  v0.3.11: [03.02.2016 20:45]
#           Fixed LXC-detection bug
#  v0.4.0:  [08.02.2016 16:40]
#           Added 'known issues' section to the top of the script.
#           Added version check for this script.
#           Added automated updater for this script.
#           (The script is checking for a newer version of the diagnostic script on every start.)
#           Added diagSinusbot script version to code output.
#           Added check for vulnerable and outdated ts3client versions.
#           Added optional display of changelog for every update (if changelog file does exist).
#           New: New parameter '-o|--skip-update-check' to skip script update check.
#           New: New parameter '-u|--only-update-check|--update' to only check for script update and then abort.
#           Changed: Renamed parameter '--no-os-update-check' to '--skip-os-update-check'.
#           Changed: Renamed short parameter '-u' to '-a' (for skipping APT OS update checks).
#           Changed: Renamed parameter '--no-welcome' to '--skip-welcome-text'. Short parameter stays the same.
#           Changed: Optimized say-function to be able to output bold text.
#           Some cosmetic and overall little improvements.
#           Fixed LXC detection (finally).
#  v0.4.1:  [21.03.2016 13:15]
#           Added check if webinterface is listening either on IPv4 or IPv6 localhost.
#           Fixed detection if libglib2.0-0 package is installed properly. (Thanks for testing iTaskmanager)
#           Improved installed-package detection a bit.
#  v0.4.2:  [14.04.2016 13:15]
#           > This is just a bugfix release, fixing some issues on non-english operating system-setups.
#           > Thanks for testing and letting me know about the issues, MaxS! [from the Sinusbot forum]
#           Added connection timeout for outgoing web requests (e.g. for script update checks).
#           Added some checks of RAM, SWAP and DISK parsing functions when any errors happens.
#           Reworked the way how RAM and SWAP information gets read from the system (not OS language-dependend anymore).
#           Changed: Calculate md5 hash of installed TS3 plugin even if the bot plugin does not exist in the bot directory.
#           Fixed: Reading out RAM and SWAP-data was not possible when the operating system had any other language than english.
#           Fixed: Retrieving permissions of the sinusbot init.d script did not work on systems with any other language than english.
#           Known issue: Getting DISK data on OpenVZ machines and non-english systems may still not work. Not critical, fix may be released in the future.
#  v0.4.3:  [14.04.2016 13:30]
#           > This is just a very very small and silent micro-release making some non-mentionable improvements.
#           Updated: Added simple warning/notice to SWAP output when SWAP is disabled.
#           Updated: 'Known issues' section in script file itself.
#  v0.4.4:  [28.04.2016 20:26]
#           > Some little improvements and new version check for recent 3.0.19 TS3 client and glibc library.
#           Added glibc version check and output.
#           Added warning for TS3 client 3.0.19 on Debian 8 and older.
#           Added commands "sort" and "head" to required commands for this diagnostic script.
#           Improved bot binary search functionality.
#  v0.4.5:  [28.04.2016 22:25]
#           Fixed wrong calculation of RAM usage.
#  v0.4.6:  [04.09.2016 16:30]
#           Added: Additionally search the bot binary in /opt/ts3soundboard/
#           Added: Additionally search the bot binary in /opt/sinusbot/
#           Added messages when not using x64 arch or DNS resolution is broken.
#           Updated some messages and various text output
#           Moved TS3 client version functionality into own seperate function.
#           Disabled "TS3 v3.0.19-outdated"-warning on Debian 8 systems. (Does work on this OS)
#           Improved overall syntax.
#           Cleaned up script.
#  v0.4.7:  [01.03.2017 15:10]
#           Restricted scripts listening to files with *.js extension. (Thanks @maxibanki, PR#4)
#           Fixed detection of local reachable webinterface port. (finally! Issue was that passing the var to awk failed)
#           Updated copyright.
#  v0.5.0:  [01.03.2017 22:15]
#           Added check mechanism if using TS3 client 3.1 and later with Sinusbot 0.9.18 and older, which is not working due to TS3 client API changes.
#           Added outgoing HTTPS access checks, IPv4- and IPv6-only modes.
#           Additionally searching for initd-script at /etc/init.d/ts3bot, and systemd config at /etc/systemd/system/sinusbot.service.
#           Now checking DNS resolution of sinusbot.com instead of Google.com.
#           Now displaying the URL where all changelogs can be found when viewing the latest changelog during the script update process.
#           Improved version compare handling.
#           Fixed some typos.
#  v0.5.1:  [14.03.2017 20:30]
#           Added some required dependencies for the script to execute.
#           Clarify warn messages of HTTPS access checks.
#           Fixed docker integration.
#           Some under-the-hood improvements.
#
### Known issues:
# Mostly this issues are non-critical and just kind of hard to fix or workaround.
# If you have any ideas, feel free to tell me them.
#
# - Getting DISK data on OpenVZ machines and non-english systems may still not work.
#
### THANKS TO...
# all people, who helped developing and testing
# this script in any way. For more information
# see with parameter: '-c' or '--credits'.
#
### USAGE
# To download and execute this script you can use:
#  $ cd /path/to/sinusbot/ # usually /opt/ts3bot/
#  $ curl -O https://raw.githubusercontent.com/patschi/sinusbot-tools/master/tools/diagSinusbot.sh
#  $ bash diagSinusbot.sh
#  $ rm diagSinusbot.sh # optionally to cleanup
#
# Simple One-liner:
#  $ curl https://raw.githubusercontent.com/patschi/sinusbot-tools/master/tools/diagSinusbot.sh | bash
#
### DISCLAIMER
# No warranty, execute on your own risk.
# No cats were harmed during development.
# May contain traces of eastereggs.
#
##################################################
#### DO NOT TOUCH ANYTHING BELOW, IF YOU
#### DO NOT KNOW WHAT YOU ARE DOING!
##################################################

### SCRIPT CONFIGURATION VARIABLES
# setting important variables

# general settings
# SCRIPT
SCRIPT_AUTHOR_NAME="Patrik Kernstock aka. Patschi"
SCRIPT_AUTHOR_WEBSITE="pkern.at"
SCRIPT_YEAR="2015-2017"

SCRIPT_NAME="diagSinusbot"
SCRIPT_VERSION_NUMBER="0.5.1"
SCRIPT_VERSION_DATE="14.03.2017 20:30"

VERSION_CHANNEL="master"
SCRIPT_PROJECT_SITE="https://github.com/patschi/sinusbot-tools/tree/$VERSION_CHANNEL"
SCRIPT_PROJECT_DLURL="https://raw.githubusercontent.com/patschi/sinusbot-tools/$VERSION_CHANNEL/tools/diagSinusbot.sh"

SCRIPT_VERSION_FILE="https://raw.githubusercontent.com/patschi/sinusbot-tools/$VERSION_CHANNEL/tools/updates/diagSinusbot/version.txt"
SCRIPT_CHANGELOG_LIST="https://github.com/patschi/sinusbot-tools/tree/master/tools/updates/diagSinusbot"
SCRIPT_CHANGELOG_FILE="https://raw.githubusercontent.com/patschi/sinusbot-tools/$VERSION_CHANNEL/tools/updates/diagSinusbot/changelog-{VER}.txt"

# script COMMANDS dependencies
SCRIPT_REQ_CMDS="apt-get pwd awk wc free grep echo cat date df stat getconf netstat sort head curl"
# script PACKAGES dependencies
SCRIPT_REQ_PKGS="bc binutils coreutils lsb-release util-linux net-tools curl"

# which domain to check for accessibility
CHECK_WEB_URL="https://sinusbot.com/diag"
CHECK_DOMAIN_ACCESS="auto"

# BOT
# bot PACKAGES dependencies
BOT_REQ_PACKAGES="ca-certificates bzip2 libglib2.0-0 sudo screen python"
BOT_REQ_PACKAGES_VER="1"

### FUNCTIONS
## Function for text output
say()
{
	if [ -z "$1" ] && [ -z "$2" ]; then
		echo
		return
	fi

	# criteria
	local CRIT=$(echo "$1" | tr '[:lower:]' '[:upper:]')

	# message
	local MSG="$2"
	local MSG="$(string_replace "$MSG" "\[b\]" "\x1b[1m")"
	local MSG="$(string_replace "$MSG" "\[\/b\]" "\x1b[0m")"

	# default prefix
	local PREFIX=""

	# modes for echo command
	local MODES="-e"
	if [ "$CRIT" == "WAIT" ] || [ "$CRIT" == "QUESTION" ]; then
		local MODES="$MODES -n"
	fi

	# color for criterias
	if [ ! -z "$CRIT" ]; then
		# prefix
		local PREFIX="[$(date +"%Y-%m-%d %H:%M:%S")] "

		case "$CRIT" in
			ERROR)
				# RED
				CRIT="\e[0;31m$CRIT\e[0;37m"
				;;

			WARNING)
				# YELLOW
				CRIT="\e[0;33m$CRIT\e[0;37m"
				;;

			INFO)
				# CYAN
				CRIT="\e[0;36m$CRIT\e[0;37m"
				;;

			OKAY|QUESTION|WAIT|WELCOME)
				# GREEN
				CRIT="\e[0;32m$CRIT\e[0;37m"
				;;

			DEBUG)
				# PURPLE
				CRIT="\e[0;35m$CRIT\e[0;37m"
				;;

			*)
				# WHITE
				CRIT="\e[0;37m$CRIT"
				;;
		esac
	fi

	echo -ne "\e[40m"
	# echo message
	if [ ! -z "$CRIT" ]; then
		# if $CRIT is set...
		echo $MODES "$PREFIX[$CRIT] $MSG"
	else
		# if $CRIT is NOT set...
		echo $MODES "$PREFIX$MSG"
	fi
	echo -ne "\e[0m"
}

## Function for string replacing (Usage: string_replace "string" "pattern" "replacement")
string_replace()
{
	# (the missing $ of "$1" is correct!)
	echo "${1/$2/$3}"
}

## Function to parse comments from the script file
parse_version_comment_line()
{
	echo $(echo "$1" | awk 'match($0, /# Version: (.*)/) { print $3 };')
}

## Function to pause till input
pause()
{
	say "wait" "Press [ENTER] to continue..."
	await_answer
}

## Function for welcome header
show_welcome()
{
	# do not forget to manually replace the domain name
	# below here with the domain behind $CHECK_DOMAIN_ACCESS!
	# AND keep the format that style! (justify the text)
	say
	say "welcome" "================================================="
	say "welcome" "= [b]HELLO![/b] Please invest some time to read this.  ="
	say "welcome" "=                                               ="
	say "welcome" "=  Thanks  for  using  this diagnostic script!  ="
	say "welcome" "=  The  more  information  you   provide,  the  ="
	say "welcome" "=  better  we  can help to solve your problem.  ="
	say "welcome" "=                                               ="
	say "welcome" "=  The  execution  may  take  some  moments to  ="
	say "welcome" "=  collection  the most  important information  ="
	say "welcome" "=  of your system  and  your bot installation.  ="
	say "welcome" "=                                               ="
	say "welcome" "=  After  everything  is  done, you will get a  ="
	say "welcome" "=  diagnostic output, ready for copy & pasting  ="
	say "welcome" "=  it within a CODE-tag in the Sinusbot forum.  ="
	say "welcome" "=  [Link: https://forum.sinusbot.com]           ="
	say "welcome" "=                                               ="
	say "welcome" "=  No  private  information  will be collected  ="
	say "welcome" "=  nor  the  data  will  be  sent to anywhere.  ="
	say "welcome" "=  This  just generates an example forum post.  ="
	say "welcome" "=                                               ="
	say "welcome" "=  The script does perform a DNS resolution of  ="
	say "welcome" "=  the domain 'sinusbot.com' to  determine  if  ="
	say "welcome" "=  your  DNS settings are working as expected.  ="
	say "welcome" "================================================="
	say "welcome" "= I am thankful for any feedback. Please  also  ="
	say "welcome" "= report any issues you may find either on the  ="
	say "welcome" "= Sinusbot forum or via GitHub issues. Thanks!  ="
	say "welcome" "=   -- $SCRIPT_AUTHOR_NAME.           ="
	say "welcome" "================================================="
	say
	pause
}

## Function to show help text
show_help()
{
	say "info" "Available parameters:"
	say "info" "  -h|--help                  This help."
	say "info" "  -w|--skip-welcome-text     Skips the welcome screen."
	say "info" "  -a|--skip-os-update-check  Skips the APT OS updates check."
	say "info" "  -o|--skip-update-check     Skips the script update check."
	say "info" "  -u|--only-update-check     Only check for script update. (overrides update skip)"
	say "info" "  -c|--credits               Show credits."
	say "info" "  -v|--version               Show version."
	say "info" "  moo                        The cow says."
	say "info" "This tool has Super Cow Powers."
}

## Function to show current version
show_version()
{
	say "info" "(C) $SCRIPT_YEAR, $SCRIPT_AUTHOR_NAME ($SCRIPT_AUTHOR_WEBSITE)"
	say "info" "$SCRIPT_NAME v$SCRIPT_VERSION_NUMBER [$SCRIPT_VERSION_DATE]"
	say "info" "Project site...: $SCRIPT_PROJECT_SITE"
	say "info" "Script download: $SCRIPT_PROJECT_DLURL"
}

## Function to show credits (whooaaa!)
show_credits()
{
	say "info" ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	say "info" " THANKS TO EVERYONE WHO HAVE HELPED IN ANY WAY!"
	say "info" " Special thanks goes to..."
	say "info" ""
	say "info" "   [b]flyth[/b]            Michael F.     for developing sinusbot, testing this script and ideas"
	say "info" "   [b]Xuxe[/b]             Julian H.      for testing, ideas and contributing code"
	say "info" "   [b]GetMeOutOfHere[/b]   -              for testing and ideas"
	say "info" "   [b]JANNIX[/b]           Jan H.         for testing"
	say "info" "   [b]maxibanki[/b]        Max S.         for testing, finding bugs and contributing code"
	say "info" ""
	say "info" " ...if u see 'em somewhere, give 'em some chocolate cookieees!"
	say "info" "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}

## Function t000 m0o0o0o0o0o0oo t000d4y
show_moo()
{
	cat <<EOF
                 (__)
                 (oo)
           /------\/
          / |    ||
         *  /\---/\\
            ~~   ~~
..."Have you mooed today?"...
EOF
}

## Function when something fails
failed()
{
	say "error" "Something went wrong!"
	say "wait" "Press [ENTER] to exit."
	read -p ""
	if [ ! -z "$1" ]; then
		say "debug" "exit reason code: $1"
	fi
	exit 1
}

## Function for human output
bytes_format()
{
	# This separates the number from the text
	local SPACE=" "
	# Convert input parameter (number of bytes)
	# to Human Readable form
	local SLIST="B,KB,MB,GB,TB,PB,EB,ZB,YB"
	local POWER=1
	local VAL=$(echo "scale=2; $1 * 1024" | bc)
	local VINT=$(echo $VAL / 1024 | bc )

	while [ $VINT -gt 0 ]; do
		let POWER=POWER+1
		local VAL=$(echo "scale=2; $VAL / 1024" | bc)
		local VINT=$(echo $VAL / 1024 | bc )
	done

	echo "$VAL$SPACE$(echo $SLIST | cut -f$POWER -d',')"
}

## Function to confirm a command
confirm_package_install()
{
	say "question" "Should I install '$1' for you? [y/N] "
	if [[ $(await_answer) =~ [yY](es)* ]]; then
		INSTALL_CMD="apt-get install -y $1"
		say "debug" "Installing package '$1' using '$INSTALL_CMD'..."
		sleep 1
		eval "$INSTALL_CMD"
		if [ $? -ne 0 ]; then
			say "error" "Installing package '$1' went wrong! Check and retry."
			failed "failed package installation"
		else
			return 0
		fi
	else
		return 1
	fi
}

## Function for checking commands
check_command()
{
	if ! which "$1" >/dev/null; then
		if [ -z "$2" ]; then
			say "error" "Missing command '$1'."
			return 1
		else
			say "error" "Missing command '$1'. Please install package '$2': apt-get install $2"
			confirm_package_install "$2"
			if [ $? -ne 0 ]; then
				return 1
			else
				return 0
			fi
		fi
		return 1
	else
		return 0
	fi
}

## Function for checking if command exists
is_command_available()
{
	if which "$1" >/dev/null; then
		return 0
	else
		return 1
	fi
}

## Function to check root privileges
is_user_root()
{
	if [ "$(id -u)" -ne 0 ]; then
		say "error" "This diagnostic script must be run with root privileges!"
		say "info"  "[b]Reason[/b]: This script does perform many different checks and some of them"
		say "info"  "do require root privileges to do so - example: apt-get calls, port checks,"
		say "info"  "or to even be able to operate, if any permissions are set wrong."
		failed "no root privileges"
	fi
}

## Function to check if it is a debian-based operating system
is_supported_os()
{
	SYS_OS_LSBRELEASE_ID=$(lsb_release --id --short | tr '[:upper:]' '[:lower:]')
	SYS_OS_LSBRELEASE_RELEASE=$(lsb_release --release --short | tr '[:upper:]' '[:lower:]')
	SYS_OS_LSBRELEASE_RELEASE_MAJOR=$(echo "$SYS_OS_LSBRELEASE_RELEASE" | awk -F'.' '{ print $1 }')
	SYS_OS_LSBRELEASE_DESCRIPTION=$(lsb_release --description --short)

	# check if operating system supported
	if [ "$SYS_OS_LSBRELEASE_ID" != "debian" ] && [ "$SYS_OS_LSBRELEASE_ID" != "ubuntu" ]; then
		say "error" "This script is only working on the operating systems Debian and Ubuntu!"
		failed "unsupported operating system"
	fi

	say "info" "Detected operating system: $SYS_OS_LSBRELEASE_DESCRIPTION"

	# check version of operating system: debian
	if [ "$SYS_OS_LSBRELEASE_ID" == "debian" ] && (( $(echo "$SYS_OS_LSBRELEASE_RELEASE_MAJOR <= 6" | bc -l) )); then
		# is less or equal 6 = too old.
		say "warning" "You are using a too old operating system! Debian Squeeze and before are not officially supported for Sinusbot. Please upgrade to a more recent system."
		sleep 1
	fi

	# check version of operating system: ubuntu
	if [ "$SYS_OS_LSBRELEASE_ID" == "ubuntu" ] && (( $(echo "$SYS_OS_LSBRELEASE_RELEASE <= 12.04" | bc -l) )); then
		# is less or equal 12.04 = too old.
		say "warning" "You are using a too old operating system! Ubuntu 12.04 and before are not officially supported for Sinusbot. Please upgrade to a more recent system."
		sleep 1
	fi
}

## Function to crawl given URL
load_webfile()
{
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	curl -q --fail --connect-timeout 10 --silent "$1"
}

## Function to check outgoing IPv4 connections
check_web_ipv4()
{
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	curl -q --fail --insecure --ipv4 --silent --connect-timeout 10 "$1" &>/dev/null
	return $?
}

## Function to check outgoing IPv6 connections
check_web_ipv6()
{
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	curl -q --fail --insecure --ipv6 --silent --connect-timeout 10 "$1" &>/dev/null
	return $?
}

## Function to parse host from a given URL
parse_host_of_url()
{
	echo "$(echo "$1" | awk -F/ '{ print $3 }')"
}

## Function to check if a new update is available
script_check_for_update()
{
	# Return codes:
	#  0 = no update
	#  1 = failed retrieving info
	#  2 = update available
	local UPD_CHECK=$(load_webfile "$SCRIPT_VERSION_FILE")
	if [ $? -ne 0 ]; then
		return 1
	else
		local UPD_CHECK_STATUS="$(echo "$UPD_CHECK" | grep -Po '(?<="status": ")[^"]*')"
		if [ "$UPD_CHECK_STATUS" != "true" ]; then
			return 1
		else
			UPD_CHECK_VER="$(echo "$UPD_CHECK" | grep -Po '(?<="version": ")[^"]*')"
			if compare_version $SCRIPT_VERSION_NUMBER $UPD_CHECK_VER; then
				return 2
			else
				return 0
			fi
		fi
	fi
}

## Function to check if there is a changelog for the given version number
script_check_for_changelog()
{
	# Return codes:
	#  1 = failed retrieving changelog
	# ...else changelog may be returned.
	local UPD_CHANGELOG=$(load_webfile "$(script_get_changelog_url "$1")")
	if [ $? -ne 0 ]; then
		return 1
	else
		echo "$UPD_CHANGELOG"
	fi
}

## Function to get actual changelog url file of the given version number
script_get_changelog_url()
{
	string_replace "$SCRIPT_CHANGELOG_FILE" "\{VER\}" "$1"
}

## Function to compare version numbers
compare_version()
{
	# Return codes:
	#  0 = does not match (means: there is a newer version available)
	#  1 = does match (means: no other version available = no update)
	if [ "$1" == "$2" ]; then
		return 1
	else
		if [ "$1" == "$(echo -e "$1\n$2" | sort --version-sort --reverse | head -n1)" ]; then
			return 1
		else
			return 0
		fi
	fi
}

## Function to search bot binary
check_bot_binary()
{
	BOT_BINARY=""
	local BINARIES="ts3bot sinusbot"
	for BINARY in $BINARIES; do
		if [ -f "$BOT_PATH/$BINARY" ]; then
			BOT_BINARY="$BINARY"
			say "debug" "Binary '$BOT_BINARY' found."
		fi
	done

	if [ -z "$BOT_BINARY" ]; then
		# empty. not found.
		return 1
	else
		return 0
	fi
}

## Function to check if bot config exists
check_bot_config()
{
	if [ ! -f "$BOT_PATH/config.ini" ]; then
		say "error" "Bot configuration not found!"
		failed "bot config not found"
	fi
}

## Function to check available updates via apt-get
check_available_updates()
{
	apt-get -s dist-upgrade | awk '/^Inst/ { print $2 }' | wc -l
}

## Function to parse bot configuration file
parse_bot_config()
{
	echo "$BOT_CONFIG" | grep "$1" | cut -d '=' -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -e 's/^[\"]*//' -e 's/[\"]*$//'
}

## Function to get version of sinusbot
get_bot_version()
{
	say "debug" "Trying to get sinusbot version using version parameter..." > /proc/${PPID}/fd/0
	local BOT_VERSION_CMD=$("$BOT_PATH/$BOT_BINARY" --version 2>/dev/null)
	echo "$BOT_VERSION_CMD" | grep -q -P '^flag provided but not defined' >/dev/null
	if [ $? -eq 0 ]; then
		say "debug" "Error getting sinusbot version. Falling back to other method." > /proc/${PPID}/fd/0
		local BOT_VERSION_STRING=$(strings "$BOT_PATH/$BOT_BINARY" | grep "Version:" | cut -d ' ' -f2)
		if [ "$BOT_VERSION_STRING" != "" ]; then
			echo "$BOT_VERSION_STRING"
		else
			echo "unknown"
		fi
	else
		local BOT_VERSION_CMD=$(echo -e "$BOT_VERSION_CMD" | egrep "^SinusBot" | awk '{ print $2 }')
		echo "$BOT_VERSION_CMD"
	fi
}

## Function to get version of the ts3 client
get_ts3_client_version()
{
	local TS3_VER=$(awk 'match($0, /Client Release (.*)/) { print $4 };' "$1" | awk 'NR==1')
	if [ $? -ne 0 ]; then
		TS3_VER="unknown"
	fi
	echo "$TS3_VER"
}

## Function to check if package is installed
is_os_package_installed()
{
	dpkg-query -W -f='${Status}' "$1" 2>&1 | grep -q -P 'install ok installed' 2>&1
	if [ $? -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

## Function to get the current installed version for a given package
get_installed_version_package()
{
	local PKG_VERSION="$(dpkg-query -W -f='${Version}' "$1" 2>&1)"
	if [ $? -eq 0 ]; then
		echo "$PKG_VERSION"
	else
		echo "unknown"
	fi
}

## Function to check if package is installed
is_os_package_installed_check()
{
	if ! is_os_package_installed "$1"; then
		say "error" "Missing package '$1'. Please install package '$2': apt-get install $2"
		confirm_package_install "$2"
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	fi
}

## Function to get missing packages from a list
get_missing_os_packages()
{
	local OS_PACKAGES_MISSING=""
	for PACKAGE in $1; do
		is_os_package_installed "$PACKAGE"
		if [ $? -ne 0 ]; then
			local OS_PACKAGES_MISSING="$OS_PACKAGES_MISSING $PACKAGE"
		fi
	done
	trim_spaces "$OS_PACKAGES_MISSING"
}

## Function to get installed scripts
get_installed_bot_scripts()
{
	local INSTALLED_SCRIPTS=""
	if [ -d "$BOT_PATH/scripts/" ]; then
		for SCRIPT_FILE in $BOT_PATH/scripts/*.js; do
			if [ "$INSTALLED_SCRIPTS" == "" ]; then
				local INSTALLED_SCRIPTS="$(basename "$SCRIPT_FILE")"
			else
				local INSTALLED_SCRIPTS="$INSTALLED_SCRIPTS; $(basename "$SCRIPT_FILE")"
			fi
		done
		trim_spaces "$INSTALLED_SCRIPTS"
	else
		echo "scripts folder not found (using < v0.9.9?)"
	fi
}

## Function to trim whitespaces before and after a string
trim_spaces()
{
	echo -e "$(echo -e "$@" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}

## Function to get a md5 hash of a file
get_file_hash()
{
	if [ -f "$1" ]; then
		md5sum "$1" | awk '{print $1}'
	else
		echo "unknown"
	fi
}

## Function to check if port is in use
port_in_use()
{
	PORT=$1
	# check if port $1 is in use.
	netstat -lnt | awk -v port="$PORT" '$4 ~ "."port' | grep -i 'LISTEN' &>/dev/null
	return $?
}

## Function to get user id from a running process id
get_userid_from_pid()
{
	grep -r '^Uid:' /proc/$1/status | cut -f2
}

## Function to get username by id (linux os)
get_user_name_by_uid()
{
	awk -F: "/:$1:/{print \$1}" /etc/passwd
}

## Function which exites the script with a successful exit code
script_done()
{
	exit 0
}

## Function to resolve hostname to IP
resolve_hostname()
{
	echo $(getent hosts "$1" | head -n 1 | cut -d ' ' -f 1)
}

## Function to check DNS resolution
check_dns_resolution()
{
	if [ "$(resolve_hostname "$1")" != "" ]; then
		return 0
	else
		return 1
	fi
}

## Function await answer
await_answer()
{
	# workaround with /proc/[...] required only when read command
	# is in a function. When not given, the script may not wait
	# for an entered answer.
	read -p "" prompt < /proc/${PPID}/fd/0
	echo "$prompt"
}

################
## MAIN CODE! ##
################

SCRIPT_PATH=$(pwd)

# PARAMETERS
while [ $# -gt 0 ]; do
	case "$1" in
		-w|--skip-welcome-text )
			NO_WELCOME="yes"
		;;

		-a|--skip-os-update-check )
			NO_OS_UPD_CHECK="yes"
		;;

		-o|--skip-update-check )
			NO_UPD_CHECK="yes"
		;;

		-u|--only-update-check|--update )
			ONLY_SCRIPT_UPDATE_CHECK="yes"
		;;

		-h|--help )
			show_help
			script_done
		;;

		-c|--credits )
			show_credits
			script_done
		;;

		-v|--version )
			show_version
			script_done
		;;

		moo )
			show_moo
			script_done
		;;

		# unknown parameters
		-*|--* )
			say "warning" "Unknown parameter: '$1'."
		;;
	esac
shift
done

# further checks.
is_user_root

# do not show welcome screen, when user dont want to
if [ "$NO_WELCOME" != "yes" ]; then
	show_welcome
fi

# check if commands are available for the script
REQ_CMDS=0
for SMCMD in $SCRIPT_REQ_CMDS; do
	check_command "$SMCMD"
	if [ $? -ne 0 ]; then
		REQ_CMDS=1
	fi
done

# checking scripts
for SMCMD in $SCRIPT_REQ_CMDS; do
	check_command "$SMCMD"
	if [ $? -ne 0 ]; then
		REQ_CMDS=1
	fi
done

# running what...?
say "info" "Starting $SCRIPT_NAME v$SCRIPT_VERSION_NUMBER [$SCRIPT_VERSION_DATE]..."

# Check if we want to automatically set the domain access
if [ "$CHECK_DOMAIN_ACCESS" = "auto" ]; then
	CHECK_DOMAIN_ACCESS="$(parse_host_of_url "$CHECK_WEB_URL")"
fi

# check if any commands are missing
if [ $REQ_CMDS -ne 0 ]; then
	say "error" "Missing commands... Install and try again please."
	failed "missing commands"
fi

# checking script dependencies
PACKAGES_MISSING=$(get_missing_os_packages "$SCRIPT_REQ_PKGS")
if [ "$PACKAGES_MISSING" != "" ]; then
	say "warning" "Required packages for the script are not installed on this system."
	say "info" "Following packages are missing: $PACKAGES_MISSING"

	say "question" "Should I install them for you now? [y/N] "
	if [[ $(await_answer) =~ [yY](es)* ]]; then
		INSTALL_CMD="apt-get install -y $PACKAGES_MISSING"
		say "debug" "Installing packages using '$INSTALL_CMD'..."
		sleep 1
		# initiating installation
		eval "$INSTALL_CMD"
		# check if everything worked
		if [ $? -ne 0 ]; then
			say "error" "Installation went wrong! Please install required packages manually!"
			failed "failed package installation for script"
		else
			say "info" "Installation seems to be finished. Please re-run this script now!"
			script_done
		fi
	else
		say "warning" "Installation aborted. Please install the packages yourself before re-starting this script."
		failed "automated script installation aborted"
	fi
fi

# check for script update... maybe there are important changes, or something like that.
# ofcourse skip check, if the user don't want to stay up 2 date.
if [ "$NO_UPD_CHECK" == "yes" ] && [ "$ONLY_SCRIPT_UPDATE_CHECK" != "yes" ]; then
	say "warning" "Script update check skipped by user. This is NOT recommended!"

	say "warning" "Please at least check manually if there is any new update available."
	say "warning" "You are currently using script version: $SCRIPT_VERSION_NUMBER from $SCRIPT_VERSION_DATE."
	say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"

else
	DISPLAY_CHANGELOG="yes"

	say "info" "Checking for new diagnostic script version..."
	script_check_for_update
	UPD_CHECK_RETURN=$?
	if [ $UPD_CHECK_RETURN -eq 0 ]; then
		say "okay" "You are using the latest version."
	else
		if [ $UPD_CHECK_RETURN -eq 2 ]; then
			say "info" "There is a new version available for download! You are using v$SCRIPT_VERSION_NUMBER, but v$UPD_CHECK_VER is already available."
			say "info" "It is recommended to update the script to the latest version before continuing executing this diagnostic script."

			# does the user want to see the changelog?
			say "question" "Do you want to see the changelog of the recent update? [Y/n] "
			if [[ $(await_answer) =~ [nN](o)* ]]; then
				DISPLAY_CHANGELOG="no"
			fi

			# load and show it!
			if [ "$DISPLAY_CHANGELOG" == "yes" ]; then
				# hint for complete changelog.
				say "info" "######################################################################################"
				say "info" " The complete detailed history of every release you may find under the following URL:"
				say "info" " > $SCRIPT_CHANGELOG_LIST"
				say "info" "######################################################################################"
				# trying to get changelog
				say "debug" "Trying to get script update changelog..."
				CHANGELOG="$(script_check_for_changelog "$UPD_CHECK_VER")"
				if [ "$CHANGELOG" != "" ]; then
					say "info" "Displaying CHANGELOG for diagSinusbot v$UPD_CHECK_VER:"
					say "info" "######################################################################################"
					while IFS= read -r line; do
						say "info" " $line"
					done <<< "$CHANGELOG"
					say "info" "######################################################################################"
				else
					say "warning" "Failed getting update changelog."
					say "debug" "Tried getting changelog from '$(script_get_changelog_url "$UPD_CHECK_VER")'..."
				fi
			fi

			# do u wanna update?
			say "question" "Should I automatically update the diagnostic script for you? [Y/n] "
			# default is here yes. So if the user says explicity no, we do nothing than throwing out some text.
			if [[ $(await_answer) =~ [nN](o)* ]]; then
				say "warning" "Automated update skipped by user."
				sleep 1

				say "warning" "Please at least update the diagnostic script manually before continuing using this script."
				say "warning" "You are currently using version: $SCRIPT_VERSION_NUMBER from $SCRIPT_VERSION_DATE, but v$UPD_CHECK_VER is already available."
				say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"
				sleep 1

				pause
			else
				say "info" "Downloading new script version..."
				say "debug" "Download script URL: '$SCRIPT_PROJECT_DLURL'."
				CUR_SCRIPT_PATH="$SCRIPT_PATH/$(basename "$0")"

				# check if tmp file of this script does already exist. if so, we delete it.
				if [ -f "$CUR_SCRIPT_PATH.tmp" ]; then
					rm "$CUR_SCRIPT_PATH.tmp"
				fi

				# downloading new script...
				curl -o "$CUR_SCRIPT_PATH.tmp" "$SCRIPT_PROJECT_DLURL"
				if [ $? -ne 0 ]; then
					say "error" "Error when downloading the new script! Please investigate issues and try again. Skipping update for now."
					say "warning" "Please at least update the diagnostic script manually before continuing using this script."
					say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"
					pause
				else

					if [ ! -f "$CUR_SCRIPT_PATH.tmp" ]; then
						say "error" "Strange issue here: Even after successful download according to the exit status, the new script file is missing. Please investigate."
						say "warning" "Please at least update the diagnostic script manually before continuing using this script."
						say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"
						pause
					else

						# check syntax of new script (should be enough to detect non-bash script files, when something got wrong when downloading)
						bash -n "$CUR_SCRIPT_PATH.tmp" &>/dev/null
						if [ $? -ne 0 ]; then
							say "error" "Something went wrong while downloading the script. Either the download failed or the syntax of the script is faulty."
							say "warning" "Skipping automated update..."
							sleep 1

							say "warning" "Please at least update the diagnostic script manually before continuing using this script."
							say "warning" "You are currently using version: $SCRIPT_VERSION_NUMBER from $SCRIPT_VERSION_DATE, but v$UPD_CHECK_VER is already available."
							say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"
							pause

						else

							# make backup of old script
							mv "$CUR_SCRIPT_PATH" "$CUR_SCRIPT_PATH.bak"
							if [ $? -ne 0 ] || [ ! -f "$CUR_SCRIPT_PATH.bak" ]; then
								say "error" "Strange issue here: Renaming script file to backup file did failed. Skipping update. Please investigate."
								say "warning" "Please at least update the diagnostic script manually before continuing using this script."
								say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"
								pause
							else

								# rename temp update script to the filename of before
								mv "$CUR_SCRIPT_PATH.tmp" "$CUR_SCRIPT_PATH"
								if [ $? -ne 0 ] || [ ! -f "$CUR_SCRIPT_PATH.bak" ]; then
									say "error" "Strange issue here: Renaming the new script file to the original file name failed. Skipping update. Please investigate."
									say "warning" "Please at least update the diagnostic script manually before continuing using this script."
									say "warning" "The latest script can be found at: $SCRIPT_PROJECT_DLURL"
									pause
								else

									say "info" "Update complete. Please re-run the script, so that the changes take effect!"
									sleep 1

									say "info" "Thanks for using and updating the script! :)"
									say
									say "info" "Re-run the script using the command:"
									say "info" " $ bash $CUR_SCRIPT_PATH"
									say

									pause
									exit 0
								fi
							fi
						fi
					fi
				fi
			fi

		else
			say "error" "There was an error while checking for an update. Check your internet connection."
			say "info" "Make sure that the version check file is accessible by the server:"
			say "info" "> URL: $SCRIPT_VERSION_FILE"
			pause
		fi
	fi
fi

# check if only script update check was initiated
if [ "$ONLY_SCRIPT_UPDATE_CHECK" == "yes" ]; then
	say "debug" "Only update check was initiated. Exiting..."
	exit 0
fi

# checking bot dependencies
PACKAGES_MISSING=$(get_missing_os_packages "$BOT_REQ_PACKAGES")
if [ "$PACKAGES_MISSING" != "" ]; then
	say "warning" "Required packages for the bot are not installed on this system."
	say "info" "Following packages are missing: $PACKAGES_MISSING"

	say "question" "Should I install them for you now? [y/N] "
	if [[ $(await_answer) =~ [yY](es)* ]]; then
		INSTALL_CMD="apt-get install -y $PACKAGES_MISSING"
		say "debug" "Installing packages using '$INSTALL_CMD'..."
		sleep 1
		# initiating installation
		eval "$INSTALL_CMD"
		# check if everything worked
		if [ $? -ne 0 ]; then
			say "error" "Installation went wrong! Please install required packages manually!"
			failed "failed package installation for bot"
		else
			say "info" "Installation seems to be finished. Please re-run this script now!"
			script_done
		fi
	else
		say "warning" "Installation aborted. Please install the packages yourself before re-starting the bot."
		failed "automated bot installation aborted"
	fi
fi

# checking if OS is supported after package installation
is_supported_os

# checking dependencies for bot
if [ "$PACKAGES_MISSING" == "" ]; then
	SYS_PACKAGES_MISSING="None (v$BOT_REQ_PACKAGES_VER)"
else
	SYS_PACKAGES_MISSING="Missing packages: $PACKAGES_MISSING"
fi

# bot binary searching
say "info" "Searching bot binary..."

# checking for bot binary file
BOT_PATH=""

# possible bot paths
BOT_PATHS=("$(pwd)" "/opt/sinusbot/" "/opt/ts3bot/" "/opt/ts3soundboard/" "/home/sinusbot/" "/home/sinusbot/sinusbot/")

for BOT_PATH in "${BOT_PATHS[@]}"; do
	say "debug" "Searching in directory '$BOT_PATH'..."
		if [ -d "$BOT_PATH" ]; then
		check_bot_binary
		if [ $? -eq 0 ]; then
			say "info" "Binary found."
			break
		else
			BOT_PATH=""
		fi
	fi
done

if [ "$BOT_PATH" == "" ]; then
	say "error" "Bot binary not found! Execute this script in the sinusbot directory!"
	failed "bot binary not found"
fi

# if bot dir was found, check config file now
check_bot_config

BOT_FULL_PATH="$(echo "$BOT_PATH/$BOT_BINARY" | sed -e 's|//|/|g')"
BOT_BINARY_HASH=$(get_file_hash "$BOT_PATH/$BOT_BINARY")
BOT_BINARY_HASH_TEXT="(MD5 Hash: $BOT_BINARY_HASH)"

# collecting information
say "debug" "Collecting information..."
say "info" "(Scan may take some moments...)"

# system
say "info" "Collecting system information..."
say "debug" "Getting operating system version..."

# get OS details
SYS_OS=$(lsb_release --short --description)
SYS_OS_EXTENDED=""

if [ -f "/proc/user_beancounters" ]; then
	SYS_OS_EXTENDED="(OpenVZ)"

elif [ -f "/proc/1/cgroup" ] && [ ! -f "/.dockerenv" ]; then
	grep -Pq 'lxc' /proc/1/cgroup
	if [ $? -eq 0 ]; then
		SYS_OS_EXTENDED="(LXC)"
	fi

elif [ -f "/proc/1/cgroup" ] && [ -f "/.dockerenv" ]; then
	grep -Pq 'docker' /proc/1/cgroup
	if [ $? -eq 0 ]; then
		SYS_OS_EXTENDED="(Docker)"
	fi
fi

# get load avg
SYS_LOAD_AVG=$(cat /proc/loadavg | cut -d " " -f -3)

# get package manager last modified date
SYS_APT_LASTUPDATE=$(date --date="@$(stat -c %Y '/var/lib/apt/lists')" +"%d.%m.%Y %H:%M:%S %Z %::z")

# get current operating system date
SYS_TIME=$(date +"%d.%m.%Y %H:%M:%S %Z %::z")
SYS_TIME_ZONE=$(cat /etc/timezone)

# get uptime
SYS_UPTIME=$(</proc/uptime)
SYS_UPTIME=${SYS_UPTIME%%.*}
SYS_UP_SECONDS=$(($SYS_UPTIME % 60))
SYS_UP_MINUTES=$(($SYS_UPTIME / 60 % 60))
SYS_UP_HOURS=$(($SYS_UPTIME / 60 / 60 % 24))
SYS_UP_DAYS=$(($SYS_UPTIME / 60 / 60 / 24))
SYS_UPTIME_TEXT="$SYS_UP_DAYS days, $SYS_UP_HOURS hours, $SYS_UP_MINUTES minutes, $SYS_UP_SECONDS seconds"

# get kernel
SYS_OS_KERNEL=$(uname -srm)

# check if x64 bit os
SYS_OS_ARCH=$(getconf LONG_BIT)
if [ "$SYS_OS_ARCH" == "64" ]; then
	SYS_OS_ARCH_X64="Y"
	SYS_OS_ARCH_X64_TEXT="OK"
else
	SYS_OS_ARCH_X64="N"
	SYS_OS_ARCH_X64_TEXT="FAIL: Not x64 OS. [$SYS_OS_ARCH]"
fi

if [ "$SYS_OS_ARCH_X64" != "Y" ]; then
	say "error" "This system is not an 64-bit operating system! The bot requires an 64-bit operating system to operate, x86/x32 and other architectures are not supported. Please re-install your system with an 64-bit compatible operating system."
fi

# get package versions of important packages
PKG_VERSION_GLIBC="$(get_installed_version_package "libglib2.0-0")"
if [ "$PKG_VERSION_GLIBC" == "unknown" ]; then
	PKG_VERSION_GLIBC="unknown"
fi

# check dns resolution
say "debug" "Checking DNS resolution..."
RESOLVED_IP="$(resolve_hostname "$CHECK_DOMAIN_ACCESS")"
if [ "$RESOLVED_IP" != "" ]; then
	SYS_OS_DNS_CHECK="Y"
	SYS_OS_DNS_CHECK_TEXT="$CHECK_DOMAIN_ACCESS resolved to $RESOLVED_IP -> OK"
else
	SYS_OS_DNS_CHECK="N"
	SYS_OS_DNS_CHECK_TEXT="$CHECK_DOMAIN_ACCESS resolution failed -> ERROR"
fi

# messages for DNS check
if [ "$SYS_OS_DNS_CHECK" != "Y" ]; then
	say "error" "Strange. DNS resolution of domain '$CHECK_DOMAIN_ACCESS' failed. Please verify your DNS server settings of your system and fix this issue for the best bot experience."
fi

# check http access
# force using IPv4
say "debug" "Checking web IPv4 access..."

# set v4 URL
CHECK_WEB_URL_V4="$CHECK_WEB_URL"
CHECK_DOMAIN_ACCESS_V4="$(parse_host_of_url "$CHECK_WEB_URL_V4")"

# perform check
check_web_ipv4 "$CHECK_WEB_URL_V4"
if [ $? -eq 0 ]; then
	CHECK_WEB_IPV4="Y"
	CHECK_WEB_IPV4_TEXT="SUCCESS [Connection was established to $CHECK_DOMAIN_ACCESS_V4]"
else
	CHECK_WEB_IPV4="N"
	CHECK_WEB_IPV4_TEXT="FAILED  [Failed establishing connection to $CHECK_DOMAIN_ACCESS_V4]"
fi

# force using IPv6
say "debug" "Checking web IPv6 access..."

# set v6 URL
CHECK_WEB_URL_V6="$CHECK_WEB_URL"
CHECK_DOMAIN_ACCESS_V6="$(parse_host_of_url "$CHECK_WEB_URL_V6")"

# perform check
check_web_ipv6 "$CHECK_WEB_URL_V6"
if [ $? -eq 0 ]; then
	CHECK_WEB_IPV6="Y"
	CHECK_WEB_IPV6_TEXT="SUCCESS [Connection established to $CHECK_DOMAIN_ACCESS_V6]"
else
	CHECK_WEB_IPV6="N"
	CHECK_WEB_IPV6_TEXT="FAILED  [Failed connecting to $CHECK_DOMAIN_ACCESS_V6]"
fi

# messages of http access
if [ "$CHECK_WEB_IPV4" != "Y" ]; then
	say "error" "Contacting '$CHECK_DOMAIN_ACCESS_V4' using IPv4-only mode failed: Please check for IPv4 connectivity, for any DNS resolution issues or possible firewall restrictions."
fi

if [ "$CHECK_WEB_IPV6" != "Y" ]; then
	say "error" "Contacting '$CHECK_DOMAIN_ACCESS_V6' using IPv6-only mode failed: Please check for IPv6 connectivity, for any DNS resolution issues or possible firewall restrictions. Usually IPv6 is not supported from many internet service providers. As long as IPv4 is working, everything is fine."
fi

# get CPU info
say "debug" "Getting processor information..."
SYS_CPU_DATA=$(lscpu | egrep "^(Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket:|Socket\(s\)|Model name|CPU MHz|Hypervisor|Virtualization)")
SYS_CPU_DATA=$(echo "$SYS_CPU_DATA" | sed 's/^/    /')

# get os updatesinfo
if [ "$NO_OS_UPD_CHECK" == "yes" ]; then
	SYS_AVAIL_UPDS="unknown"
	SYS_AVAIL_UPDS_TEXT="(check skipped)"
else
	say "debug" "Checking for available operating system updates..."
	SYS_AVAIL_UPDS=$(check_available_updates)
	if [ "$SYS_AVAIL_UPDS" -gt 0 ]; then
		SYS_AVAIL_UPDS_TEXT="(updates available!)"
	else
		SYS_AVAIL_UPDS_TEXT="(well done!)"
	fi
fi

# get ram/memory info
say "debug" "Getting RAM information..."
MEMINFO="$(cat /proc/meminfo)"

if [ $? -ne 0 ]; then
	SYS_RAM_TOTAL="0"
	SYS_RAM_CACHED="0"
	SYS_RAM_FREE="0"
	SYS_RAM_USAGE="0"
	SYS_RAM_PERNT="0"
	SYS_RAM_EXTENDED="(error when reading file)"

	SYS_SWAP_TOTAL="0"
	SYS_SWAP_FREE="0"
	SYS_SWAP_USAGE="0"
	SYS_SWAP_PERNT="0"
	SYS_SWAP_EXTENDED="(error when reading file)"

	say "error" "Error when reading /proc/meminfo! [ignoring]"

else
	SYS_RAM_TOTAL=$(echo "$MEMINFO" | grep MemTotal | awk '{ print $2 }')
	SYS_RAM_CACHED=$(echo "$MEMINFO" | grep "^Cached" | awk '{ print $2 }')
	SYS_RAM_FREE=$(echo "$MEMINFO" | grep MemAvailable | awk '{ print $2 }')
	SYS_RAM_USAGE=$(($SYS_RAM_TOTAL - $SYS_RAM_FREE))
	if [ "$SYS_RAM_TOTAL" -eq 0 ]; then
		SYS_RAM_PERNT="0"
	else
		SYS_RAM_PERNT=$(($SYS_RAM_USAGE * 10000 / $SYS_RAM_TOTAL / 100))
	fi

	# get swap info
	say "debug" "Getting SWAP information..."
	SYS_SWAP_TOTAL=$(echo "$MEMINFO" | grep "SwapTotal" | awk '{ print $2 }')
	SYS_SWAP_FREE=$(echo "$MEMINFO" | grep "SwapFree" | awk '{ print $2 }')
	SYS_SWAP_USAGE=$(($SYS_SWAP_TOTAL - $SYS_SWAP_FREE))
	if [ "$SYS_SWAP_TOTAL" -eq 0 ]; then
		SYS_SWAP_PERNT="0"
		SYS_SWAP_EXTENDED="(SWAP disabled)"
	else
		SYS_SWAP_PERNT=$(($SYS_SWAP_USAGE * 10000 / $SYS_SWAP_TOTAL / 100))
	fi
fi

# get disk data
# check if the machine is a OpenVZ container
say "debug" "Getting DISK information..."
if [ -f "/proc/user_beancounters" ]; then
	# yes, so count it including simfs
	SYS_DISK_PARMS="-t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk -t simfs"
else
	# if not, then no simfs
	SYS_DISK_PARMS="-t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk"
fi

SYS_DISK_CMD="df -Tl --total $SYS_DISK_PARMS"
say "debug" "Getting disk info by using command:"
say "debug" " $ $SYS_DISK_CMD"
SYS_DISK_DATA=$($SYS_DISK_CMD)
if [ $? -eq 0 ]; then
	SYS_DISK_FIELD=$(echo "$SYS_DISK_DATA" | grep total | sed 's/ \+/ /g')
	SYS_DISK_TOTAL=$(echo "$SYS_DISK_FIELD" | cut -d " " -f5)
	SYS_DISK_USAGE=$(echo "$SYS_DISK_FIELD" | cut -d " " -f4)
	SYS_DISK_PERNT=$(($SYS_DISK_USAGE * 10000 / $SYS_DISK_TOTAL / 100))
else
	SYS_DISK_TOTAL="0"
	SYS_DISK_USAGE="0"
	SYS_DISK_PERNT="0"
	SYS_DISK_EXTENDED="(error when getting disk data)"

	say "error" "Error when reading >df< output! [ignoring]"
fi

# collecting bot info
say "info" "Collecting bot information..."
BOT_VERSION=$(get_bot_version)

BOT_CONFIG=""
if [ -z "$BOT_CONFIG" ]; then
	say "debug" "Loading bot config file..."
	if [ -f "$BOT_PATH/config.ini" ]; then
		BOT_CONFIG=$(cat "$BOT_PATH/config.ini")
	else
		BOT_CONFIG=""
	fi
fi

# get bot status
say "debug" "Determining bot status..."
BOT_STATUS="unknown"
BOT_STATUS_EXTENDED=""

BOT_STATUS_PIDS=$(pidof "$BOT_PATH/$BOT_BINARY")
if [ "$BOT_STATUS_PIDS" == "" ]; then
	BOT_STATUS="not running"
else
	BOT_STATUS_PID_FIRST="$(echo "$BOT_STATUS_PIDS" | awk '{ print $1 }')"
	BOT_STATUS_PID_USER_ID="$(get_userid_from_pid "$BOT_STATUS_PID_FIRST")"
	BOT_STATUS_PID_USER_NAME="$(get_user_name_by_uid "$BOT_STATUS_PID_USER_ID")"

	BOT_STATUS="running"
	BOT_STATUS_EXTENDED="(PIDs: $BOT_STATUS_PIDS, User: $BOT_STATUS_PID_USER_NAME)"
fi

# check webinterface
say "debug" "Reading ListenPort from bot configuration..."
BOT_WEB_STATUS="unknown"
BOT_CONFIG_WEB_PORT=$(parse_bot_config "ListenPort")
if [ "$BOT_CONFIG_WEB_PORT" == "" ]; then
	BOT_WEB_STATUS_EXTENDED="(Port not set?)"
else
	# check if port is listening either on IPv4 or IPv6 localhost
	if port_in_use "127.0.0.1" "$BOT_CONFIG_WEB_PORT" || port_in_use "::1" "$BOT_CONFIG_WEB_PORT"; then
		BOT_WEB_STATUS="port locally reachable"
	else
		BOT_WEB_STATUS="port locally not reachable"
	fi
	BOT_WEB_STATUS_EXTENDED="(Port: $BOT_CONFIG_WEB_PORT)"
fi

# check autostart script for bot
SYS_BOT_AUTOSTART="unknown"
SYS_BOT_AUTOSTART_EXTENDED=""

SYS_BOT_AUTOSTART_PATHS="/etc/init.d/sinusbot /etc/init.d/ts3bot /etc/systemd/system/sinusbot.service"
for SYS_BOT_AUTOSTART_PATH in $SYS_BOT_AUTOSTART_PATHS; do
	if [ -f "$SYS_BOT_AUTOSTART_PATH" ]; then
		SYS_BOT_AUTOSTART="found at $SYS_BOT_AUTOSTART_PATH"
		SYS_BOT_AUTOSTART_PERMS="$(stat -c %a "$SYS_BOT_AUTOSTART_PATH")"
		if [ "$SYS_BOT_AUTOSTART_PERMS" -ne 755 ]; then
			say "warning" "Please set the permissions of your autostart script at '$SYS_BOT_AUTOSTART_PATH' from $SYS_BOT_AUTOSTART_PERMS to 755, using: chmod 755 $SYS_BOT_AUTOSTART_PATH"
		fi
		SYS_BOT_AUTOSTART_EXTENDED="[perms: $SYS_BOT_AUTOSTART_PERMS]"
		break
	else
		SYS_BOT_AUTOSTART="not found"
	fi
done

# get installed scripts
say "debug" "Getting installed bot scripts..."
BOT_INSTALLED_SCRIPTS=$(get_installed_bot_scripts)

# getting log level
say "debug" "Reading LogLevel from bot configuration..."
BOT_CONFIG_LOGLEVEL=$(parse_bot_config "LogLevel")
BOT_CONFIG_LOGLEVEL_EXTENDED=""
if [ "$BOT_CONFIG_LOGLEVEL" == "10" ]; then
	BOT_CONFIG_LOGLEVEL_EXTENDED="(debug log active)"
fi

# getting ts3path
say "debug" "Reading TS3Path from bot configuration..."
BOT_CONFIG_TS3PATH=$(parse_bot_config "TS3Path")
BOT_CONFIG_TS3PATH_EXTENDED=""

# get ts3 plugin information
BOT_TS3_PLUGIN="unknown"
BOT_TS3_PLUGIN_EXTENDED="(TS3client not found)"
BOT_TS3_PLUGIN_HASH_TS3CLIENT="unknown"
BOT_TS3_PLUGIN_HASH_BOTPLUGIN="unknown"

# ts3 client info
BOT_CONFIG_TS3PATH_VERSION="unknown"
BOT_CONFIG_TS3PATH_VERSION_EXTENDED=""

if [ -f "$BOT_CONFIG_TS3PATH" ]; then
	BOT_CONFIG_TS3PATH_DIRECTORY=$(dirname "$BOT_CONFIG_TS3PATH")
	# trying to get ts3client version
	say "debug" "Trying to get ts3client version..."
	if [ -f "$BOT_CONFIG_TS3PATH_DIRECTORY/CHANGELOG" ]; then
		BOT_CONFIG_TS3PATH_VERSION=$(get_ts3_client_version "$BOT_CONFIG_TS3PATH_DIRECTORY/CHANGELOG")
		BOT_CONFIG_TS3PATH_EXTENDED="(Version $BOT_CONFIG_TS3PATH_VERSION)"

		# check ts3 client version
		if [ "$BOT_CONFIG_TS3PATH_VERSION" != "" ]; then
			# check for the old vulnerable client version 3.0.18.2 and before
			if compare_version $BOT_CONFIG_TS3PATH_VERSION 3.0.18.2 || [ $BOT_CONFIG_TS3PATH_VERSION == "3.0.18.2" ]; then
				BOT_CONFIG_TS3PATH_VERSION_EXTENDED="(vulnerable! outdated!)"
				say
				say "warning" "******************************* ATTENTION *******************************"
				say "warning" "[b]IMPORTANT! YOUR SYSTEM IS VULNERABLE DUE TO AN OUTDATED TS3CLIENT![/b]"
				say "warning" "You  are  still  using  an  outdated TS3Client version 3.0.18.2 or older,"
				say "warning" "which  has  very serious security vulnerabilities!  This security defects"
				say "warning" "allows   Remote Code Executions  and  Remote Code Inclusions!   With this"
				say "warning" "vulnerabilities it is possible to infect your system or even to take over"
				say "warning" "control  of  your  machine. This  may  lead to very dangerous situations."
				say "warning" ""
				say "warning" "        [b]Strongly recommended: Update as soon as possible![/b]         "
				say "warning" ""
				say "warning" "Download the latest TeamSpeak 3 Linux amd64 client from here:"
				say "warning" " => https://www.teamspeak.com/downloads"
				say "warning" "******************************* ATTENTION *******************************"
				say
				say "info"    "READ THE MESSAGE ABOVE! This message should warn you, do not ignore it."
				say "info"    "It is really important. Seriously. (Script will continue in five seconds...)"
				sleep 5
				pause

			# now check if running TS3Client and newer with Sinusbot 0.9.16 and older
			elif ( compare_version 3.1 $BOT_CONFIG_TS3PATH_VERSION || [ "$BOT_CONFIG_TS3PATH_VERSION" == "3.1" ] ) && ( compare_version $BOT_VERSION 0.9.18 || [ "$BOT_VERSION" == "0.9.18" ] ); then
				BOT_CONFIG_TS3PATH_VERSION_EXTENDED="(not supported!)"
				say
				say "warning" "***************************** NOT SUPPORTED *****************************"
				say "warning" "[b]THIS TS3 CLIENT VERSION IS NOT SUPPORTED AND NOT WORKING![/b]"
				say "warning" "TeamSpeak 3 Client with version 3.1+ and later is currently not supported"
				say "warning" "with Sinusbot version 0.9.16 and older."
				say "warning" "You may solve this issue by:"
				say "warning" "  1. Downgrade your TS3 client to a supported TS3 client version."
				say "warning" "  2. Upgrade to a supported Sinusbot version which supports this client."
				say "warning" "      (as long as an newer version is available)"
				say "warning" "***************************** NOT SUPPORTED *****************************"
				say
				sleep 5
				pause
			fi

			# check for compatibility of client 3.0.19 and newer on Debian 7 and older
			if [ "$BOT_CONFIG_TS3PATH_VERSION" == "3.0.19" ] || compare_version 3.0.19 $BOT_CONFIG_TS3PATH_VERSION; then
				if [ "$SYS_OS_LSBRELEASE_ID" == "debian" ] && (( $(echo "$SYS_OS_LSBRELEASE_RELEASE_MAJOR <= 7" | bc -l) )); then
					say "warning" "The TeamSpeak 3 client 3.0.19 and newer is not compatible with Debian 7 and older. Please switch back to an older TeamSpeak 3 version (for example 3.0.18.2) [[b]NOT[/b] recommended!] or upgrade to a newer operating system which has newer dependencies."
					sleep 3
				fi
			fi

		fi

	else
		BOT_CONFIG_TS3PATH_EXTENDED="(CHANGELOG file not found!)"
	fi

	# checking bot plugin in ts3client
	say "debug" "Checking installation of bot plugin in ts3client..."
	if [ -f "$BOT_CONFIG_TS3PATH_DIRECTORY/plugins/libsoundbot_plugin.so" ]; then
		BOT_TS3_PLUGIN="installed"
		BOT_TS3_PLUGIN_HASH_TS3CLIENT="$(get_file_hash "$BOT_CONFIG_TS3PATH_DIRECTORY/plugins/libsoundbot_plugin.so")"

		if [ -f "$BOT_PATH/plugin/libsoundbot_plugin.so" ]; then
			BOT_TS3_PLUGIN_HASH_BOTPLUGIN="$(get_file_hash "$BOT_PATH/plugin/libsoundbot_plugin.so")"
			if [ "$BOT_TS3_PLUGIN_HASH_BOTPLUGIN" == "$BOT_TS3_PLUGIN_HASH_TS3CLIENT"  ]; then
				BOT_TS3_PLUGIN_EXTENDED="(md5 hash match)"
			else
				BOT_TS3_PLUGIN_EXTENDED="(md5 hash mismatch!)"
			fi
		else
			BOT_TS3_PLUGIN_EXTENDED="(plugin in bot directory not found)"
		fi
	else
		BOT_TS3_PLUGIN="not installed"
		BOT_TS3_PLUGIN_EXTENDED=""
	fi

else
	BOT_CONFIG_TS3PATH_EXTENDED="(TS3client-binary does not exist!)"
fi

# checking for youtube-dl
say "debug" "Checking for 'youtube-dl'..."
BOT_CONFIG_YTDLPATH=$(parse_bot_config "YoutubeDLPath")
YTDL_VERSION="unknown"
if [ "$BOT_CONFIG_YTDLPATH" == "" ]; then
	BOT_CONFIG_YTDLPATH="not set"
	BOT_CONFIG_YTDLPATH_EXTENDED=""

	# check anyway, maybe the binary is installed anyway but just not set
	if [ -f "$(which youtube-dl)" ]; then
		YTDL_VERSION=$($(which youtube-dl) --version)
		BOT_CONFIG_YTDLPATH_EXTENDED="(does exist anyway, version: $YTDL_VERSION)"
	fi

else
	if [ -f "$BOT_CONFIG_YTDLPATH" ]; then
		YTDL_VERSION=$($BOT_CONFIG_YTDLPATH --version)
		BOT_CONFIG_YTDLPATH_EXTENDED="(does exist, version: $YTDL_VERSION)"
	else
		BOT_CONFIG_YTDLPATH_EXTENDED="(does not exist!)"
	fi
fi

# generate output
say "debug" "Generating output..."

OUTPUT=$(cat << EOF
==========================================================
SINUSBOT RELATED
SYSTEM INFORMATION
 - Operating System: $SYS_OS $SYS_OS_EXTENDED
 - OS x64 check: $SYS_OS_ARCH_X64_TEXT
 - Kernel: $SYS_OS_KERNEL
 - Load Average: $SYS_LOAD_AVG
 - Uptime: $SYS_UPTIME_TEXT
 - OS Updates: $SYS_AVAIL_UPDS $SYS_AVAIL_UPDS_TEXT
 - OS Missing Packages: $SYS_PACKAGES_MISSING
 - OS APT Last Update: $SYS_APT_LASTUPDATE
 - Bot Start Script: $SYS_BOT_AUTOSTART $SYS_BOT_AUTOSTART_EXTENDED
 - DNS resolution check: $SYS_OS_DNS_CHECK_TEXT
 - HTTPS check with IPv4 mode: $CHECK_WEB_IPV4_TEXT
 - HTTPS check with IPv6 mode: $CHECK_WEB_IPV6_TEXT
 - CPU:
$SYS_CPU_DATA
 - RAM: $(bytes_format $SYS_RAM_USAGE)/$(bytes_format $SYS_RAM_TOTAL) in use (${SYS_RAM_PERNT}%) $SYS_RAM_EXTENDED
 - SWAP: $(bytes_format $SYS_SWAP_USAGE)/$(bytes_format $SYS_SWAP_TOTAL) in use (${SYS_SWAP_PERNT}%) $SYS_SWAP_EXTENDED
 - DISK: $(bytes_format $SYS_DISK_USAGE)/$(bytes_format $SYS_DISK_TOTAL) in use (${SYS_DISK_PERNT}%) $SYS_DISK_EXTENDED
 - Package versions:
   > libglib: $PKG_VERSION_GLIBC

BOT INFORMATION
 - Status: $BOT_STATUS $BOT_STATUS_EXTENDED
 - Webinterface: $BOT_WEB_STATUS $BOT_WEB_STATUS_EXTENDED
 - Binary: $BOT_FULL_PATH $BOT_BINARY_HASH_TEXT
 - Version: $BOT_VERSION
 - TS3 Plugin: $BOT_TS3_PLUGIN $BOT_TS3_PLUGIN_EXTENDED
   - Bot Plugin: $BOT_TS3_PLUGIN_HASH_BOTPLUGIN
   - TS3 Client: $BOT_TS3_PLUGIN_HASH_TS3CLIENT
 - Config:
   - LogLevel = $BOT_CONFIG_LOGLEVEL $BOT_CONFIG_LOGLEVEL_EXTENDED
   - TS3Path = $BOT_CONFIG_TS3PATH $BOT_CONFIG_TS3PATH_EXTENDED
   - YoutubeDLPath = $BOT_CONFIG_YTDLPATH $BOT_CONFIG_YTDLPATH_EXTENDED
 - Installed scripts: $BOT_INSTALLED_SCRIPTS

OTHER INFORMATION
 - Report date: $SYS_TIME (timezone: $SYS_TIME_ZONE)
 - TeamSpeak 3 Version: $BOT_CONFIG_TS3PATH_VERSION $BOT_CONFIG_TS3PATH_VERSION_EXTENDED
 - youtube-dl Version: $YTDL_VERSION
 - DiagScript version: $SCRIPT_VERSION_NUMBER
==========================================================
EOF
)

# new lines and the finished output
say
say

say "" "[b]Please attach this output to your forum post:[/b]"
say
say "" "[CODE]"
say "" "$OUTPUT"
say "" "[/CODE]"
say
say "" "[b]Notice[/b]: For a better overview, post this data
in the forum within a CODE-tag!"

say
say

say "debug" "Done."

# we are done.
script_done
