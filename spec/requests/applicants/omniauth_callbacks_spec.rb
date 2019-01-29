require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'applicants omniauth call back', type: :request do
  around(:example) do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.mock_auth[:true_layer] = nil
    OmniAuth.config.test_mode = false
  end

  let(:token) { SecureRandom.uuid }
  let(:expires_at) { 1.hour.from_now.round }
  let(:true_layer_expires_at) { expires_at.to_i }
  let(:applicant) { create :applicant }
  let(:legal_aid_application) { create :legal_aid_application, applicant: applicant }
  let(:bank_provider) { applicant.bank_providers.find_by(token: token) }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id) if applicant
    OmniAuth.config.add_mock(
      :true_layer,
      credentials: {
        token: token,
        expires_at: true_layer_expires_at
      }
    )

    stub_true_layer
    ImportBankDataWorker.clear
  end

  describe 'GET /applicants/auth/true_layer/callback' do
    subject do
      get applicant_true_layer_omniauth_callback_path
      ImportBankDataWorker.drain
    end

    it 'should redirect to next page' do
      worker_id = SecureRandom.hex
      allow(ImportBankDataWorker).to receive(:perform_async).and_return(worker_id)
      expect(subject).to redirect_to(citizens_accounts_path(worker_id: worker_id))
    end

    it 'should import bank provider' do
      expect { subject }.to change { applicant.bank_providers.count }.by(1)
      expect(bank_provider.token).to eq(token)
      expect(bank_provider.token_expires_at.utc.to_s).to eq(expires_at.utc.to_s)
    end

    it 'should import bank transactions' do
      expect { subject }.to change { BankTransaction.count }.by_at_least(1)
    end

    context 'with a string time' do
      let(:true_layer_expires_at) { expires_at.to_json }

      it 'should persist expires_at' do
        subject
        expect(bank_provider.token_expires_at.utc.to_s).to eq(expires_at.utc.to_s)
      end
    end

    context 'with nil time' do
      let(:true_layer_expires_at) { nil }

      it 'should not persist expires_at' do
        subject
        expect(bank_provider.token_expires_at).to be_nil
      end
    end

    context 'without applicant' do
      let(:applicant) { nil }

      it 'should redirect to root' do
        expect(subject).to redirect_to(citizens_consent_path)
      end
    end

    context 'on authentication failure' do
      before do
        OmniAuth.config.mock_auth[:true_layer] = :invalid_credentials
      end

      it 'should redirect to root' do
        # Faraday defined within OAuth2::Client outputs to console on error
        # which then outputs into the standard rspec progress sequence rather
        # than to logs. Mocking `logger.add` silences that output for this spec
        allow_any_instance_of(Logger).to receive(:add)
        subject
        follow_redirect!
        expect(request.env['REQUEST_URI']).to eq(citizens_consent_path)
      end
    end
  end
end
