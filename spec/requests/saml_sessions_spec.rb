require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'SamlSessionsController', type: :request do
  let(:existing_details_response) { nil }
  let(:provider) { create :provider, :username_with_special_characters, details_response: existing_details_response }

  describe 'DELETE /providers/sign_out' do
    before { sign_in provider }
    subject { delete destroy_provider_session_path }

    it 'logs user out' do
      subject
      expect(controller.current_provider).to be_nil
    end

    context 'no mock saml' do
      before do
        allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return('false')
      end

      it 'redirects to the SAML sign_out URL' do
        subject
        expect(response).to redirect_to(idp_sign_out_provider_session_url(SAMLRequest: 1))
      end
    end

    context 'mock_saml' do
      before do
        allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return('true')
      end

      it 'redirects to providers root' do
        subject
        expect(response).to redirect_to(providers_root_url)
      end
    end
  end

  describe 'POST /providers/saml/auth', vcr: { cassette_name: 'provider_details_api_mock' } do
    let(:sample_provider_details) { { foo: 'bar' } }

    subject { post provider_session_path }

    before do
      allow_any_instance_of(Warden::Proxy).to receive(:authenticate!).and_return(provider)
    end

    it 'retrieves provider details' do
      expect(ProviderDetailsRetriever).to receive(:call).with(provider.username).and_call_original
      subject
    end

    it 'saves provider details' do
      expect(ProviderDetailsRetriever).to receive(:call).with(provider.username).and_return(sample_provider_details)
      expect { subject }.to change { provider.reload.details_response }.to(sample_provider_details.stringify_keys)
    end

    it 'does not use a worker' do
      expect(ProviderDetailsRetrieverWorker).not_to receive(:perform_async)
      subject
    end

    context 'provider already has some provider details' do
      let(:existing_details_response) { { foo: :bar } }

      it 'uses a worker' do
        ProviderDetailsRetrieverWorker.clear
        expect(ProviderDetailsRetrieverWorker).to receive(:perform_async).with(provider.id).and_call_original
        expect(ProviderDetailsRetriever).to receive(:call).with(provider.username).and_call_original
        subject
        ProviderDetailsRetrieverWorker.drain
      end
    end
  end
end
