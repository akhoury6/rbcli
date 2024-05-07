# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
BASEDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

%w[stringio yaml json tempfile].each { |file| require file }

# Pull in the local Rbcli code directly to avoid conflicting with an installed gem
require File.join(BASEDIR, 'lib', 'rbcli.rb')
require File.join(BASEDIR, 'lib', 'rbcli', 'components', 'logger', 'logger.rb')
require File.join(BASEDIR, 'lib', 'rbcli', 'components', 'config', 'config.rb')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do

    module Rbcli
      @stream = StringIO.new
      Rbcli.start_logger target: @stream, level: :debug, format: :simple

      def self.logstream
        @stream
      end

      @exit_code = nil

      def self.exit code = 0
        @exit_code = code
      end

      def self.exit_code
        @exit_code
      end
    end
  end

  config.after(:example) do
    Rbcli.logstream.reopen
    Rbcli.exit nil
  end
end