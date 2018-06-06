require 'net/http'
require 'json'

module Rbcli::Autoupdate
	class GemUpdater
		include Common

		def initialize gemname, force_update
			@gemname = gemname
			@uri = URI.parse "https://rubygems.org/api/v1/versions/#{gemname}/latest.json"
			@force_update = force_update
		end

		def get_latest_version
			response = Net::HTTP.get(@uri)
			JSON.parse(response)['version']
		end

		def update_message
			"Please check the Ruby gem #{@gemname} for instructions. You can see it at: https://rubygems.org/gems/#{@gemname}/versions/#{@latest_version}"
		end

		# def self.save_defaults
		# 	Rbcli::Config::add_categorized_defaults :gem_update, 'Automatically Check for Updates from RubyGems', {
		# 			access_token: {
		# 					description: 'Access token for GitHub API. This is only required for private repos. For help, see: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/',
		# 					value: nil
		# 			},
		# 			enterprise_hostname: {
		# 					description: 'Hostname for GitHub Enterprise. Leave as null (~) for public GitHub.',
		# 					value: nil
		# 			}
		# 	}
		# end
	end
end