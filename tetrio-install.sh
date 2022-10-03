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
        -h              Print this help message.

EOF
	exit "$1"
}

error() {
        printf '\033[1;31m%s\033[0m\n' "$@" >&2
}

# Prelim
if [ ! -x "./tetrio-desktop-file-gen.sh" ]; then
	error "Missing \"tetrio-desktop-file-gen.sh\" helper file in CWD"
fi

# Parse Args
if [ -z "$@" ]; then
	error "You must supply the install directory"
	help 1
fi

for ARG; do
	case $ARG in
	        -h)
	                help 0
	                exit
	        ;;
		*)
			if [ "$#" = "1" ]; then
				[ -d "$1" ] || error "\"${TETRIODIR}\" Is not a valid directory (non-readable or non-existant)"
				if [ -d "${1}/tetrio-desktop"* ]; then
					error "Tetrio gamefiles already exist at this location. Manually renove them to and try again."
					exit 1
				fi
				INSTALLDIR="$(realpath $1)"
				break
			fi
			error "unknown option: $1"
			help 1
	esac
	shift
done

# Main
set -e
OLDDIR="$PWD"
cd /tmp
rm -rf tetrio* "TETR.IO Setup.tar.gz"
wget https://tetr.io/about/desktop/builds/TETR.IO%20Setup.tar.gz >/dev/null 2>&1
tar -xf "TETR.IO Setup.tar.gz"
if [ -w "$INSTALLDIR" ]; then
	mv ./tetrio-desktop* "${INSTALLDIR}"
else
	sudo mv /tmp/tetrio-desktop* "${INSTALLDIR}"
fi
printf "Successfully downloaded and installed gamefiles to ${INSTALLDIR}\nInstalling .desktop file to ~/.local/share/applications...\n"
cd "$OLDDIR"
./tetrio-desktop-file-gen.sh "${INSTALLDIR}/tetrio-desktop"*
