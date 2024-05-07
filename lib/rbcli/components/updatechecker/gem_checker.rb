# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require_relative 'common/common'
require 'rest-client'
require 'json'

module Rbcli::UpdateChecker
  class GemChecker
    include Common

    def initialize gemname, force_update, message
      @gemname = gemname
      @url = "https://rubygems.org/api/v1/versions/#{gemname}/latest.json"
      @force_update = force_update
      @message = message
    end

    private

    def get_latest_version
      begin
        response = RestClient::Request.execute(method: :get, url: @url, timeout: 1)
        JSON.parse(response.body)['version']
      rescue SocketError => e
        Rbcli.log.debug ["Connection error when getting latest gem version", "#{e.message}", "Failing update check silently."].join("\n"), "UPDT"
        nil
      rescue Net::OpenTimeout => _e
        Rbcli.log.debug "Autoupdate check failed - timeout while connecting to RubyGems API. Failing silently."
        nil
      end
    end

    def update_message
      "Please run `gem update #{@gemname}` to upgrade to the latest version. You can preview it at: https://rubygems.org/gems/#{@gemname}/versions/#{@latest_version}"
    end
  end
end