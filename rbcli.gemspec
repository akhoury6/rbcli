##################################################################################
#     RBCli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2018 Andrew Khoury                                           #
#                                                                                #
#     This program is free software: you can redistribute it and/or modify       #
#     it under the terms of the GNU General Public License as published by       #
#     the Free Software Foundation, either version 3 of the License, or          #
#     (at your option) any later version.                                        #
#                                                                                #
#     This program is distributed in the hope that it will be useful,            #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#     GNU General Public License for more details.                               #
#                                                                                #
#     You should have received a copy of the GNU General Public License          #
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.     #
#                                                                                #
#     For questions regarding licensing, please contact andrew@blacknex.us       #
##################################################################################

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbcli/version'

Gem::Specification.new do |spec|
	spec.name          = 'rbcli'
	spec.version       = Rbcli::VERSION
	spec.authors       = ['Andrew Khoury']
	spec.email         = ['andrew@blacknex.us']

	spec.summary       = %q{A CLI Application/Tooling Framework for Ruby}
	spec.description   = %q{RBCli is a framework to quickly develop command-line tools and applications.}
	spec.homepage      = 'https://akhoury6.github.io/rbcli'
	spec.license       = 'GPLv3'

	spec.required_ruby_version = '>= 2.3'

	# Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
	# to allow pushing to a single host or delete this section to allow pushing to any host.
	# if spec.respond_to?(:metadata)
	# 	spec.metadata["allowed_push_host"] = "http://mygemserver.com"
	# else
	# 	raise "RubyGems 2.0 or newer is required to protect against " \
	# 		"public gem pushes."
	# end

	# Specify which files should be added to the gem when it is released.
	# The `git ls-files -z` loads the files in the RubyGem that have been added into git.
	spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
		`git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
	end
	spec.bindir        = 'exe'
	spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
	spec.require_paths = ['lib']

	spec.add_development_dependency 'bundler', '~> 1.16'
	spec.add_development_dependency 'rake', '~> 10.0'
	spec.add_development_dependency 'minitest', '~> 5.0'

	spec.add_dependency 'colorize', '~> 0.8'
	spec.add_dependency 'deep_merge', '~> 1.2'
	spec.add_dependency 'aws-sdk-dynamodb', '~> 1.6'
	spec.add_dependency 'macaddr', '~> 1.7'
	spec.add_dependency 'rufus-scheduler', '~> 3.5'
	spec.add_dependency 'octokit', '~> 4.9'
	spec.add_dependency 'mdless', '~> 0.0'
	spec.add_dependency 'net-ssh', '~> 5.0'
	spec.add_dependency 'net-scp', '~> 1.2'


	#spec.add_dependency 'trollop', '~> 2.1'
end
