# frozen_string_literal: true

RSpec.describe EJSON::Rails::Railtie do
  subject { described_class.instance }

  let(:secrets) { secrets_class.new }

  it 'should be a Railtie' do
    is_expected.to be_a ::Rails::Railtie
  end

  context 'initialized' do
    before do
      allow_rails.to receive(:root).and_return(fixtures_root)
      allow_rails.to receive_message_chain('application.secrets').and_return(secrets)
    end

    it 'merges secrets into application secrets' do
      run_initializers_of(subject)
      expect(secrets).to include(:secret)
    end

    it 'prioritizes secrets.json' do
      run_initializers_of(subject)
      expect(secrets).to include(secret: 'real_api_key')
    end

    context 'without secrets.json' do
      before do
        allow(subject).to receive(:valid?).and_call_original
        allow(subject).to receive(:valid?).with(secrets_json).and_return(false)
      end

      it 'falls back to secrets.env.json' do
        expect(Rails).to receive(:env).and_return(:env)
        run_initializers_of(subject)
        expect(secrets).to include(secret: 'test_api_key')
      end

      it 'does not load anything when Rails.env doesn\'t match' do
        expect(Rails).to receive(:env).and_return(:production)
        run_initializers_of(subject)
        expect(secrets).to be_empty
      end
    end

    context 'without any json' do
      before do
        allow(subject).to receive(:valid?).with(instance_of(Pathname)).and_return(false)
      end

      it 'does not load anything' do
        expect(Rails).to receive(:env).and_return(:production)
        run_initializers_of(subject)
        expect(secrets).to be_empty
      end
    end
  end
end
