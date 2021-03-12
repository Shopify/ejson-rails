# frozen_string_literal: true

module FileHelper
  def hide_secrets_files(*files)
    allow(EJSON::Rails::Railtie).to(receive(:valid?).and_call_original)
    files.each do |file|
      allow(EJSON::Rails::Railtie).to(receive(:valid?).with(file).and_return(false))
    end
  end
end
