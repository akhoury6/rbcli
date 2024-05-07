# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli
  VERSION = File.read(File.expand_path(File.join(File.dirname(__FILE__), '../../VERSION'))).chomp.strip
end