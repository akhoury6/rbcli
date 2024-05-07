# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'spec_helper'
require 'rubygems'

RSpec.describe "Rbcli project" do
  it "has a version number" do
    expect(Rbcli::VERSION).not_to be nil
  end

  it "pulls the version number from a file" do
    version = File.read("VERSION")
    expect(Rbcli::VERSION).equal? version
  end
end