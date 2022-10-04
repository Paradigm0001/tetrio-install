#!/bin/sh
if [ "$(id -u)" = "0" ]; then
	echo no
	exit 69
fi

# Declare vars
SCRIPTNAME="${0##*/}"

# Functions
help() {
	cat <<EOF
Usage: $SCRIPTNAME [OPTION] [DIR]

Options:
	-h		Print this help message.

	-s		Install .desktop file system wide

	-f		Provide gamefiles directory through prompt

EOF
	exit "$@"
}

error() {
	printf '\033[1;31m%s\033[0m\n' "$@" >&2
}
printDesktop() {
cat<<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Tetr.io
Comment=A modern online tetris clone with online mutiplayer, leaderboards and more.
Icon=${TETRIODIR}/tetrio-color.png
Exec=${TETRIODIR}/tetrio-desktop
Path=${TETRIODIR}
Actions=
Categories=BlocksGame;Game;StrategyGame;
EOF
}

# Parse Args
if [ -z "$@" ]; then
	error "You must supply the gamefiles directory"
	help 1
fi

for ARG; do
	case $ARG in
		-f)
			## Get gamefiles
			while true; do
				echo "Please enter the full path to the Tetr.io application directory (ex. /usr/local/bin/tetrio-desktop): "
				read TETRIODIR
				if [ -d "$TETRIODIR" -a -x "${TETRIODIR}/tetrio-desktop" ]; then
					break
				else
					error "\"${TETRIODIR}\" Is not a valid directory (non-readable, non-existant or doesnt contain the binary \"tetrio-desktop\")"
					TETRIODIR=
				fi
			done
		;;
		-s)
			SYS="y"
		;;
		-h)
			help 0
		;;
		*)
			if [ "$#" = "1" ]; then
				TETRIODIR="$(realpath $1)"
				break
			fi
			error "unknown option: $1"
			help 1
		;;
	esac
	shift
done

# Main
set -e
cd "$TETRIODIR"

# Check for icon image, if not already there then fetch offical source
if [ ! -e "tetrio-color.png" ]; then
	if [ -w "$TETRIODIR" ]; then
		wget https://txt.osk.sh/branding/tetrio-color.png >/dev/null 2>&1
	else
		wget https://txt.osk.sh/branding/tetrio-color.png -O /tmp/tetrio-color.png >/dev/null 2>&1
		sudo mv /tmp/tetrio-color.png .
	fi
fi

# Output .desktop file
if [ -z "$SYS" ]; then
	printDesktop > "${HOME}/.local/share/applications/tetrio.desktop"
else
	printDesktop | tee /usr/share/applications/tetrio.desktop
fi
printf "Successfully created a Tetr.io Desktop file.\nA logout may be required to refresh application lists\n"
