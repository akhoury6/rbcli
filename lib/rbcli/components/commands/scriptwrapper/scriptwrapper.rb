# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'json'
require 'open3'

class Rbcli::ScriptWrapper
  def initialize inline: nil, path: nil, vars: nil
    @inline = inline
    @path = path.nil? ? nil : File.expand_path(path)
    @vars = vars || []
  end

  def execute opts = nil, params = nil, args = nil, config = nil, env = nil
    sh_libpath = File.expand_path(File.join(File.dirname(__FILE__), 'lib-rbcli.sh'))
    if @inline.nil? && !@path.nil?
      cmd = File.read(@path).include?('lib-rbcli.sh') ? '' : "source '#{sh_libpath}'; "
      cmd += "source '#{@path}'"
      inject_rbcli = false
    else
      cmd = @inline
      inject_rbcli = true
    end
    self.class.run_script cmd, opts: opts, params: params, args: args, config: config, env: env, vars: @vars, inject_rbcli: inject_rbcli
  end

  def self.run_script cmd, opts: nil, params: nil, args: nil, config: nil, env: nil, vars: nil, inject_rbcli: true,
    capture_output: false, silent: false, prefix: nil, color: nil, bgcolor: nil
    envs = {}
    %w(opts params args config env vars).each do |k|
      envs["__RBCLI_#{k.upcase}"] = eval("#{k}.nil?") ? [].to_json : eval("#{k}.to_json")
    end
    vars.each do |k, v|
      envs[k.to_s.upcase] = v
    end unless vars.nil?

    if inject_rbcli && !cmd.include?('lib-rbcli.sh')
      sh_libpath = File.expand_path(File.join(File.dirname(__FILE__), 'lib-rbcli.sh'))
      cmd = cmd.lines.insert((cmd.start_with?('#!') ? 1 : 0), "source '#{sh_libpath}'\n").join
    end

    output = +''
    retval = nil
    prefix ||= ''
    Open3.popen2e(envs, cmd) do |_stdin, stdout_and_stderr, wait_threads|
      until (line = stdout_and_stderr.gets).nil? do
        if line.include?(' || ')
          severity, text = line.split(' || ', 2)
        else
          severity = 'INFO'
          text = line
        end
        output << text
        Rbcli.log.add(Logger.const_get(severity.upcase.to_sym), prefix + text.chomp.colorize(color: color, background: bgcolor), 'SCRP') unless silent
        Rbcli.log.add(-1, prefix + text.chomp.colorize(color: color, background: bgcolor), 'SCRP') if silent
      end
      retval = wait_threads.value
    end
    Rbcli.log.debug "Return value of script was: #{retval}", "SCRP"
    capture_output ? output : retval.success?
  end
end