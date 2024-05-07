# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
%w[spec_helper yaml].each { |file| require file }

RSpec.describe 'Config module' do
  context "schema validation" do
    before(:example) do
      @datafile = Tempfile.new(%w[config .yaml])
      @datafile.close
      @data = { string: 'string',
                symbol: :symbol,
                integer: 1234,
                float: 12.34,
                boolean_true: true,
                boolean_false: false,
                hash: {
                  first_level: 'John',
                  hash: {
                    second_level: 'Jim'
                  }
                }.deep_symbolize!
      }

      def populate_yaml
        @data.deep_stringify!
        File.write(@datafile.path, @data.to_yaml)
        @data.deep_symbolize!
      end

      @schemafile = Tempfile.new(%w[schema .yaml])
      @schemafile.close
      @schema = {
        "$id": "https://config/config.schema.json",
        title: "Test Config Schema",
        type: "object",
        additionalProperties: true,
        properties: {
          string: {
            type: "string",
            pattern: "^string$"
          }
        }
      }

      def populate_schema
        @schema.deep_stringify!
        File.write(@schemafile.path, @schema.to_yaml)
        @schema.deep_symbolize!
      end
    end

    after(:example) do
      @datafile.unlink
      @schemafile.unlink
    end

    it "correctly validates with a matching schema" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path)
      config.load!
      expect(config.validate!).to eq(true)
      expect(Rbcli.exit_code).to eq(nil)
    end

    it "returns false on failure" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path)
      populate_schema
      config[:string] = 1234
      expect(config.validate!).to eq(false)
    end

    it "shows a descriptive message on failure" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path)
      populate_schema
      config[:string] = 1234
      Rbcli.logstream.reopen
      config.validate!
      expect(Rbcli.logstream.string).to include("The property '#/string' of type integer did not match the following type: string")
    end

    it "attempts to quit on failure" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path)
      populate_schema
      config[:string] = 1234
      config.validate!
      expect(Rbcli.exit_code).not_to eq(nil)
    end

    it "still returns false on failure when suppress_errors is true" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path, suppress_errors: true)
      populate_schema
      config[:string] = 1234
      expect(config.validate!).to eq(false)
    end

    it "does not show a message on failure when suppress_errors is true" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path)
      populate_schema
      config[:string] = 1234
      Rbcli.logstream.reopen
      config.validate!
      expect(Rbcli.logstream.string).to include("The property '#/string' of type integer did not match the following type: string")
    end

    it "does not attempt to exit on failure when suppress_errors is true" do
      config = Rbcli::Config.new(location: @datafile.path, schema_location: @schemafile.path, suppress_errors: true)
      populate_schema
      config[:string] = 1234
      config.validate!
      expect(Rbcli.exit_code).to eq(nil)
    end
  end
end