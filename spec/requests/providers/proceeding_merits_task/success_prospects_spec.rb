require 'rails_helper'

module Providers
  module ProceedingMeritsTask
    RSpec.describe SuccessProspectsController, type: :request do
      let!(:legal_aid_application) { create :legal_aid_application }
      let!(:application_proceeding_type) { create :application_proceeding_type, :with_chances_of_success, legal_aid_application: legal_aid_application }
      let(:provider) { legal_aid_application.provider }

      describe 'GET /providers/application_proceeding_type/:id/success_prospects' do
        subject { get providers_application_proceeding_type_success_prospects_path(application_proceeding_type) }

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

      describe 'PATCH providers/application_proceeding_type/:id/success_prospects' do
        subject { patch providers_application_proceeding_type_success_prospects_path(application_proceeding_type), params: params.merge(submit_button) }
        let(:success_prospect) { 'marginal' }
        let(:success_prospect_details) { Faker::Lorem.paragraph }
        let(:params) do
          {
            proceeding_merits_task_chances_of_success: {
              success_prospect: success_prospect.to_s,
              success_prospect_details: success_prospect_details
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
              expect(application_proceeding_type.chances_of_success.reload.success_prospect).to eq(success_prospect)
              expect(application_proceeding_type.chances_of_success.reload.success_prospect_details).to eq(success_prospect_details)
            end

            it 'redirects to the next page' do
              expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
            end
          end

          context 'Save as draft button pressed' do
            let(:submit_button) do
              {
                draft_button: 'Save as draft'
              }
            end

            it 'updates the record' do
              expect(application_proceeding_type.chances_of_success.reload.success_prospect).to eq(success_prospect)
              expect(application_proceeding_type.chances_of_success.reload.success_prospect_details).to eq(success_prospect_details)
            end

            it 'redirects to provider applications home page' do
              expect(response).to redirect_to providers_legal_aid_applications_path
            end

            context 'nothing specified' do
              let(:success_prospect) { nil }
              let(:success_prospect_details) { nil }

              it 'redirects to provider applications home page' do
                expect(response).to redirect_to providers_legal_aid_applications_path
              end
            end
          end
        end
      end
    end
  end
end
