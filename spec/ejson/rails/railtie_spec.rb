# frozen_string_literal: true

RSpec.describe(EJSON::Rails::Railtie) do
  subject { described_class.instance }

  let(:secrets) { secrets_class.new }
  let(:credentials) { credentials_object }
  let(:production_env) { ActiveSupport::EnvironmentInquirer.new("production") }
  let(:staging_env) { ActiveSupport::EnvironmentInquirer.new("staging") }
  let(:default_env) { ActiveSupport::EnvironmentInquirer.new("env") }

  it "should be a Railtie" do
    is_expected.to(be_a(Rails::Railtie))
  end

  context "before configuration" do
    before do
      allow_rails.to(receive(:root).and_return(fixtures_root))
      allow_rails.to(receive_message_chain("application.secrets").and_return(secrets))
      allow_rails.to(receive_message_chain("application.credentials").and_return(credentials))
      allow(File).to(receive(:delete))
    end

    it "merges secrets into application secrets" do
      run_load_hooks
      expect(secrets).to(include(:secret))
    end

    it "merges secrets into application credentials" do
      run_load_hooks
      expect(credentials.config).to(include(:secret))
    end

    it "raises if an application credential would be overwritten" do
      credentials.config[:secret] = "some-credential"
      expect { run_load_hooks }
        .to(raise_error("A credential already exists with the same name: secret"))
    end

    it "prioritizes secrets.json" do
      run_load_hooks
      expect(secrets).to(include(secret: "real_api_key"))
    end

    context "without secrets.json" do
      before { hide_secrets_files(secrets_json) }

      it "falls back to secrets.env.json" do
        expect(Rails).to(receive(:env).twice.and_return(default_env))
        run_load_hooks
        expect(secrets).to(include(secret: "test_api_key"))
      end

      it "does not load anything when Rails.env doesn't match" do
        expect(Rails).to(receive(:env).and_return(staging_env))
        run_load_hooks
        expect(secrets).to(be_empty)
      end
    end

    context "without any json" do
      before { hide_secrets_files(secrets_json, environment_secrets_json) }

      it "does not load anything" do
        expect(Rails).to(receive(:env).and_return(staging_env))
        run_load_hooks
        expect(secrets).to(be_empty)
      end
    end

    context "with set_secrets = false" do
      it "does not merge secrets into application secrets" do
        described_class.set_secrets = false
        run_load_hooks
        expect(secrets).to(be_empty)
      ensure
        described_class.set_secrets = true
      end
    end

    describe "deleting the JSON files" do
      context "in production environments" do
        before { allow_rails.to(receive(:env).and_return(production_env)) }
        it "deletes the JSON files" do
          expect(File).to(receive(:delete).once.ordered.with(secrets_json))
          expect(File).to(receive(:delete).once.ordered.with(production_secrets_json))
          run_load_hooks
        end
      end

      context "in non-production environments" do
        before { allow_rails.to(receive(:env).and_return(staging_env)) }

        it "does not delete the JSON files" do
          expect(File).not_to(receive(:delete))
          run_load_hooks
        end
      end
    end
  end
end
