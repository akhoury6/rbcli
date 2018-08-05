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


##
# Functions to convert hash keys to all symbols or all strings
##
class Hash
	def deep_symbolize! hsh = nil
		hsh ||= self
		hsh.keys.each do |k|
			if k.is_a? String
				hsh[k.to_sym] = hsh[k]
				hsh.delete k
			end
			deep_symbolize! hsh[k.to_sym] if hsh[k.to_sym].is_a? Hash
		end
		hsh
	end

	def deep_stringify! hsh = nil
		hsh ||= self
		hsh.keys.each do |k|
			if k.is_a? Symbol
				hsh[k.to_s] = hsh[k]
				hsh.delete k
			end
			deep_stringify! hsh[k.to_s] if hsh[k.to_s].is_a? Hash
		end
		hsh
	end
end
