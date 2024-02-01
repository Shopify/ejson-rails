# frozen_string_literal: true

RSpec.describe(EJSON::Rails::Railtie) do
  subject { described_class.instance }

  let(:secrets) { secrets_class.new }
  let(:credentials) { credentials_object }

  it "should be a Railtie" do
    is_expected.to(be_a(Rails::Railtie))
  end

  context "before configuration" do
    before do
      allow_rails.to(receive(:root).and_return(fixtures_root))
      allow_rails.to(receive_message_chain("application.secrets").and_return(secrets))
      allow_rails.to(receive_message_chain("application.credentials").and_return(credentials))
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
        expect(Rails).to(receive(:env).and_return(:env))
        run_load_hooks
        expect(secrets).to(include(secret: "test_api_key"))
      end

      it "does not load anything when Rails.env doesn't match" do
        expect(Rails).to(receive(:env).and_return(:production))
        run_load_hooks
        expect(secrets).to(be_empty)
      end
    end

    context "without any json" do
      before { hide_secrets_files(secrets_json, environment_secrets_json) }

      it "does not load anything" do
        expect(Rails).to(receive(:env).and_return(:production))
        run_load_hooks
        expect(secrets).to(be_empty)
      end
    end

    describe "dynamic secret source configuration" do
      context "when no ejson_secret_source is configured" do
        it "falls back to loading secrets from disk" do
          run_load_hooks
          expect(secrets).to(include(secret: "real_api_key"))
        end
      end

      context "when ejson_secret_source is a proc which yields secrets" do
        before { described_class.ejson_secret_source = proc { '{"secret": "secret_from_ejson_secret_source"}' } }

        it "loads the return value to Rails secrets" do
          run_load_hooks
          expect(secrets).to(include(secret: "secret_from_ejson_secret_source"))
        end
      end

      context "when ejson_secret_source is a proc which does not yield secrets" do
        before { described_class.ejson_secret_source = proc {} }
        it "falls back to default behavior of loading secrets from disk" do
          run_load_hooks
          expect(secrets).to(include(secret: "real_api_key"))
        end
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
      before do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("EJSON_RAILS_DELETE_SECRETS").and_return(ejson_rails_delete_secrets))
        allow(Rails).to(receive(:env).and_return(:env))
      end

      context "when EJSON_RAILS_DELETE_SECRETS equals true" do
        let(:ejson_rails_delete_secrets) { "true" }

        it "deletes the JSON files" do
          expect(File).to(receive(:delete).once.ordered.with(secrets_json))
          expect(File).to(receive(:delete).once.ordered.with(environment_secrets_json))
          run_load_hooks
        end
      end

      context "when EJSON_RAILS_DELETE_SECRETS equals anything other than true" do
        let(:ejson_rails_delete_secrets) { "nope" }

        it "does not delete the JSON files" do
          expect(File).not_to(receive(:delete))
          run_load_hooks
        end
      end

      context "when EJSON_RAILS_DELETE_SECRETS is not set" do
        let(:ejson_rails_delete_secrets) {}

        it "does not delete the JSON files" do
          expect(File).not_to(receive(:delete))
          run_load_hooks
        end
      end
    end
  end
end
