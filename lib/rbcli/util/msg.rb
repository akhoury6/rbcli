module Rbcli::Msg
	def self.print message, log: false, color: nil
		Rbcli::log.info {message} if log
		STDOUT.print message
	end

	def self.puts message, log: false, color: nil
		Rbcli::log.info {message} if log
		message = message.colorize(color) if Rbcli::config[:colorize_output]
		STDOUT.puts message
	end

	def self.err message, log: false, color: :yellow
		Rbcli::log.warn {message} if log
		message = message.colorize(color) if Rbcli::config[:colorize_output]
		STDERR.puts message
	end

	def self.fatal message, log: true, color: :red, exitcode: 1
		Rbcli::log.fatal {"Exited with the message: " + message} if log
		message = "Error: #{message}"
		message = message.colorize(color) if Rbcli::config[:colorize_output]
		STDERR.puts message
		exit exitcode
	end

	@triggernests = 0

	def self.triggered msg, msg_success, msg_fail = nil, fatality_msg = nil, log: false, success_color: :green, fail_color: :red, newline: false, &block
		@triggernests.times {msg = '  ' + msg}
		@triggernests += 1

		Rbcli::Msg.send ((newline) ? :puts : :print), msg
		result = yield
		tmsg = (result or msg_fail.nil?) ? msg_success : msg_fail
		tcol = (result or msg_fail.nil?) ? success_color : fail_color
		Rbcli::Msg.puts tmsg, log: log, color: tcol
		Rbcli::Msg.fatal fatality_msg, log: log if fatality_msg

		@triggernests -= 1
	end

	def self.yesno question, default_to_yes: false
		yes_display = (default_to_yes) ? 'Y' : 'y'
		no_display = (default_to_yes) ? 'n' : 'N'
		Rbcli::Msg.print "#{question} (#{yes_display}/#{no_display}): ", log: false
		if default_to_yes
			answer = !gets.chomp.casecmp('n').zero?
		else
			answer = gets.chomp.casecmp('y').zero?
		end
		Rbcli::log.info {"Question: #{question}. Answer: #{answer}"}
		answer
	end
end