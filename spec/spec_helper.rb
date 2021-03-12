# frozen_string_literal: true

require "bundler/setup"
require "rails"
require "ejson/rails"

require_relative "support/path_helper"
require_relative "support/file_helper"
require_relative "support/rails_helper"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.include(PathHelper)
  config.include(FileHelper)
  config.include(RailsHelper)
end
