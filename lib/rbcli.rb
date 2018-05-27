lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

module Rbcli end # Empty module declaration required to declare submodules freely
require "rbcli/version"

require "rbcli/util"

# STATE TOOLS
require "rbcli/stateful_systems/configuratestorage"
require "rbcli/stateful_systems/localstorage/localstate"
# END STATE TOOLS

require "rbcli/configurate"

require "rbcli/engine/command"
require "rbcli/engine/parser"
