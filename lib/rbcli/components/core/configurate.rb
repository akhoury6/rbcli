# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
module Rbcli::Configurate
  # If a non-existant method is called, we attempt to load the plugin.
  # If the plugin fails to load we display a message to the developer
  def self.method_missing(method, *args, &block)
    filename = File.join(RBCLI_LIBDIR, 'plugins', method.to_s.downcase, 'component.rb')
    if File.exist? filename
      require filename
      self.send method, *args, &block
    else
      raise Rbcli::ConfigurateError.new "Invalid Rbcli Configurate plugin called: `#{method}` in file #{File.expand_path caller[0]}"
    end
  end
end

module Rbcli::Configurable
  def self.included klass
    # We dynamically add two methods to the module: one that runs other methods dynamially, and one that
    # displays a reasonable message if a method is missing
    klass.singleton_class.class_eval do
      define_method :rbcli_private_running_method do |&block|
        @self_before_instance_eval = eval 'self', block.binding
        instance_eval &block
      end

      define_method :method_missing do |method, *args, &block|
        raise Rbcli::ConfigurateError.new "Invalid Configurate.#{self.name.split('::')[-1].downcase} method called: `#{method}` in file #{File.expand_path caller[0]}"
      end
    end

    # This will dynamically create the configurate block based on the class name.
    # For example, if the class name is 'Me', then the resulting block is `Configurate.me`
    name = klass.name.split('::')[-1]
    Rbcli::Configurate.singleton_class.class_eval do
      define_method name.downcase.to_sym do |&block|
        mod = self.const_get name
        begin
          mod.rbcli_private_running_method &block
        rescue Rbcli::ConfigurateError => e
          Rbcli.log.fatal 'Rbcli Configuration Error: ' + e.message
          Rbcli::exit 255
        end
      end
    end
  end
end

Dir.glob(File.dirname(__FILE__) + '/../**/component.rb', &method(:require))

# module Rbcli
#   def self.configuration mod, key = nil
#     begin
#       d = Rbcli::Configurate.const_get(mod.to_s.capitalize.to_sym).config
#       (key.nil?) ? d : d[key]
#     rescue
#       nil
#     end
#   end
# end