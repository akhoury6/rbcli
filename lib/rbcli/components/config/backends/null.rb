# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
class Rbcli::UserConf::Null < Rbcli::UserConf::Backend
  def initialize filename, type
    @type = type.to_s.upcase
    @loaded = false
  end

  def load _defaults = nil
    @loaded = true
    {}
  end

  def save hash
    hash
  end

  def save_raw text
    true
  end

  def savable?
    false
  end

  def exist?
    true
  end
end