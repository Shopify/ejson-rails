# frozen_string_literal: true

module RailsHelper
  def allow_rails
    allow(Rails)
  end

  def secrets_class
    ActiveSupport::OrderedOptions
  end

  def run_load_hooks
    ActiveSupport.run_load_hooks(:before_configuration)
  end
end
