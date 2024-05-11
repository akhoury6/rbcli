# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require_relative 'helpers/deep_assign'

class Rbcli::UserConf::Env < Rbcli::UserConf::Backend
  include Rbcli::UserConf::Helpers::DeepAssign

  def initialize prefix, type
    @prefix = prefix
    @type = type.to_s.capitalize
    @loaded = false
  end

  def load defaults = nil
    vars = ENV.select { |k, v| k.match(/^#{@prefix}_.+/i) && !k.match(/^_/) }
    if @prefix.nil? && !defaults.nil? && !defaults.empty?
      lowercase_default_keys = defaults.keys.map { |k| k.downcase.to_sym }
      vars = vars.merge ENV.select { |k, v| lowercase_default_keys.include?(k.downcase.to_sym) }
    end
    vars = vars.map { |k, v| [k.split('_', 2).last.downcase, v] }.to_h
    final_vars = Hash.new
    vars.each do |key, value|
      deep_assign(final_vars, key.split('_').map { |k| k.to_sym }, translate_value(value))
    end
    @loaded = true
    final_vars
  end

  def save hash, path = []
    hash.each do |key, value|
      if !value.is_a? Hash
        ENV[([@prefix] + path + [key.upcase]).reject(&:nil?).join('_')] = (value.is_a?(Symbol) ? ':' : '') + value.to_s
      else
        save value, path + [key.upcase]
      end
    end
  end

  def save_raw text
    true
  end

  def parse_defaults defaults
    final_vars = Hash.new
    defaults.each do |key, value|
      key_parts = key.to_s.split('_').map { |k| k.downcase.to_sym }
      key_parts.delete_at(0) if key_parts.first == @prefix.to_s.downcase.to_sym
      deep_assign(final_vars, key_parts, value.is_a?(String) ? translate_value(value) : value)
    end
    final_vars
  end

  def savable?
    true
  end

  def exist?
    true
  end
end