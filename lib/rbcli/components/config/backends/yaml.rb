# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'yaml'

class Rbcli::UserConf::Yaml < Rbcli::UserConf::Backend
  private

  def parse str
    begin
      parsed_str = YAML.safe_load(str, symbolize_names: true, aliases: true, permitted_classes: [Symbol])
    rescue Psych::SyntaxError, Psych::DisallowedClass => e
      Rbcli.log.warn "Invalid #{@type} syntax found at '#{@path}'", "CONF"
      Rbcli.log.warn e.message, "CONF"
      Hash.new
    else
      @loaded = true
      parsed_str
    end
  end

  def unparse hash
    hash.to_yaml
  end

  def inject_banner text, banner
    banner.lines.map { |line| "# #{line.chomp}" }.join("\n") + "\n" + text
  end
end