lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

module Rbcli end # Empty module declaration required to declare submodules freely
require "rbcli/version"

require "rbcli/util"

# TOOLKIT
require "rbcli/localstorage/localstate"
# END TOOLKIT

require "rbcli/configurate"

require "rbcli/engine/command"
require "rbcli/engine/parser"
