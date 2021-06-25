require 'rails_helper'

RSpec.describe Providers::LimitationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types }
  let(:proceeding_type) { legal_aid_application.proceeding_types.first }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/limitations' do
    subject { get providers_legal_aid_application_limitations_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include(I18n.t('providers.limitations.legacy_proceeding_types.h1-heading'))
      end
    end

    context 'when the multiple proceedings flag is off' do
      before do
        Setting.setting.update!(allow_multiple_proceedings: false)
        login_as provider
        subject
      end

      it 'shows the correct text' do
        expect(unescaped_response_body).to include(I18n.t('providers.limitations.legacy_proceeding_types.substantive_certificate_covered'))
      end

      it 'does not have a details section' do
        expect(parsed_response_body.css('details')).to be_empty
      end

      context 'when delegated functions have been used' do
        let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_delegated_functions }
        let(:proceeding_type) { legal_aid_application.proceeding_types.first }
        let(:provider) { legal_aid_application.provider }

        it 'shows the correct text' do
          expect(unescaped_response_body).to include(I18n.t('providers.limitations.legacy_proceeding_types.cost_override_question'))
        end
      end
    end

    context 'when the multiple proceedings flag is on' do
      before do
        Setting.setting.update!(allow_multiple_proceedings: true)
        login_as provider
        subject
      end

      it 'puts scope limitations in a details section' do
        expect(parsed_response_body.css('details').text).to include(I18n.t('providers.limitations.multi_proceeding_types.substantive_certificate'))
        expect(unescaped_response_body).to_not include(I18n.t('providers.limitations.multi_proceeding_types_with_df.cost_override_question'))
      end

      context 'when delegated functions have been used' do
        let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_delegated_functions }
        let(:proceeding_type) { legal_aid_application.proceeding_types.first }
        let(:provider) { legal_aid_application.provider }

        it 'shows the correct text' do
          expect(unescaped_response_body).to include(I18n.t('providers.limitations.multi_proceeding_types_with_df.cost_override_question'))
        end
      end
    end

    context '#pre_dwp_check?' do
      it 'returns true' do
        expect(described_class.new.pre_dwp_check?).to be true
      end
    end
  end

  describe 'PATCH /providers/applications/:id/limitations' do
    before do
      login_as provider
    end

    context 'with multiple proceedings disabled' do
      subject { patch providers_legal_aid_application_limitations_path(legal_aid_application) }

      it 'redirects to next page' do
        expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
      end
    end

    context 'with multiple proceedings enabled and delegated functions have been used' do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_delegated_functions }
      let(:proceeding_type) { legal_aid_application.proceeding_types.first }
      let(:provider) { legal_aid_application.provider }

      before do
        Setting.setting.update!(allow_multiple_proceedings: true)
      end

      subject { patch providers_legal_aid_application_limitations_path(legal_aid_application, params: params) }

      context 'with the correct params' do
        context 'when no limit extension is requested' do
          let(:params) do
            { legal_aid_application: { emergency_cost_override: false } }
          end

          it 'redirects to next page' do
            expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
          end
        end

        context 'when a limit extension is requested' do
          let(:params) do
            { legal_aid_application: { emergency_cost_override: true,
                                       emergency_cost_requested: 3_000.0,
                                       emergency_cost_reasons: 'this is just a test' } }
          end

          it 'redirects to next page' do
            expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
          end
        end
      end

      context 'with the incorrect params' do
        let(:params) do
          { legal_aid_application: { emergency_cost_override: true,
                                     emergency_cost_requested: 'non numeric response',
                                     emergency_cost_reasons: 'this is just a test' } }
        end

        it 'should display an error' do
          subject
          expect(response.body).to match('govuk-error-summary')
          expect(response.body).to include('Cost limit must be an amount of money, like 2,500')
        end
      end
    end
  end
end
