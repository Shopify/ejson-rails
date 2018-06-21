# frozen_string_literal: true

module EJSON
  module Rails
    Rails = ::Rails
    private_constant :Rails

    class Railtie < Rails::Railtie
      config.before_configuration do
        json_files.each do |file|
          next unless valid?(file)
          secrets = JSON.parse(file.read, symbolize_names: true)
          break Rails.application.secrets.deep_merge!(secrets)
        end
      end

      class << self
        private

        def valid?(pathname)
          pathname.exist?
        end

        def json_files
          [
            Rails.root.join("config", "secrets.json"),
            Rails.root.join("config", "secrets.#{Rails.env}.json"),
          ]
        end
      end
    end
  end
end
