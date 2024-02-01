# frozen_string_literal: true

module EJSON
  module Rails
    Rails = ::Rails
    private_constant :Rails

    class Railtie < Rails::Railtie
      singleton_class.attr_accessor(:ejson_secret_source, :set_secrets)
      @set_secrets = true

      config.before_configuration do
        secrets = load_secrets_from_config || load_secrets_from_disk
        next unless secrets

        secrets = JSON.parse(secrets, symbolize_names: true)

        Rails.application.secrets.deep_merge!(secrets) if set_secrets
        # Merging into `credentials.config` because in Rails 7.0, reading a credential with
        # Rails.application.credentials[:some_credential] won't work otherwise.
        Rails.application.credentials.config.deep_merge!(secrets) do |key|
          raise "A credential already exists with the same name: #{key}"
        end

        # Delete the loaded JSON files so they are no longer readable by the app.
        if ENV["EJSON_RAILS_DELETE_SECRETS"] == "true"
          json_files.each do |pathname|
            File.delete(pathname) if File.writable?(pathname)
          end
        end
      end

      class << self
        private

        def load_secrets_from_config
          ejson_secret_source&.yield
        end

        def load_secrets_from_disk
          json_files.detect { |file| valid?(file) }&.read
        end

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
