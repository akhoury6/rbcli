# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require 'erb'

module Rbcli
  module ToolHelpers
    def self.render_erb src, template_vars
      ERBRenderer.new(src, template_vars).render
    end

    def self.cp_file src_file, dest_file, render_erb: true, set_executable: false, template_vars: nil, force: false
      src = File.expand_path(src_file)
      dest = File.expand_path(dest_file)
      if File.exist?(dest) && !force
        Rbcli.log.info "File #{File.basename(dest)} already exists. Overwrite? (y/N):", "TOOL"
        answer = gets.chomp
        answer = { 'y' => true, 'n' => false }[(answer[0] || '').downcase]
        if answer
          FileUtils.rm_rf(dest)
        else
          Rbcli.log.error "Destination file #{dest} already exists. Please delete it and try again.", "TOOL"
          return false
        end
      end
      Rbcli.log.info "Generating file " + File.basename(dest) + " ... ", "TOOL"
      if render_erb
        File.write(dest, self.render_erb(src, template_vars))
      else
        FileUtils.cp(src, dest)
      end
      FileUtils.chmod(set_executable ? 0755 : 0644, dest)
      FileUtils.rm_f(File.join(File.dirname(dest), '.keep')) if File.exist?(File.join(File.dirname(dest), '.keep'))
      true
    end

    class ERBRenderer
      def initialize filename, varlist
        @filename = filename
        varlist.each do |k, v|
          self.instance_variable_set("@#{k.to_s}", v)
        end
        @vars = varlist
      end

      def render_component name, filename = 'template.rb.erb'
        location = File.join(RBCLI_LIBDIR, 'components', name, filename)
        ERB.new(File.read(location), trim_mode: '-', eoutvar: '_sub01').result(binding)
      end

      def render
        ERB.new(File.read(@filename), trim_mode: '-').result(binding)
      end
    end
  end
end
