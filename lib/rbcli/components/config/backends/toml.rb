# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'toml'

class Rbcli::UserConf::Toml < Rbcli::UserConf::Backend
  private

  def parse str
    begin
      parsed_str = TOML.load(str).deep_symbolize!
    rescue => e
      raise Rbcli::ParseError.new "Invalid #{@type} syntax found at '#{@path}': #{e.message}"
    else
      @loaded = true
      parsed_str
    end
  end

  def unparse hash
    TOML::Generator.new(hash).body
  end

  def inject_banner text, banner
    banner.lines.map { |line| "# #{line.chomp}" }.join("\n") + "\n" + text
  end
end

class Symbol
  def to_toml(path = "")
    '"' + self.to_s.sub(/^:/, '') + '"'
  end
end