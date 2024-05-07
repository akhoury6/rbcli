# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'rubygems'

module Rbcli::Configurate::UpdateChecker
  include Rbcli::Configurable

  def self.gem gem, force_update: false, message: nil
    raise Rbcli::ConfigurateError.new "Only one update checker can be specified" if Rbcli::Warehouse.get(:updatecheck)
    raise Rbcli::ConfigurateError.new "Gem name provided for update checker is not valid" if gem.nil? || !gem.is_a?(String) || gem.empty?
    raise Rbcli::ConfigurateError.new "Force_update must be a boolean value" unless force_update.is_a?(TrueClass) || force_update.is_a?(FalseClass)
    raise Rbcli::ConfigurateError.new "Version string must be set in Rbcli::Configurate.cli to configure update checks" if Rbcli::Warehouse.get(:version, :appinfo).nil?
    begin
      Gem::Version.new(Rbcli::Warehouse.get(:version, :appinfo))
    rescue ArgumentError => e
      raise Rbcli::ConfigurateError.new e.message
    end
    require File.join(RBCLI_LIBDIR, 'components', 'updatechecker', 'gem_checker')
    Rbcli::Warehouse.set(:updatecheck, Rbcli::UpdateChecker::GemChecker.new(gem, force_update, message))
    Rbcli::Engine.register_operation Rbcli::Warehouse.get(:updatecheck).method(:check_for_updates), name: :updatechecke_by_gem, priority: 60
    Rbcli.log.debug "Registered update checker by gem for gem: #{gem}", "UPDT"
  end

  def self.github github_repo, access_token: nil, enterprise_hostname: nil, force_update: false, message: nil
    raise Rbcli::ConfigurateError.new "Only one update checker can be specified" if Rbcli::Warehouse.get(:updatecheck)
    raise Rbcli::ConfigurateError.new "Repo name provided for update checker is not valid" if github_repo.nil? || !github_repo.is_a?(String) || github_repo.empty?
    raise Rbcli::ConfigurateError.new "Force_update must be a boolean value" unless force_update.is_a?(TrueClass) || force_update.is_a?(FalseClass)
    raise Rbcli::ConfigurateError.new "Version string must be set in Rbcli::Configurate.cli to configure update checks" if Rbcli::Warehouse.get(:version, :appinfo).nil?
    begin
      Gem::Version.new(Rbcli::Warehouse.get(:version, :appinfo))
    rescue ArgumentError => e
      raise Rbcli::ConfigurateError.new e.message
    end
    require File.join(RBCLI_LIBDIR, 'components', 'updatechecker', 'github_checker')
    Rbcli::Warehouse.set(:updatecheck, Rbcli::UpdateChecker::GithubChecker.new(github_repo, access_token, enterprise_hostname, force_update, message))
    Rbcli::Engine.register_operation Rbcli::Warehouse.get(:updatecheck).method(:check_for_updates), name: :updatechecke_by_github, priority: 60
    Rbcli.log.debug "Registered update checker by github repo for github_repo: #{github_repo}", "UPDT"
  end
end