# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'json'

class Rbcli::UserConf::Json < Rbcli::UserConf::Backend
  private

  def parse str
    begin
      parsed_str = JSON.parse(str)
    rescue JSON::JSONError => e
      raise Rbcli::ParseError.new "Invalid #{@type} syntax found at '#{@path}': #{e.message}"
    else
      @loaded = true
      parsed_str
    end
  end

  def unparse hash
    JSON.pretty_generate(hash)
  end

  def inject_banner text, _banner
    text
  end
end