# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'spec_helper'
require 'fileutils'
require 'yaml'

RSpec.describe 'Config module' do
  context 'auto file creation' do
    before(:example) do
      @tmpdir = Dir.mktmpdir
      @tmppath = File.join(@tmpdir, 'config.yaml')
    end

    after(:example) do
      FileUtils.remove_entry(@tmpdir, force: true)
    end

    it 'does not create missing backend file by default' do
      config = Rbcli::Config.new(location: @tmppath, suppress_errors: true)
      expect(File.exist?(@tmppath)).to eq(false)
      config.load!
      expect(File.exist?(@tmppath)).to eq(false)
    end

    it 'does not create missing backend file when flag is set to false' do
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: false, suppress_errors: true)
      expect(File.exist?(@tmppath)).to eq(false)
      config.load!
      expect(File.exist?(@tmppath)).to eq(false)
    end

    it 'will create missing backend file if specified' do
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true)
      expect(File.exist?(@tmppath)).to eq(false)
      config.load!
      expect(File.exist?(@tmppath)).to eq(true)
    end

    it 'will create empty but valid file when no defaults set' do
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true)
      expect(File.exist?(@tmppath)).to eq(false)
      config.load!
      expect(File.read(@tmppath)).to start_with("---")
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq({})
    end

    it 'will create missing backend file with defaults' do
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true)
      expect(File.exist?(@tmppath)).to eq(false)
      config.defaults = { foo: "bar", string: "default_string", supergroup: { bar: 'baz' } }
      config.load!
      expect(File.exist?(@tmppath)).to eq(true)
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq({ foo: "bar", string: "default_string", supergroup: { bar: 'baz' } })
    end

  end
end
