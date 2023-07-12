# frozen_string_literal: true

module RailsHelper
  def allow_rails
    allow(Rails)
  end

  def secrets_class
    ActiveSupport::OrderedOptions
  end

  def credentials_object
    ActiveSupport::EncryptedConfiguration.new(
      config_path: "file.enc",
      key_path: "keyfile.key",
      env_key: "RAILS_KEY",
      raise_if_missing_key: false,
    )
  end

  def run_load_hooks
    ActiveSupport.run_load_hooks(:before_configuration)
  end
end
