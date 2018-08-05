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
#     For questions regarding licensing, please contact andrew@blacknex.us        #
##################################################################################


module Rbcli
	def self.load_project
		project_root = File.expand_path("#{File.dirname(caller[0].split(':')[0])}/../")

		# Add lib to the load path for the user's convenience
		lib = "#{project_root}/lib"
		$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

		# We require all ruby files as-is
		%w(config hooks application application/commands).each do |dir|
			dirpath = "#{project_root}/#{dir}"
			Dir.glob "#{dirpath}/*.rb" do |file|
				require file
			end if Dir.exists? dirpath
		end

		# We automatically pull in default user configs
		configspath = "#{project_root}/userconf"
		Dir.glob "#{configspath}/*.{yml,yaml,json}" do |file|
			Rbcli::Configurate.me {config_defaults file}
		end

	end
end