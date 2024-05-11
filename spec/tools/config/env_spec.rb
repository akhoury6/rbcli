# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper].each { |file| require file }

RSpec.describe 'Config module' do
  context "env backend" do
    after(:example) do
      ENV.select { |k, v| k.match /RBCLI/i }.keys.each { |key| ENV.delete key }
    end

    it "creates new env config when type is defined" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      expect(config.type).to eq(:env)
    end

    it "can load environment variables with the correct prefix" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_FOO'] = 'bar'
      config.load!
      expect(config).to eq({ foo: 'bar' })
    end

    it "is case insensitive" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_FOO'] = 'bar'
      ENV['RBCLI_bar'] = 'baz'
      ENV['rbcli_BAZ'] = 'zinga'
      ENV['rbcli_zing'] = 'ger'
      config.load!
      expect(config).to eq({ foo: 'bar', bar: 'baz', baz: 'zinga', zing: 'ger' })
    end

    it "does not match incomplete variable names" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_'] = 'foo'
      ENV['RBCLI'] = 'bar'
      config.load!
      expect(config).to eq({})
    end

    it "uses default values when envvars are not available" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      config.add_default(:foo, 'bar')
      expect(config).to eq({})
      config.load!
      expect(config).to eq({ foo: 'bar' })
    end

    it "loads environment variables using recursive naming" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_FOO_BAR_BAZ'] = 'zinga'
      config.load!
      expect(config).to eq({ foo: { bar: { baz: 'zinga' } } })
    end

    it "saves data to environment variables" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      config[:foo] = 'bar'
      config.save!
      expect(ENV.select { |k, v| k.match /RBCLI/i }).to eq({ 'RBCLI_FOO' => 'bar' })
    end

    it "saves data to environment variables using recursive naming" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      config[:foo] = { bar: { baz: 'zinga' } }
      config.save!
      expect(ENV.select { |k, v| k.match /RBCLI/i }).to eq({ 'RBCLI_FOO_BAR_BAZ' => 'zinga' })
    end

    it "merges nested hash values" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_HASH_VALUE'] = 'first'
      ENV['RBCLI_HASH_OTHER'] = 'second'
      config.load!

      expect(config[:hash]).to be_a(Hash)
      expect(config[:hash]).to eq({ value: 'first', other: 'second' })
    end

    it "loads all variable types as expected" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_STRING'] = 'string'
      ENV['RBCLI_SYMBOL'] = ':symbol'
      ENV['RBCLI_INTEGER'] = '1234'
      ENV['RBCLI_FLOAT'] = '12.34'
      ENV['RBCLI_BOOLEANTRUE'] = 'true'
      ENV['RBCLI_BOOLEANFALSE'] = 'false'
      ENV['RBCLI_ARRAY'] = '[1, 2, 3, [4, 5 ,6]]'
      ENV['RBCLI_HASH_NEST'] = 'nested'

      config.load!
      expect(config[:string]).to be_a(String)
      expect(config[:symbol]).to be_a(Symbol)
      expect(config[:integer]).to be_a(Integer)
      expect(config[:float]).to be_a(Float)
      expect(config[:booleantrue]).to be_a(TrueClass)
      expect(config[:booleanfalse]).to be_a(FalseClass)
      expect(config[:array]).to be_a(Array)
      expect(config[:hash]).to be_a(Hash)
    end

    it "saves all variable types as expected" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      ENV['RBCLI_STRING'] = 'string'
      ENV['RBCLI_SYMBOL'] = ':symbol'
      ENV['RBCLI_INTEGER'] = '1234'
      ENV['RBCLI_FLOAT'] = '12.34'
      ENV['RBCLI_BOOLEANTRUE'] = 'true'
      ENV['RBCLI_BOOLEANFALSE'] = 'false'
      ENV['RBCLI_ARRAY'] = '[1, 2, 3, [4, 5 ,6]]'
      ENV['RBCLI_HASH_NEST'] = 'nested'

      config.load!
      expect(config[:string]).to eq('string')
      expect(config[:symbol]).to eq(:symbol)
      expect(config[:integer]).to eq(1234)
      expect(config[:float]).to eq(12.34)
      expect(config[:booleantrue]).to eq(true)
      expect(config[:booleanfalse]).to eq(false)
      expect(config[:array]).to eq([1, 2, 3, [4, 5, 6]])
      expect(config[:hash]).to eq({ nest: 'nested' })
    end

    it "creates new env config when given no prefix" do
      config = Rbcli::Config.new(type: :env)
      expect(config.type).to eq(:env)
    end

    it "loads no environment variables when given no prefix" do
      config = Rbcli::Config.new(type: :env)
      ENV['RBCLI_FOO'] = 'bar'
      config.load!
      expect(config).to eq({})
    end

    it "saves variables to the environment when given no prefix" do
      config = Rbcli::Config.new(type: :env)
      config[:foobar_barbaz_bazinga] = 'bar'
      config[:foo] = { bar: { baz: 'zinga' } }
      config.save!
      expect(ENV.keys).to include('FOOBAR_BARBAZ_BAZINGA')
      expect(ENV['FOOBAR_BARBAZ_BAZINGA']).to eq('bar')
      expect(ENV.keys).to include('FOO_BAR_BAZ')
      expect(ENV['FOO_BAR_BAZ']).to eq('zinga')
    end

    it "overrides envvars correctly when specified as a default and given a prefix" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      config.add_default(:foo, 'foo')
      ENV['RBCLI_FOO'] = 'baz'
      ENV['FOO'] = 'not this one'
      config.load!
      expect(config).to eq({ foo: 'baz' })
    end

    it "overrides envvars correctly when specified as a default and not given a prefix" do
      config = Rbcli::Config.new(type: :env)
      config.add_default(:foo, 'bar')
      ENV['FOO'] = 'baz'
      config.load!
      expect(config).to eq({ foo: 'baz' })
    end

    it "overrides defaults with non-string values and non-symbol keys" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      config.add_default('TERM_WIDTH', 320)
      config.add_default('TERM_HEIGHT', 240)
      ENV['RBCLI_TERM_WIDTH'] = '640'
      ENV['RBCLI_TERM_HEIGHT'] = '480'
      config.load!
      expect(config).to eq({ term: { width: 640, height: 480 } })
    end

    it "overrides defaults when the prefix is repeated in the default setting" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env)
      config.add_default('RBCLI_FOO', 'bar')
      ENV['RBCLI_FOO'] = 'baz'
      config.load!
      expect(config).to eq({ foo: 'baz' })
    end

    it "does not crash when asked to annotate banner" do
      config = Rbcli::Config.new(location: 'RBCLI', type: :env, banner: @banner)
      config[:foo] = :bar
      config.save!
      config.annotate!
    end
  end
end