# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper].each { |file| require file }

RSpec.describe 'Config module' do
  context "null file" do
    it "creates a null config when no location is specified" do
      config = Rbcli::Config.new
      expect(config.type).to eq(:null)
    end

    it "creates a null config when location is nil" do
      config = Rbcli::Config.new(location: nil)
      expect(config.type).to eq(:null)
    end

    it "creates a null config when location is :null" do
      config = Rbcli::Config.new(location: :null)
      expect(config.type).to eq(:null)
    end

    it "creates a null config when type is :null" do
      config = Rbcli::Config.new(type: :null)
      expect(config.type).to eq(:null)
    end

    it "creates a null config when the file is invalid but suppress_errors is true" do
      config = Rbcli::Config.new(location: '/invalid/file/path', suppress_errors: true)
      expect(config.type).to eq(:null)
    end

    it "exits when file is invalid but suppress_errors is false" do
      _config = Rbcli::Config.new(location: '/invalid/file/path', suppress_errors: false)
      expect(Rbcli.exit_code).not_to be_nil
    end

    it "evaluates as an empty hash" do
      config = Rbcli::Config.new
      expect(config).to be_a(Hash)
      expect(config).to eq(Hash.new)
    end

    it "succeeds loading but makes no changes" do
      first_config = Rbcli::Config.new
      second_config = Rbcli::Config.new
      first_config.load!
      expect(first_config).to eq(second_config)
    end

    it "fails and displays a warning when a config save is attempted" do
      config = Rbcli::Config.new
      result = config.save!
      expect(result).to eq(false)
      expect(Rbcli.logstream.string).to include("WARN")
    end

    it "fails and does not warn when a config save is attempted if suppress_errors is true" do
      config = Rbcli::Config.new(suppress_errors: true)
      result = config.save!
      expect(result).to eq(false)
      expect(Rbcli.logstream.string).not_to include("WARN")
    end

    it "validates against a schema correctly" do
      config = Rbcli::Config.new
      config[:foo] = :bar
      expect(config.validate!).to be(true)
    end

    it "merges missing defaults on load" do
      config = Rbcli::Config.new
      config.defaults = { foo: "bar", string: "default_string", supergroup: { bar: 'baz' } }
      expect(config.defaults).to eq({ foo: "bar", string: "default_string", supergroup: { bar: 'baz' } })
      config.load!
      expect(config).to eq({ foo: "bar", string: 'default_string', supergroup: { bar: 'baz' } })
    end

    it "does not crash when asked to annotate banner" do
      config = Rbcli::Config.new
      config.set_banner @banner
      config[:foo] = :bar
      config.save!
      config.annotate!
    end
  end
end