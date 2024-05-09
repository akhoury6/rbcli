# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'spec_helper'

RSpec.describe 'Config module' do
  context 'defaults' do
    it "allows setting a single default" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar')
      expect(config.defaults).to eq({foo: 'bar'})
    end

    it "allows setting single default values without affecting the data" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar')
      expect(config).to eq({})
    end

    it "allows setting all defaults using a hash" do
      config = Rbcli::Config.new
      config.defaults = { foo: 'bar', bar: { baz: 'zinga' } }
      expect(config.defaults).to eq({ foo: 'bar', bar: { baz: 'zinga' } })
    end

    it "allows setting all default values without affecting the data" do
      config = Rbcli::Config.new
      config.defaults = { foo: 'bar', bar: { baz: 'zinga' } }
      expect(config).to eq({})
    end

    it "assigns single defaults on load" do
      config = Rbcli::Config.new
      config.add_default(:foo, default: 'bar')
      expect(config.defaults).to eq({foo: 'bar'})
      expect(config).to eq({})
      config.load!
      expect(config).to eq({foo: 'bar'})
    end

    it "assigns all defaults on load" do
      config = Rbcli::Config.new
      config.defaults = { foo: 'bar', bar: { baz: 'zinga' } }
      expect(config.defaults).to eq({ foo: 'bar', bar: { baz: 'zinga' } })
      expect(config).to eq({})
      config.load!
      expect(config).to eq({ foo: 'bar', bar: { baz: 'zinga' } })
    end
  end
end