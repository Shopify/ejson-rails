# frozen_string_literal: true

module PathHelper
  def spec_root
    Pathname.new(File.dirname(__FILE__)).join("..")
  end

  def fixtures_root
    spec_root.join("fixtures")
  end

  def secrets_json
    fixtures_root.join("config", "secrets.json")
  end

  def environment_secrets_json
    fixtures_root.join("config", "secrets.env.json")
  end

  def production_secrets_json
    fixtures_root.join("config", "secrets.production.json")
  end
end
