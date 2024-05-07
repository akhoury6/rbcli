# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Core::CmdLibrary
  def self.extended klass
    klass.instance_variable_set :@commands, {}
  end

  def inherited subklass
    raise Rbcli::CommandError.new "The command #{subklass.name.downcase} cannot be defined twice." unless @commands[subklass.name.downcase].nil?
    subklass.instance_variable_set :@data, {
      description: nil,
      helptext: nil,
      default: nil,
      action: nil,
      script: nil,
      usage: nil,
      parameter_prompts: {},
      parser: Optimist::Parser.new
    }
    @commands[subklass.name.downcase] = subklass.new
    Rbcli::Cliopts.register_command subklass.name.downcase
    Rbcli.log.debug "Registered command '#{subklass.name.downcase}'", "CORE"

    Rbcli::Engine.register_operation Proc.new {
      Rbcli.log.debug "Running command '#{Rbcli::Cliopts.cmd[:name]}'", "CORE"
      Rbcli::Cliopts.cmd[:command].data[:action].call(Rbcli::Cliopts.opts,
                                                      Rbcli::Cliopts.cmd[:params],
                                                      Rbcli::Cliopts.cmd[:args],
                                                      (Rbcli::Configurate.constants.include?(:Config) ? Rbcli.configuration(:config)[:config] : Rbcli::Config.new(suppress_errors: true)),
                                                      (Rbcli::Configurate.constants.include?(:Envvars) ? Rbcli.configuration(:envvars)[:envvars] : Rbcli::Config.new(suppress_errors: true))
      ) unless Rbcli::Cliopts.cmd[:command].data[:action].nil?
      Rbcli::Cliopts.cmd[:command].data[:script].execute(Rbcli::Cliopts.opts,
                                                         Rbcli::Cliopts.cmd[:params],
                                                         Rbcli::Cliopts.cmd[:args],
                                                         (Rbcli::Configurate.constants.include?(:Config) ? Rbcli.configuration(:config)[:config] : Rbcli::Config.new(suppress_errors: true)),
                                                         (Rbcli::Configurate.constants.include?(:Envvars) ? Rbcli.configuration(:envvars)[:envvars] : Rbcli::Config.new(suppress_errors: true))
      ) unless Rbcli::Cliopts.cmd[:command].data[:script].nil?
    }, name: :run_command, priority: 100 if @commands.count == 1
  end

  def data
    self.instance_variable_get :@data;
  end

  def commands
    @commands.select { |name, cmd| !cmd.data[:default] }
  end

  def default_command
    default_commands = @commands.select { |_name, cmd| cmd.data[:default] }
    raise Rbcli::CommandError.new "Can't execute - more than one command has been specified as default: #{default_commands.keys}" if default_commands.count > 1
    default_commands.count == 1 ? default_commands.first : nil
  end
end

class Rbcli::Command
  extend Rbcli::Core::CmdLibrary

  def data
    self.class.data
  end

  def self.description desc = nil
    desc.nil? ? @data[:description] : @data[:description] = desc
  end

  def self.helptext text = nil
    text.nil? ? @data[:helptext] : @data[:helptext] = text
  end

  def self.usage text = nil
    text.nil? ? @data[:usage] : @data[:usage] = text
  end

  def self.default
    @data[:default] = true
  end

  def self.parameter * args
    if !args[2].nil? && !args[2].empty? && args[2][:prompt].is_a?(String)
      @data[:parameter_prompts][args[0]] = { prompt: args[2][:prompt], default: args[2][:default], type: args[2][:type].nil? ? nil : args[2][:type].to_s.chomp('s').to_sym }
      args[2][:required] = false
    end
    @data[:parser].opt *args
  end

  def self.action & block
    @data[:action] = block
  end

  def self.script inline: nil, path: nil, vars: nil
    if !inline.nil? && !path.nil?
      raise Rbcli::CommandError.new "Can't assign both an inline script and an external path to command '#{self.name}'"
    end
    if path == :builtin or path.nil?
      callerscript = caller_locations.first.absolute_path
      path = "#{File.dirname(callerscript)}/scripts/#{File.basename(callerscript, ".*")}.sh"
    end
    require File.join(RBCLI_LIBDIR, 'components', 'scriptwrapper', 'scriptwrapper.rb')
    @data[:script] = Rbcli::ScriptWrapper.new inline: inline, path: path, vars: vars
  end
end