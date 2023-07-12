# frozen_string_literal: true

module EJSON
  module Rails
    Rails = ::Rails
    private_constant :Rails

    class Railtie < Rails::Railtie
      config.before_configuration do
        json_file = json_files.detect { |file| valid?(file) }
        next unless json_file

        secrets = JSON.parse(json_file.read, symbolize_names: true)
        Rails.application.secrets.deep_merge!(secrets)
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
