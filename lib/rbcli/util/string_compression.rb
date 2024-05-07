# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'base64'
require 'zlib'

String.instance_eval { define_method(:compress) { Base64.encode64(Zlib::Deflate.deflate(self)).chomp } }
String.instance_eval { define_method(:decompress) { Zlib::Inflate.inflate(Base64.decode64(self)) } }