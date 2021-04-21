require 'rails_helper'

RSpec.describe 'provider proceedings before the court requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types }
  let(:application_proceeding_type) { legal_aid_application.lead_application_proceeding_type }
  let(:provider) { legal_aid_application.provider }

  describe 'GET providers/application_proceeding_type/:id/proceedings_before_the_court' do
    subject { get providers_application_proceeding_type_proceedings_before_the_court_path(application_proceeding_type) }

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
      end
    end
  end

  describe 'PATCH providers/application_proceeding_type/:id/proceedings_before_the_court' do
    subject { patch providers_application_proceeding_type_proceedings_before_the_court_path(application_proceeding_type), params: params.merge(submit_button) }
    let(:proceedings_before_the_court) { true }
    let(:details_of_proceedings_before_the_court) { Faker::Lorem.paragraph }
    let(:params) do
      {
        proceeding_merits_task_chances_of_success: {
          proceedings_before_the_court: proceedings_before_the_court.to_s,
          details_of_proceedings_before_the_court: details_of_proceedings_before_the_court
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates the record' do
          expect(application_proceeding_type.chances_of_success.reload.proceedings_before_the_court).to eq(proceedings_before_the_court)
          expect(application_proceeding_type.chances_of_success.reload.details_of_proceedings_before_the_court).to eq(details_of_proceedings_before_the_court)
        end

        it 'redirects to the next page' do
          expect(response).to redirect_to providers_legal_aid_application_statement_of_case_path(legal_aid_application)
        end

        context 'invalid params - details missing' do
          let(:proceedings_before_the_court) { true }
          let(:details_of_proceedings_before_the_court) { '' }

          it 'returns http_success' do
            expect(response).to have_http_status(:ok)
          end

          it 'the response includes the error message' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.proceeding_merits_task/chances_of_success.attributes.details_of_proceedings_before_the_court.blank'))
          end
        end
      end

      context 'Save as draft button pressed' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the record' do
          expect(application_proceeding_type.chances_of_success.reload.proceedings_before_the_court).to eq(proceedings_before_the_court)
          expect(application_proceeding_type.chances_of_success.reload.details_of_proceedings_before_the_court).to eq(details_of_proceedings_before_the_court)
        end

        it 'redirects to provider applications home page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'nothing specified' do
          let(:proceedings_before_the_court) { nil }
          let(:details_of_proceedings_before_the_court) { nil }

          it "redirects provider to provider's applications page" do
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end
        end

        context 'invalid params - details missing' do
          let(:proceedings_before_the_court) { true }
          let(:details_of_proceedings_before_the_court) { nil }

          it "redirects provider to provider's applications page" do
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end
        end
      end
    end
  end
end
