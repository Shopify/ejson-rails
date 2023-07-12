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

    context "with set_secrets = false" do
      it "does not merge secrets into application secrets" do
        described_class.set_secrets = false
        run_load_hooks
        expect(secrets).to(be_empty)
      ensure
        described_class.set_secrets = true
      end
    end
  end
end
