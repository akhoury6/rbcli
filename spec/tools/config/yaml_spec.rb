# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper yaml].each { |file| require file }

RSpec.describe 'Config module' do
  context "yaml file" do
    before(:example) do
      @datafile = Tempfile.new(%w[config .yaml])
      @datafile.close
      @data = {
        string: 'string',
        symbol: :symbol,
        integer: 1234,
        float: 12.34,
        boolean_true: true,
        boolean_false: false,
        array: [1, 2, 3, [4, 5, 6]],
        hash: {
          first_level: 'John',
          hash: {
            second_level: 'Jim'
          }
        }
      }

      def populate_yaml
        @data.deep_stringify!
        File.write(@datafile.path, @data.to_yaml)
        @data.deep_symbolize!
      end

      @banner = <<~BANNER
        This is a test banner!
        Multiple lines of text should work too.
      BANNER
    end

    after(:example) do
      @datafile.unlink
    end

    it "detects empty yaml config based on filename" do
      config = Rbcli::Config.new(location: @datafile.path)
      expect(config.type).to eq(:yaml)
    end

    it "detects empty yaml config based on parameter" do
      config = Rbcli::Config.new(location: @datafile.path, type: :yaml)
      expect(config.type).to eq(:yaml)
    end

    it "evaluates as an empty hash" do
      config = Rbcli::Config.new(location: @datafile.path)
      expect(config).to be_a(Hash)
      expect(config).to eq(Hash.new)
    end

    it "loads yaml data converting all keys to symbols" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_yaml
      config.load!
      expect(config.keys).to eq(@data.deep_symbolize!.keys)
    end

    it "loads all variable types as expected" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_yaml
      config.load!
      expect(config[:string]).to eq(@data[:string])
      expect(config[:symbol]).to eq(@data[:symbol])
      expect(config[:integer]).to eq(@data[:integer])
      expect(config[:float]).to eq(@data[:float])
      expect(config[:boolean_true]).to eq(@data[:boolean_true])
      expect(config[:boolean_false]).to eq(@data[:boolean_false])
      expect(config[:array]).to eq(@data[:array])
      expect(config[:hash]).to eq(@data[:hash])
      expect(config.keys).to eq(@data.keys)
    end

    it "skips saving changes when no changes are made" do
      config = Rbcli::Config.new(location: @datafile.path)
      old_mtime = File.mtime(@datafile.path)
      config.save!
      new_mtime = File.mtime(@datafile.path)
      expect(new_mtime).to eq(old_mtime)
    end

    it "correctly saves all variable types as expected" do
      config = Rbcli::Config.new(location: @datafile.path)
      @data.each { |key, value| config[key] = value }
      config.save!
      yaml_data = YAML.safe_load_file(@datafile.path, symbolize_names: true, aliases: true, permitted_classes: [Symbol])
      expect(yaml_data[:string]).to eq(@data[:string])
      expect(yaml_data[:symbol]).to eq(@data[:symbol])
      expect(yaml_data[:integer]).to eq(@data[:integer])
      expect(yaml_data[:float]).to eq(@data[:float])
      expect(yaml_data[:boolean_true]).to eq(@data[:boolean_true])
      expect(yaml_data[:boolean_false]).to eq(@data[:boolean_false])
      expect(yaml_data[:array]).to eq(@data[:array])
      expect(yaml_data[:hash]).to eq(@data[:hash])
      expect(yaml_data.keys).to eq(@data.keys)
    end

    it "saves yaml data converting keys to strings" do
      config = Rbcli::Config.new(location: @datafile.path)
      config[:foo] = :bar
      config.save!
      yaml_data = File.read(@datafile.path)
      expect(yaml_data).to eq({ "foo" => :bar }.to_yaml)
    end

    it "merges missing defaults on load" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_yaml
      config.defaults = { foo: "bar", string: "default_string", supergroup: { bar: 'baz' } }
      expect(config.defaults).to eq({ foo: "bar", string: "default_string", supergroup: { bar: 'baz' } })
      config.load!
      expect(config).to eq(@data.merge({ foo: "bar", string: @data[:string], supergroup: { bar: 'baz' } }))
    end

    it "saves banner to top of file as a valid comment" do
      config = Rbcli::Config.new(location: @datafile.path, banner: @banner)
      populate_yaml
      config.load!
      config.save!
      config.annotate!
      txt = File.read(@datafile.path)
      @banner.lines.each { |line| expect(txt).to match(/#+ +#{line}/) }
      config2 = Rbcli::Config.new(location: @datafile.path)
      config2.load!
      expect(config2).to eq(config)
      expect(config2).to eq(@data)
    end
  end
end