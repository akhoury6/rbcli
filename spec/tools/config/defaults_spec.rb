# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'spec_helper'

RSpec.describe 'Config module' do
  context 'defaults' do
    it "allows setting default values without affecting the data" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar')
      expect(config).to eq({})
    end

    it "can find defaults with inspect" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar')
      expect(config.inspect).to include(":foo").and include('"bar"')
    end

    it "can get provide default values back when asked" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar')
      expect(config.defaults).to eq({ foo: 'bar' })
    end

    it "can create default groups by string and resulting group becomes a symbol" do
      config = Rbcli::Config.new
      config.add_group("foobar")
      expect(config.defaults).to eq({ foobar: {} })
    end

    it "can create default groups by symbol" do
      config = Rbcli::Config.new
      config.add_group(:foobar)
      expect(config.defaults).to eq({ foobar: {} })
    end

    it "can create default nested groups by a path array of mixed strings and symbols" do
      config = Rbcli::Config.new
      config.add_group([:foo, :bar, :baz, 'zing', :bing, 'bop', :boop])
      expect(config.defaults).to eq({ foo: { bar: { baz: { zing: { bing: { bop: { boop: {} } } } } } } })
    end

    it "can store hidden helptext for a group" do
      config = Rbcli::Config.new
      config.add_group(:foo, helptext: "Some helpful text")
      expect(config.defaults).to eq({ foo: {} })
      expect(config.inspect).to include("Some helpful text")
    end

    it "can create a default in a nested group" do
      config = Rbcli::Config.new
      config.add_group([:foo, :bar, :baz, :zing, :bing, :bop, :boop])
      config.add_default(:foo, default: 'bar', group_path: [:foo, :bar, :baz, :zing, :bing, :bop, :boop])
      expect(config.defaults).to eq({ foo: { bar: { baz: { zing: { bing: { bop: { boop: { foo: 'bar' } } } } } } } })
    end

    it "can automatically create group path for default value" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar', group_path: [:foo, :bar, :baz, :zing, :bing, :bop, :boop])
      expect(config.defaults).to eq({ foo: { bar: { baz: { zing: { bing: { bop: { boop: { foo: 'bar' } } } } } } } })
    end

    it "assigns defaults on load" do
      config = Rbcli::Config.new
      config.add_group :supergroup, helptext: "Some info"
      config.add_default :foo, helptext: "this is a default setting", default: 'bar'
      config.add_group [:supergroup, :dupergroup], helptext: "More info"
      config.add_default :bar, group_path: [:supergroup, :dupergroup], helptext: "another option", default: 'baz'
      config.add_group :fubergroup, helptext: "Last group"
      config.add_default :baz, group_path: :fubergroup, helptext: "some helptext", default: 'zinga'
      expect(config.defaults).to eq({ foo: "bar", supergroup: { dupergroup: { bar: "baz" } }, fubergroup: { baz: "zinga" } })
      expect(config).to eq({})
      config.load!
      expect(config).to eq({ foo: "bar", supergroup: { dupergroup: { bar: "baz" } }, fubergroup: { baz: "zinga" } })
    end
  end
end