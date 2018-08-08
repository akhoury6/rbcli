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

require 'net/ssh'
require 'net/scp'
require 'json'
require 'etc'

class Rbcli::RemoteExec

	def initialize cmd, connection_string, remote_identity, params, args, global_opts, config
		@cmd = cmd
		@params = params.to_json.gsub("\"", "\\\"")
		@args = args.to_json.gsub("\"", "\\\"")
		@global_opts = global_opts.to_json.gsub("\"", "\\\"")
		@config = config.to_json.gsub("\"", "\\\"")

		@remote_host = parse_connection connection_string, remote_identity

		## SCRIPT COMMANDS
		if !@cmd.script.nil?
			@execution_block = lambda do |ssh|
				# Set paths
				tmpdir = ssh.exec! 'mktemp -d /tmp/rbcli.XXXXXXXXXXXX'
				remote_script_path = "#{tmpdir.strip}/script.sh"
				local_rbclilib_path = "#{File.dirname(__FILE__)}/../../../lib-sh/lib-rbcli.sh"
				remote_rbclilib_path = "#{tmpdir.strip}/lib-rbcli.sh"

				# Upload scripts
				ssh.scp.upload @cmd.script.path, remote_script_path
				ssh.scp.upload local_rbclilib_path, remote_rbclilib_path
				ssh.exec! "chmod 0700 #{remote_script_path}"

				# We need to test for JQ -- if it is not present we ask the user for the sudo password
				jq_found = ssh.exec!('which jq').exitstatus == 0
				if jq_found
					sudopw = nil
				else
					print "JQ not found on remote system. Please enter sudo password to install it, or leave blank if no password needed: "
					sudopw = gets.chomp
				end

				# Since we need to sudo, we need to send the sudo password when prompted
				#result = ''
				channel = ssh.open_channel do |channel, success|
					channel.on_data do |channel, data|
						print data.to_s
						if !jq_found and data =~ /^\[sudo\] password for /
							channel.send_data "#{sudopw}\n"
							# else
							# 	result += data.to_s
						end
					end
					channel.request_pty
					channel.exec "__RBCLI_PARAMS=\"#{@params}\" __RBCLI_ARGS=\"#{@args}\" __RBCLI_GLOBAL=\"#{@global_opts}\" __RBCLI_CONFIG=\"#{@config}\" source #{remote_script_path}"
					channel.wait
				end
				channel.wait
				#puts result

				# Cleanup
				ssh.exec! "rm -rf #{tmpdir}"
			end

			## EXTERN COMMANDS
		elsif !@cmd.extern.nil?
			@execution_block = lambda do |ssh|
				channel = ssh.open_channel do |channel, success|
					channel.on_data do |channel, data|
						print data.to_s
					end
					channel.request_pty
					channel.exec "__RBCLI_PARAMS=\"#{@params}\" __RBCLI_ARGS=\"#{@args}\" __RBCLI_GLOBAL=\"#{@global_opts}\" __RBCLI_CONFIG=\"#{@config}\" __RBCLI_MYVARS=\"#{@myvars}\" #{@cmd.extern.path}"
					channel.wait
				end
				channel.wait
			end

			## STANDARD COMMANDS
		else
			@execution_block = lambda do |ssh|
				raise Exception.new "Warning: Remote SSH Execution does not yetexist for Standard Ruby commands. Please use a Script or External command to use this feature."
			end
		end

	end

	def run

		case @remote_host[:credstype]
		when :keyfile
			Net::SSH.start(@remote_host[:hostname], @remote_host[:username], port: @remote_host[:port], keys: @remote_host[:creds], keys_only: true, &@execution_block)
		when :keytext
			Net::SSH.start(@remote_host[:hostname], @remote_host[:username], port: @remote_host[:port], key_data: @remote_host[:creds], keys_only: true, &@execution_block)
		when :password
			Net::SSH.start(@remote_host[:hostname], @remote_host[:username], port: @remote_host[:port], password: @remote_host[:creds], keys_only: false, &@execution_block)
		else
			raise Exception.new "Invalid SSH Connection: No credentials specified for host #{@remote_host[:hostname]}"
		end

	end

	private

	def parse_connection connstring, ident
		## We want to split the connection string up
		_, _, user, host, _, port = connstring.match(/^(([^:@\/]+)@)?([^:@\/]+)?(:([\d]+))?/).to_a
		exiting = false
		if host.nil?
			puts "Please enter a valid hostname or IP address for remote execution."
			exiting = true
		end
		begin
			port ||= 22
			port = port.to_i
		rescue
			puts "Please enter a valid port number"
			exiting = true
		end
		exit 1 if exiting

		if File.exist? File.expand_path(ident)
			credstype = :keyfile
		else
			credstype = :password
		end

		{
				hostname: host,
				port: port,
				username: user,
				creds: ident,
				credstype: credstype
		}
	end

end


# class Rbcli::Command
#
# 	def self.remote_exec cmd, params, args, global_opts, config
# 		executor = Rbcli::RemoteExec.new cmd, cmd.remote_host, params, args, global_opts, config
# 		executor.run
# 	end
#
# 	def self.remote_host hostname, port: 22, username: nil, password: nil, keytext: nil, keyfile: nil
# 		@remote_host = {
# 				hostname: hostname,
# 				port: port,
# 				username: username,
# 				creds: keyfile || keytext || password,
# 				credstype: (keyfile.nil?) ? ((keytext.nil?) ? ((password.nil?) ? nil : :password) : :keytext) : :keyfile
# 		}
# 	end
#
# 	def remote_host
# 		self.class.instance_variable_get :@remote_host
# 	end
#
# 	##
# 	# Run command on a remote machine
# 	##
# 	def self.remote_cmd cmd, params, args, global_opts, config
# 		# We do something different depending on if it is a Ruby command, Script, or Extern
# 		unless @commands[cmd].script.nil?
# 			script = @commands[cmd].script
#
# 		end
# 	end
# end