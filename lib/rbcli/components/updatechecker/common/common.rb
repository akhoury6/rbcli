# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
# TODO: Detect invalid network connections and skip
# TODO: Add a timeout
require 'rubygems'
module Rbcli::UpdateChecker
  module Common
    def check_for_updates
      show_message if update_available?
    end

    private

    def update_available?
      Rbcli.log.debug "Checking for updates", "UPDT"
      @latest_version = get_latest_version
      unless @latest_version.nil?
        begin
          update_needed = Gem::Version.new(@latest_version) > Gem::Version.new(Rbcli::Warehouse.get(:version, :appinfo))
        rescue ArgumentError => e
          Rbcli.log.warn "Update check failed: #{e.message}"
          false
        else
          Rbcli.log.debug "Latest version: #{@latest_version}", "UPDT"
          Rbcli.log.debug "Current version: #{Rbcli::Warehouse.get(:version, :appinfo)}", "UPDT"
          Rbcli.log.debug "Update not required", "UPDT" unless update_needed
          update_needed
        end
      end
    end

    def show_message
      Rbcli.log.warn "An update is available to #{Rbcli::Warehouse.get(:appname, :appinfo)} (#{Rbcli::Warehouse.get(:version, :appinfo)} -> #{@latest_version || get_latest_version})"
      Rbcli.log.warn @message || update_message
      if @force_update
        Rbcli.log.error "This application requires that you update to the latest version to continue using it. It will now exit."
        Rbcli::exit 25
      end
    end

    def get_latest_version
      raise Rbcli::Error.new "Update Checker type #{self.class.name} must define a 'check_for_updates' method."
    end

    def update_message
      raise Rbcli::Error.new "Update Checker type #{self.class.name} must define an 'update_message' method."
    end
  end
end