# frozen_string_literal: true

RSpec.describe(EJSON::Rails::Railtie) do
  subject { described_class.instance }

  let(:secrets) { secrets_class.new }

  it 'should be a Railtie' do
    is_expected.to(be_a(::Rails::Railtie))
  end

  context 'before configuration' do
    before do
      allow_rails.to(receive(:root).and_return(fixtures_root))
      allow_rails.to(receive_message_chain('application.secrets').and_return(secrets))
    end

    it 'merges secrets into application secrets' do
      run_load_hooks
      expect(secrets).to(include(:secret))
    end

    it 'prioritizes secrets.json' do
      run_load_hooks
      expect(secrets).to(include(secret: 'real_api_key'))
    end

    context 'without secrets.json' do
      before { hide_secrets_files(secrets_json) }

      it 'falls back to secrets.env.json' do
        expect(Rails).to(receive(:env).and_return(:env))
        run_load_hooks
        expect(secrets).to(include(secret: 'test_api_key'))
      end

      it 'does not load anything when Rails.env doesn\'t match' do
        expect(Rails).to(receive(:env).and_return(:production))
        run_load_hooks
        expect(secrets).to(be_empty)
      end
    end

    context 'without any json' do
      before { hide_secrets_files(secrets_json, environment_secrets_json) }

      it 'does not load anything' do
        expect(Rails).to(receive(:env).and_return(:production))
        run_load_hooks
        expect(secrets).to(be_empty)
      end
    end
  end
end
