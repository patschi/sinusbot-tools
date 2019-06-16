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
#  SinusBot forum: https://forum.sinusbot.com
#  SinusBot forum thread [english]: https://forum.sinusbot.com/threads/diagsinusbot-sh-sinusbot-diagnostic-script.831/#post-4418
#  SinusBot forum thread [german]: https://forum.sinusbot.com/threads/diagsinusbot-sh-sinusbot-diagnostik-script.832/#post-4419
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
#### MAGIC HAPPENS BELOW.
#### DO NOT TOUCH ANYTHING BELOW, IF YOU
#### DO NOT KNOW WHAT YOU ARE DOING!
##################################################

### SCRIPT CONFIGURATION VARIABLES
# setting important variables
# NOTICE: Unfortunately this does not when the script file is being piped to bash.
#SCRIPT_FILE_DETAILS="$(awk 'match($0, /v([0-9.]*)\:((\s)*)\[(.*)\]/) { print substr($0, RSTART, RLENGTH) };' "$(basename "$0")" | awk 'END{ print }')"
#SCRIPT_VERSION_NUMBER="$(echo $SCRIPT_FILE_DETAILS | awk -F":" '{ print $1 }')"
#SCRIPT_VERSION_DATE="$(echo $SCRIPT_FILE_DETAILS | awk -F"[" '{ print substr($2, 1, length($2)-1) }')"

# general settings
# SCRIPT
SCRIPT_AUTHOR_NAME="Patrik Kernstock aka. Patschi"
SCRIPT_AUTHOR_WEBSITE="patrik.kernstock.net"
SCRIPT_YEAR="2015-2019"

SCRIPT_NAME="diagSinusbot"
# get version number and date automatically from changelog
SCRIPT_VERSION_NUMBER="0.8.0"
SCRIPT_VERSION_DATE="2019-06-16 00:01 UTC"

VERSION_CHANNEL="master"
SCRIPT_PROJECT_SITE="https://github.com/patschi/sinusbot-tools/tree/$VERSION_CHANNEL"
SCRIPT_PROJECT_DLURL="https://raw.githubusercontent.com/patschi/sinusbot-tools/$VERSION_CHANNEL/tools/diagSinusbot.sh"

SCRIPT_VERSION_FILE="https://raw.githubusercontent.com/patschi/sinusbot-tools/$VERSION_CHANNEL/tools/updates/diagSinusbot/version.txt"
SCRIPT_CHANGELOG_LIST="https://github.com/patschi/sinusbot-tools/tree/master/tools/updates/diagSinusbot"
SCRIPT_CHANGELOG_FILE="https://raw.githubusercontent.com/patschi/sinusbot-tools/$VERSION_CHANNEL/tools/updates/diagSinusbot/changelog-{VER}.txt"

# script COMMANDS dependencies
SCRIPT_REQ_CMDS="apt-get pwd awk wc free grep echo cat date df stat getconf netstat sort head curl date ldd"
# script PACKAGES dependencies
SCRIPT_REQ_PKGS="bc binutils coreutils lsb-release util-linux net-tools curl"

# which domain to check for accessibility
CHECK_WEB_URL="https://www.sinusbot.com/diag"
CHECK_DOMAIN_ACCESS="auto"

# check reachability for update servers
CHECK_UPDATE_SERVERS="https://update01.sinusbot.com/diag https://update02.sinusbot.com/diag https://update03.sinusbot.com/diag"

# BOT
# bot PACKAGES dependencies
BOT_REQ_PACKAGES="x11vnc xvfb libxcursor1 ca-certificates bzip2 libnss3 libegl1-mesa x11-xkb-utils libasound2"

## SCRIPT SETTINGS
# IPv6 HTTPS check, 0 = off, 1 = on
CHECK_CURL_IPV6=0
# NTP server address
NTP_SERVER_ADDR="time.google.com"
# Do not force anything. Let it unchanged! (Trust me I'm an engineer.)
MODE_FORCE=0

## EXECUTION VARIABLES
EXEC_CURL="curl -q --user-agent "$SCRIPT_NAME/v$SCRIPT_VERSION_NUMBER""

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
	echo "$1" | awk 'match($0, /# Version: (.*)/) { print $3 };'
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
	say "welcome" "================================================"
	say "welcome" "= [b]HELLO![/b]  Having an issue? I'm here to assist! ="
	say "welcome" "=                                              ="
	say "welcome" "=  Thanks for  using  this diagnostic script!  ="
	say "welcome" "=  The more  information  you   provide,  the  ="
	say "welcome" "=  better we  can help to solve your problem.  ="
	say "welcome" "=                                              ="
	say "welcome" "=  The execution  may  take  some  moments to  ="
	say "welcome" "=  collection the most  important information  ="
	say "welcome" "=  of your system and  your bot installation.  ="
	say "welcome" "=                                              ="
	say "welcome" "=  After everything  is  done, you will get a  ="
	say "welcome" "=  summarized output ready to copy & paste it  ="
	say "welcome" "=  within a CODE-tag  in  the SinusBot forum.  ="
	say "welcome" "=  [Link: https://forum.sinusbot.com]          ="
	say "welcome" "=                                              ="
	say "welcome" "=  This script uses DNS resolutions and HTTPS  ="
	say "welcome" "=  requests  to  Sinusbot-related  domains to  ="
	say "welcome" "=  check  if your network settings are valid.  ="
	say "welcome" "================================================"
	say "welcome" "= Please also report any feedback or issues    ="
	say "welcome" "= related to the script in the official forum. ="
	say "welcome" "= Thank you and happy debugging!               ="
	say "welcome" "=   -- $SCRIPT_AUTHOR_NAME.          ="
	say "welcome" "================================================"
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
	say "info" "  -m|--skip-wait-messages    Skip waiting time after important messages"
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
	say "info" "   [b]flyth[/b]            Michael F.     for developing SinusBot, testing this script and ideas"
	say "info" "   [b]Xuxe[/b]             Julian H.      for testing, ideas and contributing code"
	say "info" "   [b]GetMeOutOfHere[/b]   -              for testing and ideas"
	say "info" "   [b]JANNIX[/b]           Jan H.         for testing"
	say "info" "   [b]maxibanki[/b]        Max S.         for testing, finding bugs and contributing code"
	say "info" "   [b]irgendwer[/b]        Jonas          for testing and ideas"
	say "info" "   [b]Multivitamin[/b]     David          for testing and ideas"
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
		say "error" "This script is only designed to run on following operating systems: Debian, Ubuntu."
		say "error" "IMPORTANT: Running the script with parameter '--force-run|-f' will prevent aborting here. However it is /!\ STRONGLY NOT RECOMMENDED /!\ as it may result in various errors, incorrect output or unexpected errors!"
		if [ "$MODE_FORCE" -eq 0 ]; then
			failed "unsupported operating system"
		fi
	fi

	say "info" "Detected operating system: $SYS_OS_LSBRELEASE_DESCRIPTION"

	# check version of operating system: debian
	if [ "$SYS_OS_LSBRELEASE_ID" == "debian" ] && (( $(echo "$SYS_OS_LSBRELEASE_RELEASE_MAJOR <= 6" | bc -l) )); then
		# is less or equal 6 = too old.
		say "warning" "You are using a too old operating system! Debian Squeeze and before are not officially supported for SinusBot. Please upgrade to a more recent system."
		sleep 1
	fi

	# check version of operating system: ubuntu
	if [ "$SYS_OS_LSBRELEASE_ID" == "ubuntu" ] && (( $(echo "$SYS_OS_LSBRELEASE_RELEASE <= 12.04" | bc -l) )); then
		# is less or equal 12.04 = too old.
		say "warning" "You are using a too old operating system! Ubuntu 12.04 and before are not officially supported for SinusBot. Please upgrade to a more recent system."
		sleep 1
	fi
}

## Function to crawl given URL
load_webfile()
{
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	$EXEC_CURL --fail --insecure --connect-timeout 10 --silent "$1"
}

## Function to check outgoing connections
check_web()
{
	local URL=$1
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	$EXEC_CURL --head --write-out "%{http_code}" --fail --insecure --silent --connect-timeout 10 -o /dev/null "$URL"
}

## Function to check outgoing IPv4 connections
check_web_ipv4()
{
	local URL=$1
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	$EXEC_CURL --head --write-out "%{http_code}" --fail --insecure --ipv4 --silent --connect-timeout 10 -o /dev/null "$URL"
}

## Function to check outgoing IPv6 connections
check_web_ipv6()
{
	local URL=$1
	# timeout is 10 seconds, because maybe slower internet connections or slow DNS resolutions.
	$EXEC_CURL --head --write-out "%{http_code}" --fail --insecure --ipv6 --silent --connect-timeout 10 -o /dev/null "$URL"
}

## Function to parse host from a given URL
parse_host_of_url()
{
	echo "$1" | awk -F/ '{ print $3 }'
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

## Function to get version of SinusBot
get_bot_version()
{
	say "debug" "Trying to get SinusBot version using version parameter..." > /proc/${PPID}/fd/0
	local BOT_VERSION_CMD=$("$BOT_PATH/$BOT_BINARY" --version 2>/dev/null)
	echo "$BOT_VERSION_CMD" | grep -q -P '^flag provided but not defined' >/dev/null
	if [ $? -eq 0 ]; then
		say "debug" "Error getting SinusBot version. Falling back to other method." > /proc/${PPID}/fd/0
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
		say "warning" "Scripts folder not found! (are you using v0.9.9 or prior?)"
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
	getent hosts "$1" | head -n 1 | cut -d ' ' -f 1
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

## Get time by NTP
get_time_by_ntp()
{
	# get current external date by NTP (Credits: http://seriot.ch/ntp.php)
	local NTP_TIME="$(echo $((0x`printf c%47s|nc -uw1 $NTP_SERVER_ADDR 123|xxd -s40 -l4 -p`-64#23GDW0)) 2>&1)"
	if ! [[ $NTP_TIME =~ ^-?[0-9]+([.][0-9]+)?$ ]] || [ "$NTP_TIME" == "-2208988800" ]; then
		NTP_TIME=0
	fi
	echo $NTP_TIME
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

## Function to get current locale
get_locale_current()
{
	echo $LANG
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

		-m|--skip-wait-messages )
			SKIP_WAIT_MESSAGES="yes"
		;;

		-f|--force-run )
			MODE_FORCE=1
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

# check values.
if [ "$SCRIPT_VERSION_NUMBER" == "" ]; then
	say "error" "Important variable empty: SCRIPT_VERSION_NUMBER. Aborting."
	failed "Version number incorrectly set."
fi
if [ "$SCRIPT_VERSION_DATE" == "" ]; then
	say "error" "Important variable empty: SCRIPT_VERSION_DATE. Aborting."
	failed "Version date incorrectly set."
fi

# further checks.
is_user_root

# do not show welcome screen, when user dont want to
if [ "$NO_WELCOME" != "yes" ]; then
	show_welcome
fi

# running what...?
say "info" "Starting $SCRIPT_NAME v$SCRIPT_VERSION_NUMBER [$SCRIPT_VERSION_DATE]..."

# Check if we want to automatically set the domain access
if [ "$CHECK_DOMAIN_ACCESS" = "auto" ]; then
	CHECK_DOMAIN_ACCESS="$(parse_host_of_url "$CHECK_WEB_URL")"
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

# check if commands are available for the script
REQ_CMDS=0
for SMCMD in $SCRIPT_REQ_CMDS; do
	check_command "$SMCMD"
	if [ $? -ne 0 ]; then
		REQ_CMDS=1
	fi
done

# check if any commands are missing
if [ $REQ_CMDS -ne 0 ]; then
	say "error" "Missing commands... Install and try again please."
	failed "missing commands"
fi

# check for script update... maybe there are important changes, or something like that.
# of course skip check, if the user don't want to stay up 2 date.
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
					say "info" "Displaying CHANGELOG for diagSinusBot v$UPD_CHECK_VER:"
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

# checking if OS is supported
is_supported_os

# checking bot dependencies
PACKAGES_MISSING=""
if [ "$BOT_REQ_PACKAGES" != "" ]; then
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
fi

# checking dependencies for bot
if [ "$PACKAGES_MISSING" == "" ]; then
	SYS_PACKAGES_MISSING="None"
else
	SYS_PACKAGES_MISSING="Missing packages: $PACKAGES_MISSING"
fi

# bot binary searching
say "info" "Searching bot binary..."

# checking for bot binary file
BOT_PATH=""

# possible bot search paths
BOT_SEARCH_PATHS=("$(pwd)" "/opt/sinusbot/" "/opt/ts3bot/" "/opt/ts3soundboard/" "/home/sinusbot/" "/home/sinusbot/sinusbot/")
for BOT_PATH in "${BOT_SEARCH_PATHS[@]}"; do
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
	say "error" "Bot binary not found! Execute this script in the SinusBot directory!"
	failed "bot binary not found"
fi

# if bot dir was found, check config file now
check_bot_config

BOT_FULL_PATH="$(echo "$BOT_PATH/$BOT_BINARY" | sed -e 's|//|/|g')"
BOT_FULL_PATH_FILE="$BOT_PATH/$BOT_BINARY"

BOT_BINARY_HASH=$(get_file_hash "$BOT_FULL_PATH_FILE")
BOT_BINARY_FILE_INFO_PERMS=$(stat -c %a $BOT_FULL_PATH_FILE)
BOT_BINARY_FILE_INFO_USER=$(stat -c %U $BOT_FULL_PATH_FILE)
BOT_BINARY_PATH_EXTENDED="MD5 Hash: $BOT_BINARY_HASH, Perms: $BOT_BINARY_FILE_INFO_PERMS, User: $BOT_BINARY_FILE_INFO_USER"

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
	say "warning" "It seems your machine is a OpenVZ container. OpenVZ is known for failing on some checks in this diagnostic scripts. These are known limitations due to restrictions and the nature of the containering software."

elif [ -f "/proc/1/cgroup" ] && [ ! -f "/.dockerenv" ]; then
	grep -Pq 'lxc' /proc/1/cgroup
	if [ $? -eq 0 ]; then
		SYS_OS_EXTENDED="(LXC)"
		say "warning" "It seems your machine is a LXC container. LXC is known for failing on some checks in this diagnostic scripts. These are known limitations due to restrictions and the nature of the containering software."
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
	SYS_OS_DNS_CHECK_TEXT="SUCCESS [$CHECK_DOMAIN_ACCESS resolved to $RESOLVED_IP]"
else
	SYS_OS_DNS_CHECK="N"
	SYS_OS_DNS_CHECK_TEXT="FAILED [resolution of $CHECK_DOMAIN_ACCESS failed]"
fi

# messages for DNS check
if [ "$SYS_OS_DNS_CHECK" != "Y" ]; then
	say "error" "Strange. DNS resolution of domain '$CHECK_DOMAIN_ACCESS' failed. Please verify your DNS server settings of your system and fix this issue for the best bot experience."
fi

# check http access
# set URLs
CHECK_WEB_URL_V4="$CHECK_WEB_URL"
CHECK_WEB_URL_V6="$CHECK_WEB_URL"

# force using IPv4
say "debug" "Checking web IPv4 access..."

CHECK_DOMAIN_ACCESS_V4="$(parse_host_of_url "$CHECK_WEB_URL_V4")"

# perform availability checks
CHECK_WEB_IPV4_CODE=$(check_web_ipv4 "$CHECK_WEB_URL_V4")
if [ "$CHECK_WEB_IPV4_CODE" -eq "200" ]; then
	CHECK_WEB_IPV4="Y"
	CHECK_WEB_IPV4_TEXT="SUCCESS [Connection established to $CHECK_DOMAIN_ACCESS_V4, CODE #$CHECK_WEB_IPV4_CODE]"
else
	CHECK_WEB_IPV4="N"
	CHECK_WEB_IPV4_TEXT="FAILED [Failed connection to $CHECK_DOMAIN_ACCESS_V4, CODE #$CHECK_WEB_IPV4_CODE]"
fi

if [ $CHECK_CURL_IPV6 -eq 1 ]; then
	# force using IPv6
	say "debug" "Checking web IPv6 access..."

	# set v6 URL
	CHECK_WEB_URL_V6="$CHECK_WEB_URL_V6"
	CHECK_DOMAIN_ACCESS_V6="$(parse_host_of_url "$CHECK_WEB_URL_V6")"

	# perform check
	CHECK_WEB_IPV6_CODE=$(check_web_ipv6 "$CHECK_WEB_URL_V6")
	if [ "$CHECK_WEB_IPV6_CODE" -eq "200" ]; then
		CHECK_WEB_IPV6="Y"
		CHECK_WEB_IPV6_TEXT="SUCCESS [Connection established to $CHECK_DOMAIN_ACCESS_V6, CODE #$CHECK_WEB_IPV6_CODE]"
	else
		CHECK_WEB_IPV6="N"
		CHECK_WEB_IPV6_TEXT="FAILED  [Failed connecting to $CHECK_DOMAIN_ACCESS_V6, CODE #$CHECK_WEB_IPV6_CODE]"
	fi
else
	CHECK_WEB_IPV6_TEXT="IGNORED [Disabled]"
fi

# messages of http access
if [ "$CHECK_WEB_IPV4" != "Y" ]; then
	say "error" "Contacting '$CHECK_DOMAIN_ACCESS_V4' using IPv4-only mode failed: Please check for IPv4 connectivity, for any DNS resolution issues or possible firewall restrictions."
fi

if [ $CHECK_CURL_IPV6 -eq 1 ]; then
	if [ "$CHECK_WEB_IPV6" != "Y" ]; then
		say "error" "Contacting '$CHECK_DOMAIN_ACCESS_V6' using IPv6-only mode failed: Please check for IPv6 connectivity, for any DNS resolution issues or possible firewall restrictions. Usually IPv6 is not supported from many internet service providers. As long as IPv4 is working, everything is fine."
	fi
fi

# special error codes
if [ "$CHECK_WEB_IPV4_CODE" == "403" ] || [ "$CHECK_WEB_IPV6_CODE" == "403" ]; then
	say "warning" "Error Code 403: This possibly means that Cloudflare has classified the connection as suspicious and therefore blocked it. So this could be probably a false-positive."
fi

# check update servers
say "debug" "Checking update server availability..."

UPDSRV_CHECK_STATUS="OK"
UPDSRV_CHECK_TEXT=""
for UPDSRV_CHECK in $CHECK_UPDATE_SERVERS; do
	UPDSRV_CHECK_DOMAIN="$(parse_host_of_url "$UPDSRV_CHECK")"
	UPDSRV_CHECK_CODE=$(check_web "$UPDSRV_CHECK")
	UPDSRV_CHECK_DNS=$(resolve_hostname "$UPDSRV_CHECK_DOMAIN")
	if [ "$UPDSRV_CHECK_CODE" -eq "404" ]; then
		UPDSRV_CHECK_THIS="SUCCESS"
	else
		UPDSRV_CHECK_STATUS="NOK"
		UPDSRV_CHECK_THIS="FAILED"
	fi
	UPDSRV_CHECK_TEXT="$UPDSRV_CHECK_TEXT\n    $UPDSRV_CHECK_DOMAIN -> $UPDSRV_CHECK_DNS: $UPDSRV_CHECK_THIS [CODE #$UPDSRV_CHECK_CODE]"
done

if [ "$UPDSRV_CHECK_STATUS" == "NOK" ]; then
	say "warning" "At least one sinusbot update server did not correctly replied. This might be a temporary issue on the sinusbot-side or a local issue."
fi

# check locales
say "debug" "Checking for locales..."
LOCALE_LANG=$(get_locale_current)
if [ "$LOCALE_LANG" == "" ]; then
	LOCALE_LANG="(not set)"
fi

# get CPU info
say "debug" "Getting processor information..."
SYS_CPU_DATA=$(lscpu | egrep "^(Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket:|Socket\(s\)|Model name|CPU MHz|Hypervisor|Virtualization)")
if [ "$SYS_CPU_DATA" == "" ]; then
	SYS_CPU_DATA="(failed retrieving information)"
fi
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

if [ $? -ne 0 ] || [ "$MEMINFO" == "" ]; then
	SYS_RAM_TOTAL="0"
	SYS_RAM_CACHED="0"
	SYS_RAM_FREE="0"
	SYS_RAM_USAGE="0"
	SYS_RAM_PERNT="0"
	SYS_RAM_EXTENDED="(error when reading data)"

	SYS_SWAP_TOTAL="0"
	SYS_SWAP_FREE="0"
	SYS_SWAP_USAGE="0"
	SYS_SWAP_PERNT="0"
	SYS_SWAP_EXTENDED="(error when reading data)"

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
	SYS_DISK_TOTAL=$(echo "$SYS_DISK_FIELD" | cut -d " " -f3)
	SYS_DISK_USAGE=$(echo "$SYS_DISK_FIELD" | cut -d " " -f4)
	SYS_DISK_PERNT=$(($SYS_DISK_USAGE * 10000 / $SYS_DISK_TOTAL / 100))
else
	SYS_DISK_TOTAL="0"
	SYS_DISK_USAGE="0"
	SYS_DISK_PERNT="0"
	SYS_DISK_EXTENDED="(error when getting disk data)"

	say "error" "Error when reading df-command output! [ignoring]"
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
	BOT_STATUS_PID_USER_NAME="$(echo -n $(get_user_name_by_uid "$BOT_STATUS_PID_USER_ID"))"

	BOT_STATUS="running"
	BOT_STATUS_EXTENDED="(PIDs: $BOT_STATUS_PIDS, User: $BOT_STATUS_PID_USER_NAME)"
fi

# ldd output
say "debug" "Getting LDD output from bot binary..."
BOT_LDD=$(ldd "$BOT_PATH/$BOT_BINARY" | sed -e 's/^[ \t]*/    /')

# check webinterface
say "debug" "Reading ListenPort from bot configuration..."
BOT_WEB_STATUS="unknown"
BOT_CONFIG_WEB_PORT=$(parse_bot_config "ListenPort")
if [ "$BOT_CONFIG_WEB_PORT" == "" ]; then
	BOT_WEB_STATUS_EXTENDED="(Port not set?)"
else
	# check if port is listening either on IPv4 or IPv6 localhost
	if port_in_use "$BOT_CONFIG_WEB_PORT"; then
		BOT_WEB_STATUS="port locally reachable"
	else
		BOT_WEB_STATUS="port locally not reachable"
	fi
	BOT_WEB_STATUS_EXTENDED="(Port: $BOT_CONFIG_WEB_PORT)"
fi

# check autostart script for bot
SYS_BOT_AUTOSTART="unknown"
SYS_BOT_AUTOSTART_EXTENDED=""

SYS_BOT_AUTOSTART_PATHS="/etc/init.d/sinusbot /etc/init.d/ts3bot /etc/systemd/system/sinusbot.service /etc/systemd/system/ts3bot.service"
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
			# check for the old vulnerable client version: 3.2.4 and older
			TS3_SECURITY_MIN_VER=3.2.4
			if compare_version $BOT_CONFIG_TS3PATH_VERSION $TS3_SECURITY_MIN_VER || [ $BOT_CONFIG_TS3PATH_VERSION == "$TS3_SECURITY_MIN_VER" ]; then
				BOT_CONFIG_TS3PATH_VERSION_EXTENDED="(vulnerable! outdated!)"
				say
				say "warning" "******************************* ATTENTION *******************************"
				say "warning" "[b]IMPORTANT! YOUR SYSTEM IS VULNERABLE DUE TO AN OUTDATED TS3CLIENT![/b]"
				say "warning" "You  are  using  an  outdated  and  vulnerable TeamSpeak 3 Client version"
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

				# check if we wait after this message.
				if [ "$SKIP_WAIT_MESSAGES" != "yes" ]; then
					say "info"    "It is really important. Seriously. (Script will continue in 5 seconds...)"
					sleep 5
					pause
				fi

			# now check if running TS3Client and newer with SinusBot 0.9.16 and older
			elif ( compare_version 3.1 $BOT_CONFIG_TS3PATH_VERSION || [ "$BOT_CONFIG_TS3PATH_VERSION" == "3.1" ] ) && ( compare_version $BOT_VERSION 0.9.18 || [ "$BOT_VERSION" == "0.9.18" ] ); then
				BOT_CONFIG_TS3PATH_VERSION_EXTENDED="(not supported!)"
				say
				say "warning" "***************************** NOT SUPPORTED *****************************"
				say "warning" "[b]THIS TS3 CLIENT VERSION IS NOT SUPPORTED AND NOT WORKING![/b]"
				say "warning" "TeamSpeak 3 Client with version 3.1+ and later is currently not supported"
				say "warning" "with SinusBot version 0.9.16 and older."
				say "warning" "You may solve this issue by:"
				say "warning" "  1. Downgrade your TS3 client to a supported TS3 client version."
				say "warning" "  2. Upgrade to a supported SinusBot version which supports this client."
				say "warning" "      (as long as an newer version is available)"
				say "warning" "***************************** NOT SUPPORTED *****************************"
				say
				# check if we wait after this message.
				if [ "$SKIP_WAIT_MESSAGES" != "yes" ]; then
					sleep 7
					pause
				fi
			fi

			# check for compatibility of client 3.0.19 and newer on Debian 7 and older
			if [ "$BOT_CONFIG_TS3PATH_VERSION" == "3.0.19" ] || compare_version 3.0.19 $BOT_CONFIG_TS3PATH_VERSION; then
				if [ "$SYS_OS_LSBRELEASE_ID" == "debian" ] && (( $(echo "$SYS_OS_LSBRELEASE_RELEASE_MAJOR <= 7" | bc -l) )); then
					say "warning" "The TeamSpeak 3 client 3.0.19 and newer is not compatible with Debian 7 and older. Please switch back to an older TeamSpeak 3 version (for example 3.0.18.2) [[b]NOT[/b] recommended!] or upgrade to a newer operating system which has newer dependencies."
					if [ "$SKIP_WAIT_MESSAGES" != "yes" ]; then
						sleep 3
					fi
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

	# checking libqxcb-glx-integration.so file
	say "debug" "Checking if libqxcb-glx-integration.so file exists..."
	if [ -f "$BOT_CONFIG_TS3PATH_DIRECTORY/xcbglintegrations/libqxcb-glx-integration.so" ]; then
		BOT_TS3_LIBQXCB_GLX_INTEGRATION="yes"
	else
		BOT_TS3_LIBQXCB_GLX_INTEGRATION="no"
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

# get current operating system date
SYS_TIME_ZONE="$(cat /etc/timezone)"
SYS_TIME_TS_LOCAL=$(date +%s)
# get human-readable date
SYS_TIME_LOCAL=$(date --date @$SYS_TIME_TS_LOCAL +"%d.%m.%Y %H:%M:%S %Z %::z")

# get current external date by NTP
SYS_TIME_TS_REMOTE=$(get_time_by_ntp)

if [ "$SYS_TIME_TS_REMOTE" == "0" ]; then
	say "error" "Failed trieving remote time from NTP server $NTP_SERVER_ADDR! Is any firewall blocking the NTP request, or is the DNS resolution failing?"
	SYS_TIME_REMOTE="<Failed retrieving remote time!>"
	SYS_TIME_DIFF="n/a"

else
	# get human-readable date
	SYS_TIME_REMOTE=$(date --date @$SYS_TIME_TS_REMOTE +"%d.%m.%Y %H:%M:%S %Z %::z")

	SYS_TIME_DIFF_MAX=30
	SYS_TIME_DIFF=$(($SYS_TIME_TS_REMOTE - $SYS_TIME_TS_LOCAL))
	SYS_TIME_DIFF_EXTENDED=""

	# always move over negative difference integer to positive, as it doesn't really matter anyway yet
	if [ "$SYS_TIME_DIFF" -lt 0 ]; then
		((SYS_TIME_DIFF *= -1))
	fi

	# check difference
	if [ $SYS_TIME_DIFF -le 2 ]; then
		SYS_TIME_DIFF_EXTENDED="(Time diff less than 2 secs. Good.)"

	elif [ $SYS_TIME_DIFF -le 10 ]; then
		SYS_TIME_DIFF_EXTENDED="(Time diff less than 10 secs. Acceptable.)"

	elif [ $SYS_TIME_DIFF -le $SYS_TIME_DIFF_MAX ]; then
		say "warning" "Time difference of local and remote time is less than $SYS_TIME_DIFF_MAX seconds, but greater than 10 seconds! Please update your local time using NTP or so to prevent any server or SinusBot-specific issues! A correct server time is always strongly recommended!"
		SYS_TIME_DIFF_EXTENDED="(Time diff between 10 and $SYS_TIME_DIFF_MAX secs! Critical!)"

	elif [ $SYS_TIME_DIFF -ge $SYS_TIME_DIFF_MAX ]; then
		say "warning" "Time difference of local and remote time is greater than $SYS_TIME_DIFF_MAX seconds! Please update your local time using NTP or so to prevent any server or SinusBot-specific issues! A correct server time is always strongly recommended!"
		SYS_TIME_DIFF_EXTENDED="(Time diff greater than $SYS_TIME_DIFF_MAX secs!)"
	fi
fi

# generate output
say "debug" "Generating output..."

OUTPUT=$(cat << EOF
==========================================================
SINUSBOT RELATED
SYSTEM INFORMATION
 - Operating System: $SYS_OS $SYS_OS_EXTENDED
 - Kernel: $SYS_OS_KERNEL
 - Load Average: $SYS_LOAD_AVG
 - Uptime: $SYS_UPTIME_TEXT
 - OS x64 check: $SYS_OS_ARCH_X64_TEXT
 - OS Updates: $SYS_AVAIL_UPDS $SYS_AVAIL_UPDS_TEXT
 - OS Missing Packages: $SYS_PACKAGES_MISSING
 - OS APT Last Update: $SYS_APT_LASTUPDATE
 - Shell Locale: $LOCALE_LANG
 - Bot Start Script: $SYS_BOT_AUTOSTART $SYS_BOT_AUTOSTART_EXTENDED
 - CPU:
$SYS_CPU_DATA
 - RAM: $(bytes_format $SYS_RAM_USAGE)/$(bytes_format $SYS_RAM_TOTAL) in use (${SYS_RAM_PERNT}%) $SYS_RAM_EXTENDED
 - SWAP: $(bytes_format $SYS_SWAP_USAGE)/$(bytes_format $SYS_SWAP_TOTAL) in use (${SYS_SWAP_PERNT}%) $SYS_SWAP_EXTENDED
 - DISK: $(bytes_format $SYS_DISK_USAGE)/$(bytes_format $SYS_DISK_TOTAL) in use (${SYS_DISK_PERNT}%) $SYS_DISK_EXTENDED
 - Package versions:
   - libglib: $PKG_VERSION_GLIBC

BOT INFORMATION
 - Status: $BOT_STATUS $BOT_STATUS_EXTENDED
 - Webinterface: $BOT_WEB_STATUS $BOT_WEB_STATUS_EXTENDED
 - Binary: $BOT_FULL_PATH
 - Binary Info: $BOT_BINARY_PATH_EXTENDED
 - Version: $BOT_VERSION
 - TS3 Plugin: $BOT_TS3_PLUGIN $BOT_TS3_PLUGIN_EXTENDED
   - Bot Plugin: $BOT_TS3_PLUGIN_HASH_BOTPLUGIN
   - TS3 Client: $BOT_TS3_PLUGIN_HASH_TS3CLIENT
 - Config:
   - LogLevel = $BOT_CONFIG_LOGLEVEL $BOT_CONFIG_LOGLEVEL_EXTENDED
   - TS3Path = $BOT_CONFIG_TS3PATH $BOT_CONFIG_TS3PATH_EXTENDED
   - YoutubeDLPath = $BOT_CONFIG_YTDLPATH $BOT_CONFIG_YTDLPATH_EXTENDED
 - Installed scripts: $BOT_INSTALLED_SCRIPTS

BOT TECHNICAL INFORMATION
 - File exists:
   - TS3Client/libqxcb-glx-integration.so: $BOT_TS3_LIBQXCB_GLX_INTEGRATION
 - LDD output:
$BOT_LDD

REACHABILITY CHECKS
 - HTTPS check with IPv4 mode: $CHECK_WEB_IPV4_TEXT
 - HTTPS check with IPv6 mode: $CHECK_WEB_IPV6_TEXT
 - DNS resolution check: $SYS_OS_DNS_CHECK_TEXT
 - Update server checks: $UPDSRV_CHECK_TEXT

TIME INFORMATION
 - Time (local): $SYS_TIME_LOCAL
 - Time (remote): $SYS_TIME_REMOTE
 - Time (difference): $SYS_TIME_DIFF secs $SYS_TIME_DIFF_EXTENDED
 - Timezone: $SYS_TIME_ZONE

OTHER INFORMATION
 - TeamSpeak3 Version: $BOT_CONFIG_TS3PATH_VERSION $BOT_CONFIG_TS3PATH_VERSION_EXTENDED
 - youtube-dl Version: $YTDL_VERSION
 - DiagScript Version: $SCRIPT_VERSION_NUMBER
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
