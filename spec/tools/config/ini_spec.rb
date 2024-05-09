# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper].each { |file| require file }

RSpec.describe 'Config module' do
  context "ini file" do
    before(:example) do
      @datafile = Tempfile.new(%w[config .ini])
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
            second_level: 'Jim',
            hash: {
              third_level: 'Bob',
              hash: {
                fourth_level: 'Betty'
              }
            }
          }
        }
      }
      @inifile = <<~INIFILE
        string = string
        symbol = :symbol
        integer = 1234
        float = 12.34
        boolean_true = true
        boolean_false = false
        array = [1, 2, 3, [4, 5, 6]]
        [hash]
        first_level = John
        [hash.hash]
        second_level = Jim
        [hash.hash.hash]
        third_level = Bob
        [hash.hash.hash.hash]
        fourth_level = Betty
      INIFILE

      def populate_ini
        File.write(@datafile.path, @inifile)
      end

      @banner = <<~BANNER
        This is a test banner!
        Multiple lines of text should work too.
      BANNER
    end

    after(:example) do
      @datafile.unlink
    end

    it "detects empty ini config based on filename" do
      config = Rbcli::Config.new(location: @datafile.path)
      expect(config.type).to eq(:ini)
    end

    it "detects empty ini config based on parameter" do
      config = Rbcli::Config.new(location: @datafile.path, type: :ini)
      expect(config.type).to eq(:ini)
    end

    it "evaluates as an empty hash" do
      config = Rbcli::Config.new(location: @datafile.path)
      expect(config).to be_a(Hash)
      expect(config).to eq(Hash.new)
    end

    it "loads ini data converting all keys to symbols" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_ini
      config.load!
      expect(config.keys).to eq(@data.deep_symbolize!.keys)
    end

    it "loads all variable types as expected" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_ini
      config.load!
      expect(config[:string]).to eq(@data[:string])
      expect(config[:symbol]).to eq(@data[:symbol])
      expect(config[:integer]).to eq(@data[:integer])
      expect(config[:float]).to eq(@data[:float])
      expect(config[:boolean_true]).to eq(@data[:boolean_true])
      expect(config[:boolean_false]).to eq(@data[:boolean_false])
      expect(config[:array]).to eq(@data[:array])
      expect(config[:hash]).to eq(@data[:hash])
      expect(config).to eq(@data)
    end

    it "skips saving changes when no changes are made" do
      config = Rbcli::Config.new(location: @datafile.path)
      old_mtime = File.mtime(@datafile.path)
      config.save!
      new_mtime = File.mtime(@datafile.path)
      expect(new_mtime).to eq(old_mtime)
    end

    it "saves ini file in the correct format for all variable types" do
      config = Rbcli::Config.new(location: @datafile.path)
      @data.each { |key, value| config[key] = value }
      config.save!
      ini_data = File.read(@datafile.path).lines.map { |line| line.chomp.strip }
      ini_data.reject!(&:empty?)
      ini_data.each do |line|
        expect(@inifile).to include(line)
      end
      @inifile.lines.each do |line|
        expect(ini_data).to include(line.chomp.strip)
      end
    end

    it "saves ini data converting keys to strings" do
      config = Rbcli::Config.new(location: @datafile.path)
      config[:foo] = :bar
      config.save!
      ini_data = File.read(@datafile.path)
      expect(ini_data).to eq("foo = :bar")
    end

    it "merges missing defaults on load" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_ini
      config.defaults = { foo: "bar", string: "default_string", supergroup: { bar: 'baz' } }
      expect(config.defaults).to eq({ foo: "bar", string: "default_string", supergroup: { bar: 'baz' } })
      config.load!
      expect(config).to eq(@data.merge({ foo: "bar", string: @data[:string], supergroup: { bar: 'baz' } }))
    end

    it "saves banner to top of file as a valid comment" do
      config = Rbcli::Config.new(location: @datafile.path)
      populate_ini
      config.set_banner @banner
      config.load!
      config.save!
      config.annotate!
      txt = File.read(@datafile.path)
      @banner.lines.each { |line| expect(txt).to match(/;+ +#{line}/) }
      config2 = Rbcli::Config.new(location: @datafile.path)
      config2.load!
      expect(config2).to eq(config)
      expect(config2).to eq(@data)
    end
  end
end