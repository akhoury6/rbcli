# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'fileutils'

module Rbcli::UserConf
end

class Rbcli::UserConf::Backend
  @registered_types = {}

  def self.types
    {
      yaml: Proc.new { |filename| filename.is_a?(String) && (filename.downcase.end_with?('.yaml') || filename.downcase.end_with?('.yml')) },
      json: Proc.new { |filename| filename.is_a?(String) && filename.downcase.end_with?('.json') },
      ini: Proc.new { |filename| filename.is_a?(String) && filename.downcase.end_with?('.ini') },
      toml: Proc.new { |filename| filename.is_a?(String) && filename.downcase.end_with?('.toml') },
      env: Proc.new { |filename| false },
      null: Proc.new { |filename| true }
    }
  end

  def self.inherited(subklass)
    @registered_types[subklass.name.split('::').last.sub(/Store$/, '').downcase.to_sym] = subklass
  end

  def self.create filename, type: nil
    type ||= self.types.map { |slug, check| [slug, check.call(filename)] }.to_h.select { |slug, match| match }.first.first
    type = type.to_s.downcase.to_sym
    require_relative "backends/#{type.to_s}"
    @registered_types[type].new(filename, type)
  end

  def initialize filename, type
    @path = File.expand_path(filename)
    @path = File.realpath(@path) if File.symlink?(@path)
    @type = type.to_s.capitalize
    @loaded = false
  end

  attr_reader :type, :loaded
  alias_method :loaded?, :loaded

  # The defaults: parameter is used on some backends to know which fields to expect and parse
  def load defaults: nil
    begin
      text = File.read(@path)
    rescue Errno::ENOENT => _
      Rbcli.log.debug "Attempted to load #{@type} config file but did not find it at '#{@path}'", "CONF"
    else
      Rbcli.log.debug "Loaded #{@type} config file at '#{@path}'", "CONF"
      self.parse(text)
    end
  end

  def save hash
    Rbcli.log.debug "Saving #{@type} config file at '#{@path}'", "CONF"
    begin
      File.write(@path, self.unparse(hash))
    rescue Errno => err
      Rbcli.log.error "Could not save config to file at '#{@path}'", "CONF"
      Rbcli.log.error "Error: #{err.message}", "CONF"
      false
    else
      hash
    end
  end

  def savable?
    File.writable?(File.exist?(@path) ? @path : File.dirname(@path))
  end

  def exist?
    File.exist?(@path)
  end

  def annotate! defaults
    begin
      text = File.read(@path)
    rescue Errno::ENOENT => _
      Rbcli.log.debug "Attempted to annotate #{@type} config file but did not find it at '#{@path}'", "CONF"
      return nil
    end
    Rbcli.log.debug "Annotating #{@type} config file at '#{@path}'", "CONF"

    text = self.inject_banner(text, defaults[:helptext])
    File.write(@path, text)

    begin
      File.write(@path, text)
      Rbcli.log.debug "Saved #{@type} annotations at '#{@path}'", "CONF"
    rescue Errno => err
      Rbcli.log.error "Could not save annotations to '#{@path}'", "CONF"
      Rbcli.log.error "Error: #{err.message}", "CONF"
      return nil
    else
      return true
    end
  end
end