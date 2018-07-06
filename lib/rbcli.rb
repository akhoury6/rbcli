###########
## RBCLI ##
###########
#
# This file loads the Rbcli systems.
#
# Utils and Prereqs must be loaded first.
#
###########

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

module Rbcli end # Empty module declaration required to declare submodules freely
require 'rbcli/version'

# UTILS
require 'rbcli/util/hash_deep_symbolize'
#require 'rbcli/util/string_colorize' # We are using the colorize gem instead. The code is kept here for reference.
# END UTILS

# BASE PREREQS
require 'rbcli/configuration/config'
require 'rbcli/logging/logging'
# END BASE PREREQS


# STATE TOOLS
require 'rbcli/stateful_systems/configuratestorage'
require 'rbcli/stateful_systems/state_storage'
require 'rbcli/stateful_systems/storagetypes/localstate'
require 'rbcli/stateful_systems/storagetypes/remotestate_dynamodb'
# END STATE TOOLS

# AUTOUPDATE
require 'rbcli/autoupdate/autoupdate'
# END AUTOUPDATE

# SCRIPT WRAPPER
require 'rbcli/scriptwrapping/scriptwrapper'
# END SCRIPT WRAPPER

# CORE
require 'rbcli/configuration/configurate'
require 'rbcli/engine/load_project'
require 'rbcli/engine/command'
require 'rbcli/engine/parser'
# END CORE
