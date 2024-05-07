# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
class Rbcli::ConfigOfDeath < Rbcli::Config
  (Rbcli::Config.instance_methods - Class.instance_methods).each do |method|
    self.define_method(method) do |*args|
      raise Rbcli::ConfigurateError.new "Attempted to access config that was not configured."
    end
  end
end