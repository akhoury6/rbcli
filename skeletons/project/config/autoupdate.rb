Rbcli::Configurate.me do
	####
	# AUTOUPDATE
	###
	# RBCli can notify users when you have an update to your application.
	# This requires your application to be published either on Rubygems.org, Github, or Github Enterprise.
	# Note that only one can be enabled at a time.
	# For more details on each integration, see below.
	###

	## Autoupdate, Github -- (Optional) --  Check for updates to this application at a GitHub repo.
	# The repo should use version number tags in accordance to Github's best practices: https://help.github.com/articles/creating-releases/
	#
	# Note that the `access_token` can be overridden by the user via their configuration file, so it can be left as `nil`,
	# which will require your users to enter their github tokens to use this feature.
	# For instructions on generating a new access token, see: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
	# The token is not needed if using a public repo.
	#
	# The `enterprise_hostname` setting allows you to point RBCli at a local GitHub Enterprise server.
	#
	# Setting `force_update: true` will halt execution if an update is available, forcing the user to update.
	# Uncomment the line below to enable

	#autoupdate github_repo: '<your_user>/<your_repo>', access_token: nil, enterprise_hostname: nil, force_update: false


	## Autoupdate, Rubygems.org -- (Optional) -- Check for updates to this application on Rubygems.org
	# Uncomment the line below to enable

	#autoupdate gem: '<your_gem>', force_update: false

end