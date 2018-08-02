# Automatic Update Check

RBCli can automatically notify users when an update is available. If `force_update` is set (see below), RBCli can halt execution until the user updates their application.

Two sources are currently supported: Github (including Enterprise) and RubyGems.

## GitHub Update Check

The GitHub update check works best when paired with GitHub's best practices on releases. See here: https://help.github.com/articles/creating-releases/

RBCli will check your github repo's tags and compare that version number with one you configured Rbcli with.

```ruby
autoupdate github_repo: 'akhoury6/rbcli', access_token: nil, enterprise_hostname: nil, force_update: false    # (Optional) Check for updates to this application at a GitHub repo. The repo must use version number tags in accordance to best practices: https://help.github.com/articles/creating-releases/
``` 
The `github_repo` should point to the repo using the `user/repo` syntax. 

The `access_token` can be overridden by the user via their configuration file, so it can be left as `nil`. The token is not needed at all if using a public repo. For instructions on generating a new access token, see [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). 

The `enterprise_hostname` setting allows you to point RBCli at a local GitHub Enterprise server.

Setting `force_update: true` will halt execution if an update is available, forcing the user to update.

## Rubygems.org Update Check

The Rubygems update check will check if there is a new published version of the gem on Rubygems.org. The latest published version is compared to the version number you configured RBCli with.

```ruby
autoupdate gem: 'rbcli', force_update: false   # (Optional) Check for updates to this application through RubyGems.org.
```

The `gem` parameter should simply state the name of the gem.
 
Setting `force_update: true` will halt execution if an update is available, forcing the user to update.
