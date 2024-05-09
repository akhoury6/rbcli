##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require_relative 'optimist/optimist'
require 'stringio'
module Rbcli::Parser
  @parser = Optimist::Parser.new

  def self.add_opt * args
    Rbcli.log.debug "Set top-level opt argument: #{args}", "OPTS"
    Rbcli::Warehouse.set(:opts, [], :unparsedopts) if Rbcli::Warehouse.get(:opts, :unparsedopts).nil?
    Rbcli::Warehouse.get(:opts, :unparsedopts) << args
  end

  def self.parse
    appinfo = Rbcli::Warehouse.get(nil, :appinfo) || {}
    bannerstr = "#{appinfo[:appname] || EXECUTABLE}" + (appinfo[:version].nil? ? "\n" : " version: #{appinfo[:version]}\n")
    unless appinfo[:copyright_year].nil? && appinfo[:author].nil?
      bannerstr += "Copyright (C) #{appinfo[:copyright_year]} " unless appinfo[:copyright_year].nil?
      bannerstr += "by #{appinfo[:author]}" if appinfo[:author].is_a? String
      bannerstr += "by #{appinfo[:author].join(', ')}" if appinfo[:author].is_a? Array
      bannerstr += " <#{appinfo[:email]}>" unless appinfo[:author].nil? || appinfo[:email].nil?
      bannerstr += "\n"
    end
    unless appinfo[:compatibility].nil? || appinfo[:compatibility].empty?
      bannerstr += "Compatiblity: "
      if appinfo[:compatibility].length == 2
        bannerstr += appinfo[:compatibility].join(' and ') + "\n"
      else
        bannerstr += appinfo[:compatibility][0..-2].join(', ') + ', and ' + appinfo[:compatibility][-1] + "\n"
      end
    end
    bannerstr += "License: #{appinfo[:license]}\n" unless appinfo[:license].nil?
    bannerstr += "\n"
    bannerstr += appinfo[:helptext].chomp + "\n\n" unless appinfo[:helptext].nil?
    bannerstr += "Usage:\n  #{EXECUTABLE} [options] command [parameters]\n\n"

    non_default_commands = Rbcli::Warehouse.get(:commands).select { |_name, cmd| !cmd.default? }
    if non_default_commands.count > 0
      bannerstr += "For more information on individual commands, run `#{EXECUTABLE} <command> -h`\n\n"
      bannerstr += "Commands:\n"
      leftcol_width = non_default_commands.keys.map(&:length).max + 6
      bannerstr += non_default_commands.map { |name, cmd| "  " + name + (" " * (leftcol_width - name.length)) + (cmd.description || '') }.join("\n")
    end

    @parser.synopsis bannerstr
    (Rbcli::Warehouse.get(:opts, :unparsedopts) || []).each { |args| @parser.opt *args }
    @parser.stop_on(non_default_commands.select { |_name, cmd| !cmd.default? }.keys)

    begin
      opts = @parser.parse
      Rbcli::Warehouse.set(:opts, opts, :parsedopts)
      Rbcli.log.debug "Found options: #{opts}", "OPTS"
    rescue Optimist::CommandlineError => e
      Rbcli.log.fatal e.message
      Rbcli.log.fatal "Run `#{EXECUTABLE} -h` for more information"
      Rbcli::exit 1
    rescue Optimist::HelpNeeded
      stream = StringIO.new
      @parser.educate(stream)
      Rbcli.log.info stream.string, "OPTS"
      Rbcli::exit 0
    rescue Optimist::VersionNeeded
      Rbcli.log.info bannerstr.lines.first.chomp, "OPTS"
      Rbcli::exit 0
    end
  end

  def self.parse_command
    cmd = { name: nil, command: nil, params: {}, args: [] }
    cmd[:name] = !ARGV.first.nil? && !ARGV.first.start_with?('-') ? ARGV.shift.downcase : nil
    default_command = Rbcli::Warehouse.get(:commands).values.select { |c| c.default? }.first
    if cmd[:name].nil? && default_command.nil?
      # CLI: Not given, Default: Not Set -- Educate
      Rbcli.log.debug "Command not given, and no default command set. Displaying help.", "OPTS"
      stream = StringIO.new
      @parser.educate(stream)
      Rbcli.log.info stream.string, "OPTS"
      Rbcli::exit 0
    elsif cmd[:name].nil?
      # CLI: Not given, Default: Set -- Use Default
      cmd[:command] = default_command
      Rbcli.log.debug "Using default command: '#{cmd[:command].name}'", "OPTS"
    elsif Rbcli::Warehouse.get(:commands).key?(cmd[:name])
      # CLI: Given, Default: Not Set, Command: Found -- Use Command
      cmd[:command] = Rbcli::Warehouse.get(:commands)[cmd[:name]]
      Rbcli.log.debug "Using command: '#{cmd[:command].name}'", "OPTS"
    elsif !default_command.nil?
      # CLI: Given, Default: Set, Command: Not Found -- Pass it as an argument
      cmd[:args] << cmd[:name]
      while !ARGV.first.nil? && !ARGV.first.start_with?('-')
        cmd[:args] << ARGV.shift
      end
      cmd[:command] = default_command
      Rbcli.log.debug "Using default command: '#{cmd[:command].name}' with args: #{cmd[:args]}", "OPTS"
    else
      # CLI: Given, Default: Not Set, Command: Not Found -- Fail
      Rbcli.log.fatal "Unknown command: '#{cmd[:name]}'", "OPTS"
      Rbcli.log.fatal "Run `#{EXECUTABLE} -h` for more information", "OPTS"
      Rbcli::exit 1
    end
    Rbcli::Warehouse.set(:command, cmd[:command], :parsedopts)

    parser = Optimist::Parser.new

    # We set the educate text
    appinfo = Rbcli::Warehouse.get(nil, :appinfo) || {}
    bannerstr = "#{appinfo[:appname] || EXECUTABLE}" + (appinfo[:version].nil? ? "\n" : " version: #{appinfo[:version]}\n")
    bannerstr += "\n"
    bannerstr += "Command: #{cmd[:command].name}\n\n"
    bannerstr += cmd[:command].helptext.chomp + "\n\n" unless cmd[:command].helptext.nil?
    bannerstr += "Usage:\n  #{EXECUTABLE} #{cmd[:command].name} #{cmd[:command].usage.chomp}" unless cmd[:command].usage.nil?
    parser.synopsis(bannerstr)

    # Then we add the options from the command
    cmd[:command].params.each { |param| parser.opt *param }

    begin
      cmd[:params] = parser.parse
      Rbcli::Warehouse.set(:params, cmd[:params], :parsedopts)
      Rbcli.log.debug "Found parameters for command '#{cmd[:command].name}': #{cmd[:params]}", "OPTS"
    rescue Optimist::CommandlineError => e
      Rbcli.log.fatal e.message
      Rbcli.log.fatal "Run `#{EXECUTABLE} #{cmd[:command].name} -h` for more information", "OPTS"
      Rbcli::exit 1
    rescue Optimist::HelpNeeded
      stream = StringIO.new
      parser.educate(stream)
      Rbcli.log.info stream.string, "OPTS"
      Rbcli::exit 0
    end

    cmd[:args].concat(ARGV)
    Rbcli::Warehouse.set(:args, cmd[:args], :parsedopts)
    ARGV.clear
  end

  def self.prompt_for_missing
    Rbcli::Warehouse.get(:command, :parsedopts).params
                    .select { |args| !args[2].nil? && !args[2].empty? && args[2][:prompt].is_a?(String) }
                    .reject { |args| Rbcli::Warehouse.get(:params, :parsedopts).key?((args[0].to_s + '_given').to_sym) }
                    .map { |args| { name: args[0].to_sym, prompt: args[2][:prompt], default: args[2][:default], type: args[2][:type].nil? ? nil : args[2][:type].to_s.chomp('s').to_sym } }
                    .each do |opt|
      prompt_string = opt[:prompt].strip
      param_value = Rbcli::Warehouse.get(:params, :parsedopts)[opt[:name]]
      if param_value.is_a?(TrueClass) || param_value.is_a?(FalseClass)
        prompt_string += ' (' + (param_value ? 'Y' : 'y') + '/' + (param_value ? 'n' : 'N') + ')'
        opt[:default] = param_value if opt[:default].nil?
      elsif !opt[:default].nil?
        prompt_string != " (default: #{opt[:default]})"
      end
      prompt_string += ':' unless %w(. ? ! :).include?(opt[:prompt][-1])
      prompt_string += ' '

      answer = nil
      while answer.nil?
        Rbcli.log.info prompt_string, "OPTS"
        answer = gets.chomp
        if [nil, :flag, :bool, :boolean, :trueclass, :falseclass].include?(opt[:type])
          answer = { 'y' => true, 'n' => false, '' => opt[:default] }[(answer[0] || '').downcase]
          next
        end
        if answer == ''
          Rbcli.log.debug "Using default value of #{opt[:default]} for --#{opt[:name].to_s}", "OPTS"
          answer = opt[:default]
        end
        begin
          parser = Optimist::Parser.new
          parser.opt(opt[:name], '', type: opt[:type])
          newopts = parser.parse ["--#{opt[:name].to_s}", answer]
        rescue Optimist::CommandlineError, Optimist::HelpNeeded, Optimist::VersionNeeded
          Rbcli.log.debug "Invalid answer for type #{opt[:type]}", "OPTS"
          answer = nil
        else
          answer = newopts[opt[:name]]
        end
      end
      Rbcli::Warehouse.get(:params, :parsedopts)[opt[:name]] = answer
    end
  end

  Rbcli::Engine.register_operation self.method(:parse), name: :cliopts_top_parse, priority: 10
  Rbcli::Engine.register_operation self.method(:parse_command), name: :cliopts_command_parse, priority: 20
  Rbcli::Engine.register_operation self.method(:prompt_for_missing), name: :cliopts_prompts, priority: 30
end