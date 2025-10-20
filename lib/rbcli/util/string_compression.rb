# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'base64'
require 'zlib'

String.instance_eval { define_method(:compress) { Base64.strict_encode64(Zlib::Deflate.deflate(self)) } }
String.instance_eval { define_method(:decompress) { Zlib::Inflate.inflate(Base64.strict_decode64(self)) } }