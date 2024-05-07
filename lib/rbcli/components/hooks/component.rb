# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate::Hooks
  include Rbcli::Configurable

  def self.pre_execute & block
    Rbcli::Warehouse.set(:pre_execute, block, :hooks)
    Rbcli.log.debug "Registered pre_execute hook", "HOOK"
    Rbcli::Engine.register_operation(Proc.new do
      Rbcli::Warehouse.get(:pre_execute, :hooks).call(
        Rbcli::Warehouse.get(:opts, :parsedopts),
        Rbcli::Warehouse.get(:params, :parsedopts),
        Rbcli::Warehouse.get(:args, :parsedopts),
        Rbcli::Warehouse.get(:config, :parsedopts) || Rbcli::ConfigOfDeath.new,
        Rbcli::Warehouse.get(:env, :parsedopts) || Rbcli::ConfigOfDeath.new
      )
    end, name: :pre_execute_hook, priority: 90)
  end

  def self.post_execute & block
    Rbcli::Warehouse.set(:post_execute, block, :hooks)
    Rbcli.log.debug "Registered post_execute hook", "HOOK"
    Rbcli::Engine.register_operation(Proc.new do
      Rbcli::Warehouse.get(:post_execute, :hooks).call(
        Rbcli::Warehouse.get(:opts, :parsedopts),
        Rbcli::Warehouse.get(:params, :parsedopts),
        Rbcli::Warehouse.get(:args, :parsedopts),
        Rbcli::Warehouse.get(:config, :parsedopts) || Rbcli::ConfigOfDeath.new,
        Rbcli::Warehouse.get(:env, :parsedopts) || Rbcli::ConfigOfDeath.new
      )
    end, name: :post_execute_hook, priority: 110)
  end
end