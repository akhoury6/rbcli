#!/usr/bin/env bash
#
###
# This is the RBCli script for the command `<%= @vars[:name] %>`
###
#
# You can access RBCli's variables via the `rbcli` command, which is imported by this line:
if [[ RBCLI_ENV -eq "development" ]]; then
	__RBCLI_LIBSH_PATH="${RBCLI_DEVPATH}/../../lib-sh/lib-rbcli.sh"
else
	__RBCLI_LIBSH_PATH=$(echo $(cd "$(dirname $(gem which rbcli))/../lib-sh" && pwd)/lib-rbcli.sh)
fi
source "${__RBCLI_LIBSH_PATH}"
#
# The `rbcli` function is actually a wrapper around `jq` (https://stedolan.github.io/jq/). It can automatically
# jq on users' machines if running Linux or OSX, and users have sudo access. If not, users will be prompted to install
# it. RBCli passes in the variable data by populating evironment variables with JSON, and requires JQ to parse them.
#
# You can view the entire JSON structures with:
#
#    rbcli params
#    rbcli args
#    rbcli global_opts
#    rbcli config
#    rbcli myvars
#
# And to access specific data within that json, you can add some jq syntax as shown below. The first two examples show
# how to get data from a nested hash, and the last example shows how to select an item from an array.
#
#     echo "Log Level:  $(rbcli config .logger.log_level)"
#     echo "Log Target: $(rbcli config .logger.log_target)"
#     echo "First Argument (if passed): $(rbcli args .[0])"
#
# If you wish to parse the variables manually and remove the dependency on JQ, you can comment out the line above
# and access these variables directly:
#
#    __RBCLI_PARAMS
#    __RBCLI_ARGS
#    __RBCLI_GLOBAL
#    __RBCLI_CONFIG
#    __RBCLI_MYVARS
#
###
#

echo "------Params------"
rbcli params
echo "------Args------"
rbcli args
echo "------Global Opts------"
rbcli global_opts
echo "------Config------"
rbcli config
echo "------MyVars------"
rbcli myvars
echo ""
echo "Usage Examples:"
echo "Log Level:  $(rbcli config .logger.log_level)"
echo "Log Target: $(rbcli config .logger.log_target)"
echo "First Argument (if passed): $(rbcli args .[0])"
