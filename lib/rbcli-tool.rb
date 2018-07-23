###########
## RBCLI ##
###########
#
# This file loads the Rbcli CLI Tool components.
#
###########

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

module RBCliTool end

require 'rbcli-tool/util'
require 'rbcli-tool/mdless_fix'
require 'rbcli-tool/project'
require 'rbcli-tool/generators'