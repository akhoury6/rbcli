# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'spec_helper'

RSpec.describe 'Config module' do
  context 'loader' do
    before(:example) do
      @datafiles = [Tempfile.new(%w[config .yaml]), Tempfile.new(%w[config .yaml]), Tempfile.new(%w[config .yaml])]
      @datafile_paths = @datafiles.map(&:path)
      @datafiles.each_with_index do |df, index|
        df.close
        File.write(df.path, { index: index }.deep_stringify.to_yaml)
      end
    end
    after(:example) do
      @datafiles.each { |df| df.unlink }
    end

    it 'loads a single file correctly' do
      config = Rbcli::Config.new(location: @datafile_paths[0])
      config.load!
      expect(config).to eq({ index: 0 })
    end

    it 'loads the first found file out of a list of valid files' do
      config = Rbcli::Config.new(location: @datafile_paths)
      config.load!
      expect(config).to eq({ index: 0 })
    end

    it 'skips invalid files in the list to load a good one' do
      @datafiles[0].unlink
      config = Rbcli::Config.new(location: @datafile_paths)
      config.load!
      expect(config).to eq({ index: 1 })
      @datafiles[1].unlink
      config = Rbcli::Config.new(location: @datafile_paths)
      config.load!
      expect(config).to eq({ index: 2 })
    end

    it 'does not create a file if one exists' do
      @datafiles[0].unlink
      config = Rbcli::Config.new(location: @datafile_paths)
      config.load!
      expect(config).to eq({ index: 1 })
      expect(File.exist?(@datafile_paths[0])).to eq(false)
    end

    it 'creates a file at the first location if none exist' do
      @datafiles.each { |df| df.unlink }
      config = Rbcli::Config.new(location: @datafile_paths, create_if_not_exists: true)
      config.load!
      expect(File.exist?(@datafile_paths[0])).to eq(true)
      expect(File.exist?(@datafile_paths[1])).to eq(false)
      expect(File.exist?(@datafile_paths[2])).to eq(false)
    end

    it 'injects defaults at the first location if no files exist' do
      @datafiles.each { |df| df.unlink }
      config = Rbcli::Config.new(location: @datafile_paths, create_if_not_exists: true)
      config.defaults = { foo: 'bar' }
      config.load!
      expect(config).to eq({ foo: 'bar' })
    end
  end
end
