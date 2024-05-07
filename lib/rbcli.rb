# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
RBCLI_LIBDIR = File.join(File.expand_path(File.dirname(__FILE__)), 'rbcli')
RBCLI_TOOLDIR = File.join(File.expand_path(File.dirname(__FILE__)), 'rbcli-tool')
EXECUTABLE = File.basename($0).gsub(/\.[^.]+$/, '')

# Prerequisites for anything else to run
require_relative "rbcli/version"
require 'colorize'
Dir[File.join(RBCLI_LIBDIR, 'util', '*.rb')].each { |file| require file }

# Core framework
require File.join(RBCLI_LIBDIR, 'components', 'logger', 'logger.rb')
require File.join(RBCLI_LIBDIR, 'components', 'core', 'engine.rb')
require File.join(RBCLI_LIBDIR, 'components', 'core', 'warehouse.rb')
require File.join(RBCLI_LIBDIR, 'components', 'parser', 'parser.rb')
require File.join(RBCLI_LIBDIR, 'components', 'config', 'config.rb')
require File.join(RBCLI_LIBDIR, 'components', 'commands', 'command.rb')

# The Rbcli Interface
require File.join(RBCLI_LIBDIR, 'components', 'core', 'configurate')