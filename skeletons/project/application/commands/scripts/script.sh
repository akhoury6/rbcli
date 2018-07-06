#!/usr/bin/env bash

###
# This is the RBCli script for the command {{**CMDNAME**}}
###
#
# You can find RBCli's params, args, global_opts, and config through environment
# variables. They are passed in the formats:
#
#   __PARAMS_<param_name>
#   __ARGS_<arg_name>
#   __GOBAL <global_opt_name>
#   __CONFIG <config_name>
#
# If any of the options given had nested values in your RBCli application they
# will be passed as JSON. You can parse them using jq ( https://stedolan.github.io/jq/ )
#
# If you specified any environment variables to be set manually, they will be found unmodified.
#
###
#

env | grep "^__PARAMS\|^__ARGS\|^__GLOBAL\|^__CONFIG"
