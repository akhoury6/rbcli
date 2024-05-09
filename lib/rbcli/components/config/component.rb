# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate::Config
  include Rbcli::Configurable

  def self.file location: nil, type: nil, schema_location: nil, save_on_exit: false, create_if_not_exists: false, suppress_errors: false
    raise Rbcli::ConfigurateError.new "Config file location must either be a path or an array of paths" unless location.nil? || location.is_a?(String) || (location.is_a?(Array) && location.all? { |loc| loc.is_a?(String) })
    raise Rbcli::ConfigurateError.new "Config schema file location must be a path" unless schema_location.nil? || schema_location.is_a?(String)
    raise Rbcli::ConfigurateError.new "Config type must be one of the following: #{Rbcli::UserConf::Backend.types.keys.join(', ')}" unless (type.is_a?(String) || type.is_a?(Symbol)) && Rbcli::UserConf::Backend.types.key?(type.downcase.to_sym)
    config = Rbcli::Config.new location: location, type: type, schema_location: schema_location, create_if_not_exists: create_if_not_exists, suppress_errors: suppress_errors
    Rbcli::Warehouse.set(:config, config, :parsedopts)
    Rbcli::Engine.register_operation Proc.new { Rbcli::Warehouse.get(:config, :parsedopts).load!; Rbcli::Warehouse.get(:config, :parsedopts).validate! }, name: :load_config, priority: 40
    Rbcli::Engine.register_operation Proc.new { Rbcli::Warehouse.get(:config, :parsedopts).save! }, name: :save_config, priority: 160 if save_on_exit
  end

  def self.banner text
    raise Rbcli::ConfigurateError.new "The banner must be set to a string." unless text.is_a?(String)
    Rbcli::Warehouse.get(:config, :parsedopts).set_banner text
  end

  def self.defaults hash
    raise Rbcli::ConfigurateError.new "The default configuration must be a hash." unless hash.is_a?(Hash)
    Rbcli::Warehouse.get(:config, :parsedopts).defaults = hash
  end
end