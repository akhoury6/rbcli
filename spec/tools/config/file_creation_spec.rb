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
      config.defaults = { foo: "bar", string: "FROM DEFAULTS", supergroup: { bar: 'baz' } }
      config.load!
      expect(File.exist?(@tmppath)).to eq(true)
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq({ foo: "bar", string: "FROM DEFAULTS", supergroup: { bar: 'baz' } })
    end

    it 'will add a banner to the missing backend file when using defaults' do
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true, banner: "Some Banner Text")
      config.defaults = { foo: "bar", string: "FROM DEFAULTS", supergroup: { bar: 'baz' } }
      config.load!
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq({ foo: "bar", string: "FROM DEFAULTS", supergroup: { bar: 'baz' } })
      expect(File.read(@tmppath)).to start_with("# Some Banner Text\n---\n")
    end

    it 'will create missing backend file using skeleton' do
      skeleton = { foo: "bar", string: "FROM SKELETON", supergroup: { bar: 'baz' } }
      skeleton_yaml = YAML.dump(skeleton.deep_stringify)
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true, skeleton: skeleton_yaml)
      expect(File.exist?(@tmppath)).to eq(false)
      config.load!
      expect(File.exist?(@tmppath)).to eq(true)
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq(skeleton)
    end

    it 'will create missing backend file using skeleton and ignoring defaults' do
      skeleton = { foo: "bar", string: "FROM SKELETON", supergroup: { bar: 'baz' } }
      skeleton_yaml = YAML.dump(skeleton.deep_stringify)
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true, skeleton: skeleton_yaml)
      expect(File.exist?(@tmppath)).to eq(false)
      config.defaults = { foo: "bar", string: "FROM DEFAULTS", supergroup: { bar: 'baz' } }
      config.load!
      expect(File.exist?(@tmppath)).to eq(true)
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq(skeleton)
    end

    it 'will add a banner to the missing backend file when using skeleton' do
      skeleton = { foo: "bar", string: "FROM SKELETON", supergroup: { bar: 'baz' } }
      skeleton_yaml = YAML.dump(skeleton.deep_stringify)
      expected_result = "# Some Banner Text" + "\n" + skeleton_yaml
      config = Rbcli::Config.new(location: @tmppath, create_if_not_exists: true, suppress_errors: true, skeleton: skeleton_yaml, banner: "Some Banner Text")
      config.load!
      expect(YAML.safe_load_file(@tmppath, symbolize_names: true, aliases: true, permitted_classes: [Symbol])).to eq(skeleton)
      expect(File.read(@tmppath)).to eq(expected_result)
    end

  end
end
