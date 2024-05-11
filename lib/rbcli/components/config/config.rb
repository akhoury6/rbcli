# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'deep_merge'
require 'json-schema'
require_relative 'backend'

class Rbcli::Config < Hash
  def initialize location: nil, type: nil, schema_file: nil, schema_hash: nil, create_if_not_exists: false, suppress_errors: false, banner: nil, defaults: {}, skeleton: nil
    location = [location] unless location.is_a?(Array)
    locations = location.map { |path| [path, Rbcli::UserConf::Backend.create(path, type: type)] }.reject { |path, storage| !(path.nil? || path == :null) && storage.type == 'NULL' }
    existing_location = locations.select { |_path, storage| storage.exist? }.first
    savable_location = locations.select { |_path, storage| storage.savable? }.first
    if !existing_location.nil?
      @location, @storage = existing_location
      Rbcli.log.debug @location.nil? ? "Instantiated null config; data will not be stored" : "Found config of type '#{@storage.type}' at '#{@location}'", "CONF"
    elsif !savable_location.nil? && create_if_not_exists
      @location, @storage = savable_location
      @should_create = true
      Rbcli.log.debug "Ready to create new config of type '#{@storage.type}' at '#{@location}'", "CONF"
    elsif suppress_errors
      @location, @storage = :null, Rbcli::UserConf::Backend.create(:null)
      Rbcli.log.debug "Location(s) could not be found and/or are not writeable. Instantiating null config and failing silently.", "CONF"
    else
      Rbcli.log.fatal "Config file could not be loaded. Please verify that it exists at one of the following locations: #{location.join(", ")}", "CONF"
      Rbcli::exit 2
    end
    @suppress_errors = suppress_errors
    @original_hash = {}
    @defaults = defaults
    @skeleton = skeleton
    @banner = banner
    if schema_hash
      @schema = self.class.new
      schema_hash.each_key { |key| @schema[key] = schema_hash[key] }
      @schema.is_schema = true
    elsif schema_file
      @schema = self.class.new(location: schema_file)
      @schema.is_schema = true
    else
      @schema = nil
    end
  end

  attr_accessor :is_schema, :defaults
  attr_reader :location, :schema, :skeleton, :banner, :suppress_errors

  def add_default slug, default = nil
    @defaults[slug] = default
  end

  def type
    @storage.type.downcase.to_sym
  end

  def load!
    if @should_create
      Rbcli.log.add (@suppress_errors ? :debug : :info), "Config file #{@location} does not exist. Creating with default values.", "CONF"
      return self.create!(force: true)
    end
    Rbcli.log.debug "Loading #{@is_schema ? 'schema' : 'config'} file", "CONF"
    begin
      @original_hash = @storage.load(@defaults)
    rescue Rbcli::ParseError => e
      Rbcli.log.add (@suppress_errors ? :debug : :fatal), e.message, "CONF"
      Rbcli.exit 3 unless @suppress_errors
      @original_hash = {}
    end
    unless @storage.loaded?
      Rbcli.log.add (@suppress_errors ? :debug : :warn), "Could not load #{@is_schema ? 'schema' : 'config'} file", "CONF"
      Rbcli.log.add (@suppress_errors ? :debug : :warn), "Using defaults", "CONF" unless @defaults.empty?
    end
    self.clear
    self.deep_merge!(@storage.respond_to?(:parse_defaults) ? @storage.parse_defaults(@defaults) : @defaults)
    self.deep_merge!(@original_hash.deep_symbolize!) if @original_hash.is_a?(Hash)
  end

  def validate!
    return true if @schema.nil?
    Rbcli.log.debug "Validating config against schema", "CONF"
    @schema.load! unless @schema.location.nil?
    begin
      JSON::Validator.validate!(@schema, self)
    rescue JSON::Schema::ValidationError => _e
      Rbcli.log.send (@suppress_errors ? :debug : :error), "There are errors in the config. Please fix these errors and try again."
      Rbcli.log.send (@suppress_errors ? :debug : :error), JSON::Validator.fully_validate(@schema, self).join("\n")
      Rbcli::exit 4 unless @suppress_errors
      return false
    end
    Rbcli.log.debug "Validated config against schema successfully", "CONF"
    true
  end

  def save!
    unless @storage.savable?
      Rbcli.log.add (@suppress_errors ? :debug : :warn), "Config file not savable. Data not stored.", "CONF"
      return false
    end
    hash_to_save = Marshal.load(Marshal.dump(self)).to_h # This removes all custom instance variables and types from the data
    if hash_to_save == @original_hash && !@should_create
      Rbcli.log.debug "No changes detected in the config. Skipping save.", "CONF"
    else
      Rbcli.log.debug "Changes detected in the config. Saving updated config.", "CONF"
      @storage.save(hash_to_save.deep_stringify!)
      @original_hash = hash_to_save.deep_symbolize!
      @should_create = false
    end
    self
  end

  def create! path: nil, force: false
    return false unless @location.is_a?(String)
    if File.exist?(path || @location) && !force
      Rbcli.log.add (@suppress_errors ? :debug : :error), "Config file already exists; can not overwrite.", "CONF"
      Rbcli::exit 4 unless @suppress_errors
      return false
    end
    if @skeleton
      (path.nil? ? @storage : Rbcli::UserConf::Backend.create(path, type: self.type)).save_raw @skeleton
    else
      self.deep_merge!(@storage.respond_to?(:parse_defaults) ? @storage.parse_defaults(@defaults) : @defaults)
      self.save!
    end
    @storage.annotate!(@banner) if @banner
  end

  def annotate!
    @storage.annotate! @banner
  end
end

require_relative 'config_of_death'