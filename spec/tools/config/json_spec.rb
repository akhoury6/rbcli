# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper json].each { |file| require file }

RSpec.describe 'Config module' do
  context "json file" do
    before(:example) do
      @datafile = Tempfile.new(%w[config .json])
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

      def populate_json
        @data.deep_stringify!
        File.write(@datafile.path, @data.to_json)
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

    it "detects empty json config based on filename" do
      config = Rbcli::Config.new(location: @datafile.path)
      expect(config.type).to eq(:json)
    end

    it "detects empty json config based on parameter" do
      config = Rbcli::Config.new(location: @datafile.path, type: :json)
      expect(config.type).to eq(:json)
    end

    it "evaluates as an empty hash" do
      config = Rbcli::Config.new(location: @datafile.path)
      expect(config).to be_a(Hash)
      expect(config).to eq(Hash.new)
    end

    it "loads json data converting all keys to symbols" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_json
      config.load!
      expect(config.keys).to eq(@data.deep_symbolize!.keys)
    end

    it "loads all variable types as expected (symbols become strings)" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_json
      config.load!
      expect(config[:string]).to eq(@data[:string])
      expect(config[:symbol]).to eq(@data[:symbol].to_s) # JSON does not support symbols, so we convert to string
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
      json_data = JSON.parse(File.read(@datafile.path)).deep_symbolize!
      expect(json_data[:string]).to eq(@data[:string])
      expect(json_data[:symbol]).to eq(@data[:symbol].to_s) # JSON does not support symbols, so we convert to string
      expect(json_data[:integer]).to eq(@data[:integer])
      expect(json_data[:float]).to eq(@data[:float])
      expect(json_data[:boolean_true]).to eq(@data[:boolean_true])
      expect(json_data[:boolean_false]).to eq(@data[:boolean_false])
      expect(json_data[:array]).to eq(@data[:array])
      expect(json_data[:hash]).to eq(@data[:hash])
      expect(json_data.keys).to eq(@data.keys)
    end

    it "saves json data converting keys to strings" do
      config = Rbcli::Config.new(location: @datafile.path)
      config[:foo] = :bar
      config.save!
      json_data = File.read(@datafile.path)
      expect(json_data).to eq(JSON.pretty_generate({ "foo" => "bar" }))
    end

    it "merges missing defaults on load" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_json
      config.defaults = { foo: "bar", string: "default_string", supergroup: { bar: 'baz' } }
      expect(config.defaults).to eq({ foo: "bar", string: "default_string", supergroup: { bar: 'baz' } })
      config.load!
      expect(config).to eq(@data.merge({ foo: "bar", symbol: 'symbol', string: @data[:string], supergroup: { bar: 'baz' } })) # json does not support loading symbols
    end

    it "does not save banner to top of file because json spec does not allow it" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_json
      config.set_banner @banner
      config.load!
      config.save!
      config.annotate!
      txt = File.read(@datafile.path)
      @banner.lines.each { |line| expect(txt).not_to include(line) }
      config2 = Rbcli::Config.new(location: @datafile.path)
      config2.load!
      expect(config2).to eq(config)
      expect(config2).to eq(@data.merge({ symbol: 'symbol' }))
    end
  end
end