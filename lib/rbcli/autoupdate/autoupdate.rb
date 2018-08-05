module Rbcli::Configurate
	def self.autoupdate gem: nil, github_repo: nil, access_token: nil, enterprise_hostname: nil, force_update: false, message: nil
		raise StandardError.new "Autoupdater can not have both a gem and git target defined. Please pick one." if gem and github_repo
		raise StandardError.new "Only one autoupdater can be defined." if @data[:autoupdater]
		if gem
			#Rbcli::Autoupdate::GemUpdater.save_defaults
			@data[:autoupdater] = Rbcli::Autoupdate::GemUpdater.new gem, force_update, message
		else
			Rbcli::Autoupdate::GithubUpdater.save_defaults
			@data[:autoupdater] = Rbcli::Autoupdate::GithubUpdater.new github_repo, access_token, enterprise_hostname, force_update, message
		end
		@data[:autoupdater].show_message if @data[:autoupdater].update_available?
	end
end


require 'rubygems'
module Rbcli::Autoupdate
	module Common
		def get_latest_version
			raise Exception.new "Autoupdater type #{self.class.name} must define a 'check_for_updates' method."
		end

		def update_message
			raise Exception.new "Autoupdater type #{self.class.name} must define an 'update_message' method."
		end

		def update_available?
			@latest_version = get_latest_version
			Gem::Version.new(@latest_version) > Gem::Version.new(Rbcli.configuration[:version])
		end

		def show_message
			puts "WARNING: An update is available to #{Rbcli::Configurate::configuration[:scriptname]}. You are currently running version #{Rbcli.configuration[:version]}; the latest is #{@latest_version || get_latest_version}."
			puts @message || update_message
			puts "\n"
			if @force_update
				puts "This application requires that you update to the latest version to continue using it. It will now exit."
				exit 0
			end
		end
	end
end

require "rbcli/autoupdate/gem_updater"
require "rbcli/autoupdate/github_updater"