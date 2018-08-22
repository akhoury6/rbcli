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

#####
#  Configurate
###
# This plugin class allows declaring configuration blocks dynamically
##
module Rbcli::Configurate
	##
	# If a non-existant method is called, we attempt to load the plugin.
	# If the plugin fails to load we display a message to the developer
	##
	def self.method_missing(method, *args, &block)
		filename = "#{File.dirname(__FILE__)}/configurate_blocks/#{method.to_s.downcase}.rb"
		if File.exists? filename
			require filename
			self.send method, *args, &block
		else
			msg = "Invalid Configurate plugin called: `#{method}` in file #{File.expand_path caller[0]}"
			Rbcli::log.fatal {msg}
			raise Exception.new msg
		end
	end
end

module Rbcli::Configurable

	def self.included klass
		name = klass.name.split('::')[-1]

		# We dynamically add two methods to the module: one that runs other methods dynamially, and one that
		# displays a reasonable message if a method is missing
		klass.singleton_class.class_eval do
			define_method :rbcli_private_running_method do |&block|
				@self_before_instance_eval = eval 'self', block.binding
				instance_eval &block
			end

			define_method :method_missing do |method, *args, &block|
				msg = "Invalid Configurate.#{self.name.split('::')[-1].downcase} method called: `#{method}` in file #{File.expand_path caller[0]}"
				Rbcli::log.fatal {msg}
				raise Exception.new msg
			end
		end

		# This will dynamically create the configuate block based on the class name.
		# For example, if the class name is 'Me', then the resulting block is `Confiugrate.me`
		Rbcli::Configurate.singleton_class.class_eval do
			define_method name.downcase.to_sym do |&block|
				mod = self.const_get name
				mod.rbcli_private_running_method &block
			end
		end
	end

end

module Rbcli
	def self.configuration mod, key = nil
		d = Rbcli::Configurate.const_get(mod.to_s.capitalize.to_sym).data
		(key.nil?) ? d : d[key]
	end
end