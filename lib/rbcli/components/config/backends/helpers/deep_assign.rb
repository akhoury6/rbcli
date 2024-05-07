# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'json'
module Rbcli::UserConf::Helpers
  module DeepAssign

    private

    def deep_assign hash, sections_arr, value
      if sections_arr.length == 1
        hash[sections_arr.first] = value
      else
        hash[sections_arr.first] ||= Hash.new
        deep_assign(hash[sections_arr.first], sections_arr[1..-1], value)
      end
    end

    def translate_value value
      if value.nil?
        nil
      elsif value.start_with?(':')
        value[1..-1].to_sym
      elsif value.downcase == 'true'
        true
      elsif value.downcase == 'false'
        false
      elsif value.to_i.to_s == value
        value.to_i
      elsif value.start_with?('[') && value.end_with?(']') # array
        begin
          JSON.parse(value)
        rescue JSON::ParserError => _err
          value
        end
      else
        begin
          Float value
        rescue => _err
          value
        end
      end
    end
  end
end