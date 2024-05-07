# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require_relative 'helpers/deep_assign'

class Rbcli::UserConf::Ini < Rbcli::UserConf::Backend
  include Rbcli::UserConf::Helpers::DeepAssign

  private

  def parse str
    ini = Hash.new
    nest = []
    str.lines.each_with_index do |line, i|
      line = line.split(';').first.strip
      next if line.nil? || line.empty?
      if line =~ /^\[(.*)\]$/
        nest = $1.split('.')
      elsif line.include?('=')
        key, value = line.split('=').map { |part| part.strip }
        deep_assign(ini, nest + [key], translate_value(value))
      else
        Rbcli.log.warn "Invalid #{@type} syntax found on line #{i} at '#{@path}'. Offending syntax: #{line}", "CONF"
        return Hash.new
      end
    end
    @loaded = true
    ini
  end

  def unparse hash
    ini = []
    parse_hash = Proc.new do |hsh, keys = []|
      hsh.each do |key, val|
        if !val.is_a?(Hash)
          val = ":#{val.to_s}" if val.is_a?(Symbol)
          ini << "#{key.to_s.strip} = #{val.to_s.strip}"
        else
          ini << '[' + (keys + [key]).join('.') + ']'
          parse_hash.call(val, keys + [key])
        end
      end
    end
    parse_hash.call(hash)
    ini.join("\n")
  end

  def inject_banner text, banner
    banner.lines.map { |line| "; #{line.chomp}" }.join("\n") + "\n" + text
  end
end