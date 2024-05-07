# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper].each { |file| require file }

RSpec.describe 'Config module' do
  context "null file" do
    it "creates a null config when location is :null" do
      config = Rbcli::Config.new(location: :null)
      expect(config.type).to eq(:null)
    end

    it "detects empty null config based on parameter" do
      config = Rbcli::Config.new(location: :null, type: :null)
      expect(config.type).to eq(:null)
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

    it "skips saving changes when no changes are made" do
      config = Rbcli::Config.new
      config.save!
      expect(Rbcli.logstream.string).to include("No changes detected")
    end

    it "pretends to save when changes detected" do
      config = Rbcli::Config.new
      config[:foo] = :bar
      config.save!
      expect(config.save!).to be(config)
    end

    it "validates against a schema correctly" do
      config = Rbcli::Config.new
      config[:foo] = :bar
      expect(config.validate!).to be(true)
    end

    it "sets all defaults on load" do
      config = Rbcli::Config.new
      config.add_default :foo, helptext: "this is a default setting", default: 'bar'
      config.add_group :supergroup, helptext: "Some info"
      config.add_default :bar, group_path: :supergroup, helptext: "another option", default: 'baz'
      config.add_default :string, default: 'default_string'
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