#!/bin/bash

#find out what we have (+e is important for this)
set +e
has_git="$(command -v git)"
has_curl="$(command -v curl)"
has_cargo="$(command -v ~/.cargo/bin/cargo)"
has_sudo="$(command -v sudo)"
# CHAOS-EDIT START: yt-dlp instead of the abandoned youtube-dl; unzip is required by the Bun installer that builds tgui
#has_youtubedl="$(command -v youtube-dl)"
has_ytdlp="$(command -v yt-dlp)"
has_pip3="$(command -v pip3)"
has_unzip="$(command -v unzip)"
# CHAOS-EDIT END
set -e
set -x

# apt packages, libssl needed by rust-g but not included in TGS barebones install
# CHAOS-EDIT START: also install pip3 and unzip, as tgstation does
#if ! ( [ -x "$has_git" ] && [ -x "$has_curl" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] ); then
if ! ( [ -x "$has_git" ] && [ -x "$has_curl" ] && [ -x "$has_pip3" ] && [ -x "$has_unzip" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] ); then
	echo "Installing apt dependencies..."
	if ! [ -x "$has_sudo" ]; then
		dpkg --add-architecture i386
		apt-get update
		#apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl
		apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl python3 python3-pip unzip
	else
		sudo dpkg --add-architecture i386
		sudo apt-get update
		#sudo apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl
		sudo apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl python3 python3-pip unzip
	fi
fi
# CHAOS-EDIT END

# install cargo if needed
if ! [ -x "$has_cargo" ]; then
	echo "Installing rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	. ~/.profile
fi

# CHAOS-EDIT START: yt-dlp, installed and updated with pip3 as tgstation does.
# pip 23+ (Ubuntu 23.04+) refuses to touch the system Python without --break-system-packages, and older pip does not know the flag.
## install or update youtube-dl when not present, or if it is present with pip3,
## which we assume was used to install it
#if ! [ -x "$has_youtubedl" ]; then
#	echo "Installing youtube-dl with pip3..."
#	if ! [ -x "$has_sudo" ]; then
#		apt-get update
#		apt-get install -y python3 python3-pip
#	else
#		sudo apt-get update
#		sudo apt-get install -y python3 python3-pip
#	fi
#	pip3 install youtube-dl
#elif [ -x "$has_pip3" ]; then
#	echo "Ensuring youtube-dl is up-to-date with pip3..."
#	pip3 install youtube-dl -U
#fi
pip_flags=""
if pip3 install --help | grep -q -- "--break-system-packages"; then
	pip_flags="--break-system-packages"
fi
if ! [ -x "$has_ytdlp" ]; then
	echo "Installing yt-dlp with pip3..."
	pip3 install yt-dlp $pip_flags
else
	echo "Ensuring yt-dlp is up-to-date with pip3..."
	pip3 install yt-dlp -U $pip_flags
fi
# CHAOS-EDIT END
