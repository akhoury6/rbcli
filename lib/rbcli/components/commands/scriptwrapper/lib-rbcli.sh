#!/usr/bin/env bash
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
## Basic message
function message {
	if [ "$2" == "err" ]; then
		COLOR='\033[00;31m'
	else
		COLOR='\033[00;32m'
	fi

	if [ "$2" == "no_newline" ]; then
		printf "${COLOR}${1}\033[0m"
	else
		echo "${COLOR}${1}\033[0m"
	fi
}

## Log function integrates with Rbcli Logger
function log {
	prefix='INFO || '
	if [ ! -z ${2+x} ]; then
		_pfx="$(echo "${2}" | tr '[:lower:]' '[:upper:]')"
		if [[ "${_pfx}" =~ ^(DEBUG|INFO|WARN|ERROR|FATAL|UNKNOWN)$ ]]; then
			prefix="${_pfx} || "
		fi
	fi
	echo "${prefix}${1}"
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
		Linux*)
			_flavor=$(cat /etc/*release | grep "DISTRIB_ID" | cut -d'=' -f2)
			case "${_flavor}" in
				Ubuntu*)
					sudo apt-get install jq -y
					;;
				*)
					_tmpdir=$(mktemp -d)
					_pwd=$(pwd)
					cd $_tmpdir
					curl -sOL "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
					sudo mv jq-linux64 /usr/bin/jq
					sudo chmod +x /usr/bin/jq
					cd $_pwd
					rm -rf $_tmpdir
					;;
				esac
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
# This function provides an interface to the variables exposed by Rbcli
function rbcli {
	_vargroup=$1
	_var=$2

	case "${_vargroup}" in
		opts)
			_groupname='__RBCLI_OPTS'
		;;
		params)
			_groupname='__RBCLI_PARAMS'
		;;
		args)
			_groupname='__RBCLI_ARGS'
		;;
		config)
			_groupname='__RBCLI_CONFIG'
		;;
		env)
			_groupname='__RBCLI_ENV'
		;;
		vars)
			_groupname='__RBCLI_VARS'
		;;
		*)
			message "Invalid RBCLI variable reference. Please reference variables from one of the following groups: opts, params, args, config, env, vars." "err"
			exit 1
	esac
	echo "$(echo ${!_groupname} | jq -r "${_var}")"
}
export -f rbcli