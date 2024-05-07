# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'rubygems'

class Rbcli::DeprecationWarning
  def initialize offending_object, warn_at: nil, deprecate_at: nil, message: nil
    if offending_object.is_a?(String)
      @offender = offending_object
      @in_rbcli = offending_object.include?('Rbcli')
    else
      @offender = (offending_object.respond_to?(:name) && offending_object.name.include?('::')) ? @offender = offending_object.name : @offender = offending_object.class.name
      @in_rbcli = offending_object.name.include?('Rbcli')
    end
    # @method = self.caller_locations[1].label
    @message = message

    raise Rbcli::ConfigurateError.new "The `warn_at` and `deprecate_at` values must both be set" if warn_at.nil? || deprecate_at.nil?
    raise Rbcli::ConfigurateError.new "Version string must be set in Rbcli::Configurate.cli to use deprecation warnings" if !@in_rbcli && Rbcli::Warehouse.get(:version, :appinfo).nil?
    @current_version = @in_rbcli ? Rbcli::VERSION : Gem::Version.new(Rbcli::Warehouse.get(:version, :appinfo))
    @warning_version = Gem::Version.new(warn_at)
    @error_version = Gem::Version.new(deprecate_at)
    raise Rbcli::ConfigurateError.new "Warning version must come earlier than the deprecation version" if @warning_version >= @error_version

    @callerstack = self.caller_locations
    self.parse
  end

  private

  def parse
    if @current_version >= @error_version
      Rbcli.log.error [
                        "DEPRECATION ERROR -- #{@offender.to_s}".red.bold + " -- The removal of this method is imminent. Please update your application accordingly.".red,
                        @message.nil? ? nil : @message.red
                      ].reject(&:nil?).map { |str| "DEPR".red + ' || ' + str }.join("\n"), "DEPR"
    elsif @current_version >= @warning_version
      Rbcli.log.warn [
                       "DEPRECATION WARNING -- #{@offender.to_s.yellow.bold}" + " -- This method is scheduled to be removed on version #{@error_version}. You are on version #{@current_version}.".yellow,
                       @message.nil? ? nil : @message.yellow
                     ].reject(&:nil?).map { |str| "DEPR".yellow + ' || ' + str }.join("\n"), "DEPR"
    end
  end
end