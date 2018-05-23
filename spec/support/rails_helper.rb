# frozen_string_literal: true

module RailsHelper
  def allow_rails
    allow(Rails)
  end

  def secrets_class
    ActiveSupport::OrderedOptions
  end

  def run_initializers_of(railtie)
    railtie.initializers.each(&:run)
  end
end
