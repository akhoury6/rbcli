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
#     For questions regarding licensing, please contact andrew@blacknex.us       #
##################################################################################

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

# REMOTE EXEC
require 'rbcli/remote_exec/remote_exec'
# END REMOTE EXEC

# CORE
require 'rbcli/configuration/configurate'
require 'rbcli/engine/load_project'
require 'rbcli/engine/command'
require 'rbcli/engine/parser'
# END CORE
