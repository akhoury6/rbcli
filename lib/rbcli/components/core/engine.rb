# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Engine
  @operations = []

  def self.register_operation operation, name: nil, priority: nil
    if @operations.select { |op| op[:priority] == priority }.count != 0
      raise Rbcli::Error.new "The Rbcli engine can not have two operations defined with the same priority: #{name}, #{@operations.select { |op| op[:priority] == priority }.join(", ")}"
    end
    @operations << { operation: operation, name: name, priority: priority }
  end

  def self.run!
    Rbcli.log.debug "The engine has been started", "ENGN"
    @operations.sort_by { |op| op[:priority] }.each do |op|
      Rbcli.log.debug "Running operation #{op[:priority]} -- #{op[:name]}", "ENGN"
      op[:operation].call
    end
    Rbcli.log.debug "The engine has been stopped", "ENGN"
  end
end

module Rbcli
  def self.go!
    Rbcli::Engine.run!
  end
end