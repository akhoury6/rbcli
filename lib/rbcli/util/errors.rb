# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli
  class Error < StandardError; end

  class ConfigurateError < Rbcli::Error; end

  class CommandError < Rbcli::Error; end
end