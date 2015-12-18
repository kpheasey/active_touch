module ActiveTouch
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_files
        template 'active_touch.rb', 'config/initializers/active_touch.rb'
      end

    end
  end
end