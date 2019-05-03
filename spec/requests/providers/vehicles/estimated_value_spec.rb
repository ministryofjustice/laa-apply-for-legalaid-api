require 'rails_helper'

RSpec.describe Providers::Vehicles::EstimatedValuesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }
  let(:vehicle) { legal_aid_application.vehicle }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle/estimated_value' do
    subject do
      get providers_legal_aid_application_vehicles_estimated_value_path(legal_aid_application)
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/vehicle/estimated_value' do
    let(:estimated_value) { Faker::Commerce.price(2000..10_000) }
    let(:params) { { vehicle: { estimated_value: estimated_value } } }
    let(:next_url) { providers_legal_aid_application_vehicles_remaining_payments_path(legal_aid_application) }

    subject do
      patch(
        providers_legal_aid_application_vehicles_estimated_value_path(legal_aid_application),
        params: params
      )
    end

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.estimated_value).to eq(estimated_value)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
    end

    context 'without value' do
      let(:estimated_value) { '' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.estimated_value }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Enter the estimated value of the vehicle')
      end
    end

    context 'with a non-numeric value' do
      let(:estimated_value) { 'not a number' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.estimated_value }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Estimated value must be an amount of money, like 5,000')
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end
end
