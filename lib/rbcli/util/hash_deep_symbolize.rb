# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################

##
# Functions to convert hash keys to all symbols or all strings
##
class Hash
  def deep_symbolize! hsh = nil
    hsh ||= self
    hsh.keys.each do |k|
      if k.is_a? String
        hsh[k.to_sym] = hsh[k]
        hsh.delete k
      end
      deep_symbolize! hsh[k.to_sym] if hsh[k.to_sym].is_a? Hash
    end
    hsh
  end

  def deep_stringify! hsh = nil
    hsh ||= self
    hsh.keys.each do |k|
      if k.is_a? Symbol
        hsh[k.to_s] = hsh[k]
        hsh.delete k
      end
      deep_stringify! hsh[k.to_s] if hsh[k.to_s].is_a? Hash
    end
    hsh
  end
end