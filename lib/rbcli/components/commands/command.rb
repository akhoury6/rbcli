# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
class Rbcli::Command
  def initialize name
    raise Rbcli::CommandError.new "Command name can only contain the characters [A-Za-z0-9_]+" unless /[A-Za-z0-9_]+/.match?(name)
    @name = name.to_s.downcase
    @default = false
    @description = nil
    @helptext = nil
    @usage = nil
    @action = nil
    @script = nil
    @params = []
  end

  attr_reader :name, :params

  def description text = nil
    return @description if text.nil?
    @description = text
  end

  def helptext text = nil
    return @helptext if text.nil?
    @helptext = text
  end

  def usage text = nil
    return @usage if text.nil?
    @usage = text
  end

  def default
    @default = true
  end

  def default?
    @default
  end

  def parameter * args
    args[2][:required] = false if !args[2].nil? && !args[2].empty? && args[2][:prompt].is_a?(String)
    @params.push(args)
  end

  def action & block
    @action = block
    @script = nil
  end

  def inline_script inline: nil, vars: nil
    require_relative 'scriptwrapper/scriptwrapper'
    @action = nil
    @script = Rbcli::ScriptWrapper.new inline: inline, path: nil, vars: vars
  end

  def external_script path: nil, vars: nil
    unless File.exist?(path) && File.readable?(path) && File.executable?(path)
      Rbcli.log.fatal "Command #{@name} expects a script to be located at: #{path}. Please make sure it exists and is both readable and executable by the current user."
      Rbcli::exit 1
    end
    require_relative 'scriptwrapper/scriptwrapper'
    @action = nil
    @script = Rbcli::ScriptWrapper.new inline: nil, path: path, vars: vars
  end

  def has_function?
    !(@action.nil? && @script.nil?)
  end

  def run! opts: nil, params: nil, args: nil, config: nil, env: nil
    unless self.has_function?
      raise Rbcli::CommandError.new "Command #{@name} does not have a function. An action, inline script, or external script must be defined."
    end
    # Rbcli.log.debug "Running command '#{@name}'", "CORE"
    @action.call(opts, params, args, config, env) unless @action.nil?
    @script.execute(opts, params, args, config, env) unless @script.nil?
  end
end

module Rbcli
  Rbcli::Warehouse.set(:commands, {})

  def self.command name, & block
    name = name.to_s.downcase
    raise Rbcli::CommandError.new "The command #{name} cannot be defined twice." if Rbcli::Warehouse.get(:commands).key? name
    command = Rbcli::Command.new(name)
    command.instance_eval(&block)
    unless command.has_function?
      raise Rbcli::CommandError.new "Command #{command.name} does not have a function. An action, inline script, or external script must be defined."
    end
    if command.default? && Rbcli::Warehouse.get(:commands).any? { |cmd| cmd.default? }
      raise Rbcli::CommandError.new "Only one command may be assigned as default"
    end
    Rbcli::Warehouse.get(:commands)[name] = command

    ## The first time a command is declared the engine gets primed to run commands
    Rbcli::Engine.register_operation(Proc.new {
      if Rbcli::Warehouse.get(:commands).empty?
        raise Rbcli::CommandError.new "No commands defined. At least one command must be declared to use Rbcli."
      end
      cmd_to_run = Rbcli::Warehouse.get(:command, :parsedopts)
      if cmd_to_run.nil?
        Rbcli.log.debug "No command specified and no default set. Skipping execution.", "CORE"
        break
      end
      Rbcli.log.debug "Running command '#{cmd_to_run.name}'", "CORE"
      cmd_to_run.run!(
        opts: Rbcli::Warehouse.get(:opts, :parsedopts),
        params: Rbcli::Warehouse.get(:params, :parsedopts),
        args: Rbcli::Warehouse.get(:args, :parsedopts),
        config: Rbcli::Warehouse.get(:config, :parsedopts) || Rbcli::ConfigOfDeath.new,
        env: Rbcli::Warehouse.get(:env, :parsedopts) || Rbcli::ConfigOfDeath.new
      )
    }, name: :run_command, priority: 100) if Rbcli::Warehouse.get(:commands).count == 1
  end
end