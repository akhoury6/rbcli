# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate::Cli
  include Rbcli::Configurable

  @defaults = {
    appinfo: {
      appname: EXECUTABLE,
      version: nil,
      author: nil,
      email: nil,
      copyright_year: nil,
      compatibility: nil,
      license: nil,
      helptext: nil
    }
  }

  @defaults.keys.each do |namespace|
    @defaults[namespace].each do |key, default|
      Rbcli::Warehouse.set(key, default, namespace)
      self.define_singleton_method(key) do |value|
        Rbcli::Warehouse.set(key, value, namespace)
      end
    end
  end

  def self.opt * args
    Rbcli::Parser.add_opt *args
  end
end