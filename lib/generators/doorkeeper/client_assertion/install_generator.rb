# frozen_string_literal: true

module Doorkeeper
  module ClientAssertion
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      desc 'Installs doorkeeper-client_assertion initializer.'

      def install
        template 'initializer.rb', 'config/initializers/doorkeeper_client_assertion.rb'
      end
    end
  end
end
