# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate::Logger
  include Rbcli::Configurable

  def self.logger target: :stdout, level: :info, format: :display
    unless target.is_a?(IO) ||
      (defined?(StringIO) && target.is_a?(StringIO)) ||
      (target.is_a?(String) && Dir.exist?(File.dirname(File.expand_path(target)))) ||
      (target.is_a?(Symbol) && [:stdout, :stderr].include?(target.to_sym))
      raise Rbcli::ConfigurateError.new "Log Target is invalid. Please use either :stdout, :stderr, or a valid file path where the directory already exists on the system. Target given: #{target}"
    end
    unless level.is_a?(Integer) || %i(debug info warn error fatal unknown).include?(level)
      raise Rbcli::ConfigurateError.new "Log Level must be one of the following: #{%i(debug info warn error fatal unknown)}. Level provided: #{level}"
    end
    unless Rbcli::Logger.formats.include?(format)
      raise Rbcli::ConfigurateError.new "Log format must be one of the following: #{Rbcli::Logger.formats}. Format provided: #{format}"
    end
    Rbcli.start_logger(target: target, level: level, format: format)
    Rbcli.log.debug "Logger initialized with target #{target} at level #{level}", "CORE"
  end

  def self.format slug, prok
    raise Rbcli::ConfigurateError.new "The slug for the custom log format must be a string or a symbol." unless slug.is_a?(String) || slug.is_a?(Symbol)
    raise Rbcli::ConfigurateError.new "A proc must be provided to use a custom log format" unless prok.is_a?(Proc)
    Rbcli.log.add_format slug, prok
    Rbcli.log.format slug
  end
end
