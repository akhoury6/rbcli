# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w(logger json colorize).each { |req| require req }
require_relative 'lolcat/lol'

# noinspection RubyClassVariableUsageInspection
class Rbcli::Logger
  EXECUTABLE ||= File.basename($0).gsub(/\.[^.]+$/, '')
  @max_prog_len = 0
  @original_formatter = Logger::Formatter.new
  @@formatters = {
    display: Proc.new { |severity, _datetime, _progname, msg|
      severity == 'INFO' ? msg : "#{colorlevel(severity)}#{(' ' * (5 - severity.length))} || #{msg}"
    },
    simple: Proc.new { |severity, _datetime, progname, msg|
      @max_prog_len = (@max_prog_len > progname.length) ? @max_prog_len : progname.length unless progname.nil?
      "#{colorlevel(severity)}#{(' ' * (5 - severity.length))} || #{progname || (' ' * @max_prog_len)} || #{msg}"
    },
    full: Proc.new { |severity, datetime, progname, msg|
      @max_prog_len = (@max_prog_len > progname.length) ? @max_prog_len : progname.length unless progname.nil?
      "#{datetime.strftime("%Y-%m-%d %H:%M:%S.%6N")} || #{EXECUTABLE} || #{progname || (' ' * @max_prog_len)} || #{colorlevel(severity)}#{(' ' * (5 - severity.length))} || #{msg}"
    },
    apache: Proc.new { |severity, datetime, progname, msg|
      "[#{datetime.strftime("%a %b %d %H:%M:%S.%6N %Y")}] [#{severity}] [#{EXECUTABLE}] [#{progname}] #{msg.gsub(/\e\[([;\d]+)?m/, '')}"
    },
    json: Proc.new { |severity, datetime, progname, msg|
      { timestamp: datetime.strftime("%Y-%m-%d %H:%M:%S.%N"), severity: severity, application: EXECUTABLE, module: progname, message: msg.gsub(/\e\[([;\d]+)?m/, '') }.to_json
    },
    ruby: Proc.new { |severity, datetime, progname, msg|
      @original_formatter.call(severity, datetime, progname, msg).chomp
    },
    lolcat: Proc.new { |severity, _datetime, _progname, msg|
      "#{colorlevel(severity)}#{(' ' * (5 - severity.length))} || #{Lol.makestr(msg, { spread: 3, freq: 0.1, slope: 4, invert: false, truecolor: true })}"
    }
  }

  def self.formats
    @@formatters.keys
  end

  def initialize(target: STDOUT, level: :info, format: :display)
    self.target(target)
    self.level(level)
    self.format(format)
  end

  def target target
    @logger = Logger.new(target_select(target))
    @logger.formatter = Proc.new { |severity, datetime, progname, msg|
      msg = msg.to_s unless msg.is_a?(String)
      msg.lines.map { |line| @@formatters[@format].call(severity, datetime, progname, line.chomp) }.join("\n") + "\n"
    }
  end

  def level slug = nil
    return @logger.level if slug.nil?
    @logger.level = logger_level(slug)
  end

  def format slug = nil
    return @format if slug.nil?
    @format = slug if @@formatters.key?(slug)
  end

  def add_format slug, prok
    @@formatters[slug] = prok
  end

  def add level, message, progname = nil, &block
    @logger.add(logger_level(level), message, progname, &block)
  end

  def debug message, progname = nil, &block
    self.add(Logger::DEBUG, message, progname, &block)
  end

  def info message, progname = nil, &block
    self.add(Logger::INFO, message, progname, &block)
  end

  def warn message, progname = nil, &block
    self.add(Logger::WARN, message, progname, &block)
  end

  def error message, progname = nil, &block
    self.add(Logger::ERROR, message, progname, &block)
  end

  def fatal message, progname = nil, &block
    self.add(Logger::FATAL, message, progname, &block)
  end

  def unknown message, progname = nil, &block
    self.add(Logger::UNKNOWN, message, progname, &block)
  end

  %w(debug, info, warn, error, fatal, unknown).each do |l|
    self.define_method(l.to_sym) do |message, progname = nil, &block|
      self.send(:add, l.to_sym, message, progname, &block)
    end
  end

  private

  def self.colorlevel level
    level.colorize(
      {
        'DEBUG' => :blue,
        'INFO' => :green,
        'WARN' => :yellow,
        'ERROR' => :red,
        'FATAL' => { color: :light_red, mode: :bold },
        'ANY' => :cyan
      }[level.to_s.upcase] || :default)
  end

  def target_select slug
    {
      stdout: STDOUT,
      stderr: STDERR
    }[slug] || slug
  end

  def logger_level slug
    if slug.is_a?(String) || slug.is_a?(Symbol)
      {
        debug: Logger::DEBUG,
        info: Logger::INFO,
        warn: Logger::WARN,
        error: Logger::ERROR,
        fatal: Logger::FATAL,
        unknown: Logger::UNKNOWN,
        any: -1
      }[slug.to_s.downcase.to_sym] || Logger::UNKNOWN
    else
      slug
    end
  end
end

module Rbcli
  @logger = nil

  def self.start_logger target: STDOUT, level: :info, format: :display
    @logger = Rbcli::Logger.new(target: target, level: level, format: format)
  end

  def self.log
    self.start_logger if @logger.nil?
    @logger
  end
end
