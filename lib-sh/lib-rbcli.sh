#!/usr/bin/env bash
##################################################################################
#     RBCli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2018 Andrew Khoury                                           #
#                                                                                #
#     This program is free software: you can redistribute it and/or modify       #
#     it under the terms of the GNU General Public License as published by       #
#     the Free Software Foundation, either version 3 of the License, or          #
#     (at your option) any later version.                                        #
#                                                                                #
#     This program is distributed in the hope that it will be useful,            #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#     GNU General Public License for more details.                               #
#                                                                                #
#     You should have received a copy of the GNU General Public License          #
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.     #
#                                                                                #
#     For questions regarding licensing, please contact andrew@blacknex.us        #
##################################################################################

## Log message
function message {
	if [ "$2" == "err" ]; then
		COLOR='\033[00;31m'
	else

		COLOR='\033[00;32m'
	fi

	if [ "$2" == "no_newline" ]; then
		printf "${COLOR}[RBCLI-Setup] ${1}\033[0m"
	else
		echo -e "${COLOR}[RBCLI-Setup] ${1}\033[0m"
	fi
}

## Detect OS
function detect_os {
	unameOut="$(uname -s)"
	case "${unameOut}" in
		Linux*)     machine=Linux;;
		Darwin*)    machine=Darwin;;
		CYGWIN*)    machine=Cygwin;;
		MINGW*)     machine=MinGw;;
		*)          machine="UNKNOWN:${unameOut}"
	esac
	echo ${machine}
}

## Install JQ
function install_jq {
	case "$(detect_os)}" in
		Linux)
			_tmpdir=$(mktemp -d)
			_pwd=$(pwd)
			cd $_tmpdir
			curl -sOL "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
			mv jq-linux64 /usr/bin/jq
			cd $_pwd
			rm -rf $_tmpdir
			;;
		Darwin*)
			message "Apple OSX Detected; homebrew must be installed to continue. Continue? (Y/n): " "no_newline"
			read -n1 _answer
			printf "\n"
			if [[ "${_answer}" =~ ^(y|Y)$ ]]; then
				brew install jq
			else
				message "Installation aborted."
				exit 0
			fi
			;;
		*)
			message "Sorry, your machine type ($(detect_os)) is not supported. This script can only install JQ automatically on either Linux or OSX."
			message "Please visit https://stedolan.github.io/jq/ to install JQ manually on your system."
			exit 0
	esac
}


# We need to make sure JQ is installed so that we can parse variables
which jq &> /dev/null
_RESULT=$?
if [[ "${_RESULT}" -ne 0 ]]; then
	message "Application JQ not found on local system."
	message "Installing JQ. Sudo access required, please input password if prompted."
	install_jq
fi


######
## RBCLI
######
# This function provides an interface to the variables exposed by RBCli
function rbcli {
	_vargroup=$1
	_var=$2

	case "${_vargroup}" in
		params)
			_groupname='__RBCLI_PARAMS'
		;;
		args)
			_groupname='__RBCLI_ARGS'
		;;
		global_opts)
			_groupname='__RBCLI_GLOBAL'
		;;
		config)
			_groupname='__RBCLI_CONFIG'
		;;
		myvars)
			_groupname='__RBCLI_MYVARS'
		;;
		*)
			message "Invalid RBCLI variable reference. Please reference variables from one of the following groups: params, args, global_opts, config, commandvars." "err"
			exit 1
	esac
	echo $(echo ${!_groupname} | jq -r "${2}")
}
export -f rbcli

