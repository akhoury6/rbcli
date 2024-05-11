# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate::Config
  include Rbcli::Configurable

  @params = {}
  @on_declare = Proc.new do
    Rbcli::Engine.register_operation Proc.new {
      config = Rbcli::Config.new(**@params)
      Rbcli::Warehouse.set(:config, config, :parsedopts)
      Rbcli::Warehouse.get(:config, :parsedopts).load!; Rbcli::Warehouse.get(:config, :parsedopts).validate!
    }, name: :load_config, priority: 40
  end

  def self.file location
    raise Rbcli::ConfigurateError.new "Config file location must either be a path or an array of paths" unless location.nil? || location.is_a?(String) || (location.is_a?(Array) && location.all? { |loc| loc.is_a?(String) })
    @params[:location] = location
  end

  def self.type type
    raise Rbcli::ConfigurateError.new "Config type must be one of the following: #{Rbcli::UserConf::Backend.types.keys.join(', ')}" unless (type.is_a?(String) || type.is_a?(Symbol)) && Rbcli::UserConf::Backend.types.key?(type.downcase.to_sym)
    @params[:type] = type
  end

  def self.schema_file path
    raise Rbcli::ConfigurateError.new "Config schema file location must be a path" unless path.nil? || path.is_a?(String)
    raise Rbcli::ConfigurateError.new "May not define both a schema_hash and schema_file together." if @params[:schema_hash] && !path.nil?
    @params[:schema_file] = path
  end

  def self.schema_hash hash
    raise Rbcli::ConfigurateError.new "Config schema hash must be a hash" unless hash.nil? || hash.is_a?(Hash)
    raise Rbcli::ConfigurateError.new "May not define both a schema_hash and schema_file together." if @params[:schema_file] && !hash.nil?
    @params[:schema_hash] = hash
  end

  def self.save_on_exit soe
    Rbcli::Engine.register_operation Proc.new { Rbcli::Warehouse.get(:config, :parsedopts).save! }, name: :save_config, priority: 160 if soe
  end

  def self.create_if_not_exists cne
    raise Rbcli::ConfigurateError.new "Config 'create_if_not_exists' must be true or false" unless cne.is_a?(TrueClass) || cne.is_a?(FalseClass)
    @params[:create_if_not_exists] = cne
  end

  def self.suppress_errors suppress
    raise Rbcli::ConfigurateError.new "Config 'suppress_errors' must be true or false" unless suppress.is_a?(TrueClass) || suppress.is_a?(FalseClass)
    @params[:suppress_errors] = suppress
  end

  def self.banner text
    raise Rbcli::ConfigurateError.new "The banner must be set to a string." unless text.is_a?(String)
    @params[:banner] = text
  end

  def self.defaults hash
    raise Rbcli::ConfigurateError.new "The default configuration must be a hash." unless hash.is_a?(Hash)
    @params[:defaults] = hash
  end

  def self.skeleton text
    raise Rbcli::ConfigurateError.new "The skeleton data must be set to a string." unless text.is_a?(String)
    @params[:skeleton] = text
  end
end