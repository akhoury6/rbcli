# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'deep_merge'
require 'json-schema'
require_relative 'backend'

class Rbcli::Config < Hash
  def initialize location: nil, type: nil, schema_location: nil, create_if_not_exists: false, suppress_errors: false
    location = [location] unless location.is_a?(Array)
    find_location = Proc.new do |method|
      location.each do |loc|
        storage = Rbcli::UserConf::Backend.create(loc, type: type)
        if storage.send(method)
          Rbcli.log.debug("Found config storage at '#{loc}'", "CONF") if method == :exist? && !loc.nil?
          Rbcli.log.debug("Ready to create config at '#{loc}'", "CONF") if method == :savable? && !loc.nil?
          @location = loc
          @storage = storage
          @should_create = true if method == :savable?
          break true
        end
      end
    end
    find_location.call(:exist?)
    find_location.call(:savable?) if !defined?(@location) && create_if_not_exists

    if (defined?(@location) && !@location.nil? && @location != :null) || type == :env
      Rbcli.log.debug "Instantiated config of type '#{@storage.type}' at '#{@location}'", "CONF"
    elsif location.nil? || location == :null || location == [nil]
      Rbcli.log.debug "Instantiated null config; data will not be stored", "CONF"
      @location = :null
      @storage = Rbcli::UserConf::Backend.create(:null)
    elsif suppress_errors
      Rbcli.log.debug "Location(s) could not be found and/or are not writeable. Instantiating null config and failing silently.", "CONF"
      @location = :null
      @storage = Rbcli::UserConf::Backend.create(:null)
    else
      Rbcli.log.fatal "Config file could not be loaded. Please verify that it exists at one of the following locations: #{location.join(", ")}", "CONF"
      Rbcli::exit 2
    end

    @original_hash = {}
    @declared_defaults = { groups: {}, options: {}, helptext: nil }
    @suppress_errors = suppress_errors
    @type = @storage.nil? ? nil : @storage.type.downcase.to_sym
    if schema_location
      @schema = self.class.new(location: schema_location)
      @schema.is_schema = true
    end
  end

  attr_accessor :is_schema, :type

  def set_banner text
    @declared_defaults[:helptext] = text
  end

  def add_group path_arr, helptext: nil
    make_group path_arr, helptext: helptext, nested: @declared_defaults
  end

  def add_default slug, helptext: nil, group_path: nil, default: nil, permitted: nil
    make_group group_path, nested: @declared_defaults
    make_default slug, helptext: helptext, group_path: group_path, default: default, permitted: permitted, nested: @declared_defaults
  end

  def load!
    if @should_create
      Rbcli.log.add (@suppress_errors ? :debug : :info), "Config file #{@location} does not exist. Creating with default values.", "CONF"
      self.deep_merge!(@storage.respond_to?(:parse_defaults) ? @storage.parse_defaults(defaults) : defaults)
      self.save!
    else
      Rbcli.log.debug "Loading #{@is_schema ? 'schema' : 'config'} file", "CONF"
      @original_hash = @storage.load(defaults: self.defaults)
      if !@storage.loaded?
        Rbcli.log.add (@suppress_errors ? :debug : :warn), "Could not load #{@is_schema ? 'schema' : 'config'} file", "CONF"
        Rbcli.log.add (@suppress_errors ? :debug : :warn), "Using defaults", "CONF" unless self.defaults.empty?
        return false
      else
        self.deep_merge!(@storage.respond_to?(:parse_defaults) ? @storage.parse_defaults(defaults) : defaults)
        self.deep_merge!(@original_hash.deep_symbolize!) if @original_hash.is_a?(Hash)
      end
    end
  end

  def validate!
    return true if @schema.nil?
    Rbcli.log.debug "Validating config against schema", "CONF"
    @schema.load!
    begin
      JSON::Validator.validate!(@schema, self)
    rescue JSON::Schema::ValidationError => e
      Rbcli.log.send (@suppress_errors ? :debug : :error), "There are errors in the config. Please fix these errors and try again."
      Rbcli.log.send (@suppress_errors ? :debug : :error), JSON::Validator.fully_validate(@schema, self).join("\n")
      Rbcli::exit 3 unless @suppress_errors
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

  def annotate!
    @storage.annotate! @declared_defaults
  end

  def inspect
    @declared_defaults.inspect
  end

  def defaults
    data = {}
    traverse = Proc.new do |dataloc, defaultsloc|
      dataloc.merge!(defaultsloc[:options].map { |k, v| [k, v[:default]] }.to_h)
      defaultsloc[:groups].keys.each do |k|
        dataloc[k] = {}
        traverse.call dataloc[k], defaultsloc[:groups][k]
      end
    end
    traverse.call(data, @declared_defaults)
    data
  end

  private

  def make_group path_arr, helptext: nil, nested: nil
    return true if path_arr.nil? || path_arr.respond_to?(:empty?) && path_arr.empty?
    path_arr = [path_arr] unless path_arr.is_a?(Array)
    nested[:groups][path_arr.first.to_sym] ||= { groups: {}, options: {}, helptext: nil }
    if path_arr.length == 1
      nested[:groups][path_arr.first.to_sym][:helptext] = helptext
    else
      make_group path_arr[1..-1], helptext: helptext, nested: nested[:groups][path_arr.first.to_sym]
    end
  end

  def make_default slug, helptext: nil, group_path: nil, default: nil, permitted: nil, nested: nil
    group_path = [group_path] unless group_path.is_a?(Array)
    if group_path.empty? || group_path.first.nil?
      nested[:options][slug.to_sym] = { helptext: helptext, default: default, permitted: permitted }
    else
      make_default(slug, helptext: helptext, group_path: group_path[1..-1], default: default, permitted: permitted, nested: nested[:groups][group_path.first.to_sym])
    end
  end
end

require_relative 'config_of_death'