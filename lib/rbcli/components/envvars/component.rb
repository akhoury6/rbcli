# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate::Envvars
  include Rbcli::Configurable

  def self.prefix envvar_prefix
    raise Rbcli::ConfigurateError.new "Environment variable prefix must be a string" unless envvar_prefix.is_a?(String)
    env = Rbcli::Config.new location: envvar_prefix.sub(/_+$/, ''), type: :env
    Rbcli::Warehouse.set(:env, env, :parsedopts)
    Rbcli::Engine.register_operation Proc.new { Rbcli::Warehouse.get(:env, :parsedopts).load! }, name: :load_envvars, priority: 50
  end

  def self.envvar envvar, default
    raise Rbcli::ConfigurateError.new "Environment variables must be a string" unless envvar.is_a?(String)
    Rbcli::Warehouse.get(:env, :parsedopts).add_default(envvar, default)
  end
end