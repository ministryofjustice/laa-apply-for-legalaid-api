require 'rails_helper'

RSpec.describe 'providers legal aid application requests', type: :request do
  describe 'GET /providers/applications' do
    let(:legal_aid_application) { create :legal_aid_application }
    let(:provider) { legal_aid_application.provider }
    let(:other_provider) { create(:provider) }
    let(:other_provider_in_same_firm) { create :provider, firm: provider.firm }
    let(:params) { {} }
    subject { get providers_legal_aid_applications_path(params) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      context 'provider is not a portal_enabled user' do
        let(:provider) { create :provider, :without_portal_enabled }

        it 'redirects to error page' do
          subject
          expect(response).to redirect_to(error_path(:access_denied))
        end
      end

      it "includes a link to the legal aid application's default start path" do
        subject
        expect(response.body).to include(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end

      it 'includes a link to the search page' do
        subject
        expect(response.body).to include(search_providers_legal_aid_applications_path)
      end

      context 'when legal_aid_application current path set' do
        let!(:other_provider_in_same_firm) { create :provider, firm: provider.firm }
        let!(:legal_aid_application) { create :legal_aid_application, provider_step: :applicant_details }
        let!(:other_provider_in_same_firm_application) { create :legal_aid_application, provider: other_provider_in_same_firm, provider_step: :applicant_details }
        let!(:other_provider_application) { create :legal_aid_application, provider: other_provider, provider_step: :applicant_details }

        it "includes a link to the legal aid application's current path" do
          subject
          expect(response.body).to include(providers_legal_aid_application_applicant_details_path(legal_aid_application))
        end

        it 'includes a link to the application of the other provider in the same firm' do
          subject
          expect(response.body).to include(providers_legal_aid_application_applicant_details_path(other_provider_in_same_firm_application))
        end

        it 'does not include a link to the application of the provider in a different firm' do
          subject
          expect(response.body).not_to include(providers_legal_aid_application_applicant_details_path(other_provider_application))
        end
      end

      context 'when legal_aid_application current path is unknown' do
        let!(:legal_aid_application) { create :legal_aid_application, provider_step: :unknown }

        it 'links to start of journey' do
          subject
          start_path = Flow::KeyPoint.path_for(
            journey: :providers,
            key_point: :edit_applicant,
            legal_aid_application: legal_aid_application
          )
          expect(response.body).to include(start_path)
        end
      end

      context 'with pagination' do
        it 'shows current total information' do
          subject
          expect(response.body).to include('Showing 1 of 1')
        end

        it 'does not show navigation links' do
          subject
          expect(parsed_response_body.css('.pagination-container nav')).to be_empty
        end

        context 'and more applications than page size' do
          # Creating 4 additional means there are now 5 applications
          let!(:additional_applications) { create_list :legal_aid_application, 4, provider: provider }
          let(:params) { { page_size: 3 } }

          it 'show page information' do
            subject
            expect(response.body).to include('Showing 1 - 3 of 5')
          end

          it 'shows pagination' do
            subject
            expect(parsed_response_body.css('.pagination-container nav').text).to match(/Previous\s+1\s+2\s+Next/)
          end
        end

        context 'when an application has been discarded' do
          before { create :legal_aid_application, :discarded, provider: provider }

          it 'is excluded from the list' do
            subject
            expect(response.body).to include('Showing 1 of 1')
          end
        end
      end
    end

    context 'when another provider is authenticated' do
      before do
        login_as other_provider
        subject
      end

      it 'displays no results' do
        expect(response.body).to include('No results')
      end
    end
  end

  describe 'GET /providers/applications/search' do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:provider) { legal_aid_application.provider }
    let(:other_provider) { create(:provider) }
    let(:other_provider_in_same_firm) { create :provider, firm: provider.firm }
    let(:params) { {} }
    subject { get search_providers_legal_aid_applications_path(params) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      it 'does not show any application' do
        subject
        expect(response.body).not_to include(legal_aid_application.application_ref)
      end

      context 'when searching for a Substantive application' do
        let(:search_term) { legal_aid_application.application_ref }
        let(:params) { { search_term: search_term } }

        it 'shows the application' do
          subject
          expect(unescaped_response_body).to include(legal_aid_application.applicant.last_name)
          expect(unescaped_response_body).to include('Substantive')
        end

        it 'logs the search' do
          expected_log = "Applications search: Provider #{provider.id} searched '#{search_term}' : 1 results."
          allow(Rails.logger).to receive(:info).at_least(:once)
          subject
          expect(Rails.logger).to have_received(:info).with(expected_log).once
        end
      end

      context 'when searching for an incomplete Emergency application with a substantive due date' do
        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_applicant, used_delegated_functions: true,
                                  substantive_application_deadline_on: Time.zone.today + 3.days
        end
        let(:search_term) { legal_aid_application.application_ref }
        let(:params) { { search_term: search_term } }

        it 'shows the application' do
          subject
          expect(unescaped_response_body).to include('Emergency')
          expect(unescaped_response_body).to match(/Substantive due: \d{1,2} [ADFJMNOS]\w* \d{4}/)
          expect(legal_aid_application.summary_state).to eq(:in_progress)
        end
      end

      context 'when searching for an Emergency application with a substantiuve due date and the application has been submitted' do
        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_applicant,
                 :with_everything,
                 merits_submitted_at: Time.zone.today,
                 used_delegated_functions: true,
                 substantive_application_deadline_on: Time.zone.today + 3.days
        end
        let(:search_term) { legal_aid_application.application_ref }
        let(:params) { { search_term: search_term } }

        it 'shows the application' do
          subject
          expect(unescaped_response_body).to include('Emergency')
          expect(legal_aid_application.substantive_application_deadline_on).not_to be_nil
          expect(unescaped_response_body).not_to match(/Substantive due: \d{1,2} [ADFJMNOS]\w* \d{4}/)
          expect(legal_aid_application.summary_state).to eq(:submitted)
        end
      end

      context 'when searching for the application and not result is found' do
        let(:params) { { search_term: 'something' } }

        it 'does not show the application' do
          subject
          expect(unescaped_response_body).not_to include(legal_aid_application.application_ref)
        end
      end

      context 'when not entering search criteria' do
        let(:params) { { search_term: '' } }

        it 'shows an error' do
          subject
          expect(response.body).to include(I18n.t('providers.legal_aid_applications.search.error'))
        end
      end
    end

    context 'when another provider is authenticated and search the application' do
      let(:params) { { search_term: legal_aid_application.application_ref } }
      before do
        login_as other_provider
        subject
      end

      it 'does not show the application' do
        expect(unescaped_response_body).not_to include(legal_aid_application.applicant.last_name)
      end
    end
  end

  describe 'POST /providers/applications' do
    subject { post providers_legal_aid_applications_path }
    let(:legal_aid_application) { LegalAidApplication.last }

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
      end

      it 'does not create a new application record' do
        expect { subject }.not_to change { LegalAidApplication.count }
      end

      it 'redirects to new applicant page ' do
        subject
        expect(response).to redirect_to(new_providers_applicant_path)
      end
    end
  end
end
