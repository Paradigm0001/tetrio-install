#!/bin/sh
# Declare vars
_SCRIPTNAME="${0##*/}"
_BLUE_COLORCODE='\033[0;34m'
_YELLOW_COLORCODE='\033[1;33m'
_ORANGE_COLORCODE='\033[0;33m'
_GREEN_COLORCODE='\033[0;32m'
_RESET_COLORCODE='\033[0m'

# Functions
_help() {
	_help_string="\
Usage: $_SCRIPTNAME [OPTIONS]

Options:
		-h, --help		Print this help message.

		-s, --system		Install system wide

		-l, --local		Install for current user ($USER)
"
	echo "$_help_string"
	exit "$1"
}

_error() {
        printf '\033[1;31m%s\033[0m\n' "$@" >&2
}

_printDesktop() {
	_desktopfile_string="\
[Desktop Entry]
Version=1.0
Type=Application
Name=Tetr.io
Comment=A modern online tetris clone with online mutiplayer, leaderboards and more.
Icon=${_INSTALLDIR}/tetrio-desktop/tetrio-color.png
Exec=${_INSTALLDIR}/tetrio-desktop/tetrio-desktop
Path=${_INSTALLDIR}/tetrio-desktop
Actions=
Categories=BlocksGame;Game;StrategyGame;\
"
	echo "$_desktopfile_string"
}

# Check for deps
if ! command -v wget >/dev/null 2>&1; then
	_error 'wget not found!'
	_error 'wget is required for downloading the games assets.'
	exit 1
fi

# Parse Args
if [ -z "$1" ] || [ "$#" -gt "1" ]; then
	_error "You must supply either -s or -l arguments"
	_help 1
fi
case "$1" in
	-h|--help)
		_help 0
	;;
	-s|--system)
		if [ ! "$(id -u)" = "0" ]; then
			_error "Installing system wide requires root permission."
			exit 1
		fi
		_INSTALLDIR="/usr/local/lib/"
		_DESKTOPFILEDIR="/usr/local/share/applications/"
		if [ -d "${_INSTALLDIR}/tetrio-desktop" ]; then
			_error "Tetrio gamefiles already exist at \"${_INSTALLDIR}/tetrio-desktop\". Manually renove them then try again."
			exit 1
		fi
		for i in "$_INSTALLDIR" "$_DESKTOPFILEDIR"; do
			if [ ! -d "${i}" ]; then
				_error "${i} dir does not exist, Exiting due to very bizarre behaviour..."
				exit 1
			fi
		done
		printf "Attempting ${_ORANGE_COLORCODE}system${_RESET_COLORCODE} install!\nINSTALLDIR: ${_YELLOW_COLORCODE}${_INSTALLDIR}${_RESET_COLORCODE}\nDESKTOPFILEDIR: ${_YELLOW_COLORCODE}${_DESKTOPFILEDIR}${_RESET_COLORCODE}\n\n"
	;;
	-l|--local)
		_INSTALLDIR="$HOME/.local/lib/"
		_DESKTOPFILEDIR="$HOME/.local/share/applications/"
		for i in "$_INSTALLDIR" "$_DESKTOPFILEDIR"; do
			# 0 exit code if exist or created
			if ! mkdir -p "${i}"; then
				_error "Failed to create dir \"${i}\""
				_error "Cannot proceed!"
				exit 1
			fi
		done
		printf "Attempting ${_BLUE_COLORCODE}local${_RESET_COLORCODE} install!\nINSTALLDIR: ${_YELLOW_COLORCODE}${_INSTALLDIR}${_RESET_COLORCODE}\nDESKTOPFILEDIR: ${_YELLOW_COLORCODE}${_DESKTOPFILEDIR}${_RESET_COLORCODE}\n\n"
	;;
	*)
		_error "Unknown option \"$1\""
		_help 1
	;;
esac

## Main
set -e

# Workdir
_WORKDIR="$(mktemp -d "/tmp/${_SCRIPTNAME}.XXXXX")"
trap 'rm -rf "$_WORKDIR"' HUP INT QUIT ABRT TERM EXIT

# Download and extract
echo "Downloading game assets:"
cd "$_WORKDIR"
wget -nv https://tetr.io/about/desktop/builds/TETR.IO%20Setup.tar.gz
tar -xf "TETR.IO Setup.tar.gz"
rm "TETR.IO Setup.tar.gz"

# Fetch icon art and move game files to installdir
cd ./tetrio-desktop*
wget -nv https://txt.osk.sh/branding/tetrio-color.png
cd ..
mv ./tetrio-desktop* "${_INSTALLDIR}/tetrio-desktop"

# Install .desktop file
_printDesktop > "${_DESKTOPFILEDIR}/TETRIO.desktop"
update-desktop-database "$_DESKTOPFILEDIR"

# Verbose success
_success_string="
${_GREEN_COLORCODE}Success!${_RESET_COLORCODE}

Successfully installed gamefiles to \"${_INSTALLDIR}tetrio-desktop\" and .desktop file to \"${_DESKTOPFILEDIR}TETRIO.desktop\"
A logout may be required to refresh application lists
"
printf "$_success_string"

# Exit
rm -rf "$_WORKDIR"
exit 0
