# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require_relative 'common/common'
require 'octokit'

module Rbcli::UpdateChecker
  class GithubChecker
    include Common

    def initialize reponame, access_token, enterprise_hostname, force_update, message
      @reponame = reponame
      @force_update = force_update
      @message = message
      @hostname = enterprise_hostname || "github.com"

      Octokit.configure { |c| c.api_endpoint = "https://#{enterprise_hostname}/api/v3/" } if enterprise_hostname

      #@client = Octokit::Client.new :client_id => client_id, :client_secret => client_secret
      @client = Octokit::Client.new(access_token: access_token)
    end

    private

    def get_latest_version
      begin
        @client.repo(@reponame).rels[:tags].get.data.map { |t| t[:name] }[0].sub(/^[v]*/, "")
      rescue Faraday::ConnectionFailed => e
        Rbcli.log.debug ["Connection error when getting latest version from github", "#{e.message}", "Failing update check silently"].join("\n"), "UPDT"
        nil
      rescue Octokit::TooManyRequests => e
        Rbcli.log.debug ["Reached GitHub rate limit; too many requests", "#{e.message}", "Failing update check silently"].join("\n"), "UPDT"
        nil
      rescue NoMethodError => e
        Rbcli.log.debug ["Repo was found but could not find the version tag", "#{e.message}", "Failing update check silently"].join("\n"), "UPDT"
        nil
      end
    end

    def update_message
      "Please check the github repo https://#{@hostname}/#{@reponame} for instructions on how to update to the latest version"
    end
  end
end