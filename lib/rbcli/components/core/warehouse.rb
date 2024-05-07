# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Warehouse
  @data = {}

  def self.set key, value, namespace = :default
    raise Rbcli::Error.new "Namespace must be a symbol" unless namespace.is_a? Symbol
    @data[namespace] ||= {}
    @data[namespace][key] = value
  end

  def self.get key, namespace = :default
    key.nil? ? @data.dig(namespace) : @data.dig(namespace, key)
  end
end
