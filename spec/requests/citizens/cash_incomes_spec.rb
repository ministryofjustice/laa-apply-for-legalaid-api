require 'rails_helper'

RSpec.describe Citizens::CashIncomesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }
  let!(:benefits) { create :transaction_type, :benefits }
  let!(:maintenance_in) { create :transaction_type, :maintenance_in }
  let(:next_flow_step) { flow_forward_path }

  before { legal_aid_application.set_transaction_period }

  describe 'GET /citizens/cash_income' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_cash_income_path
    end

    it 'shows the page' do
      get citizens_cash_income_path
      expect(response.body).to include(I18n.t('citizens.cash_incomes.show.page_heading'))
    end
  end

  describe 'PATCH /citizens/cash_income' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      patch citizens_cash_income_path, params: params
    end

    context 'valid update' do
      context 'valid params' do
        let(:params) { valid_params }

        it 'redirects to new action' do
          expect(response).to redirect_to(next_flow_step)
        end

        it 'updates the model attribute for no cash income to false' do
          expect(legal_aid_application.reload.no_cash_income).to be(false)
        end
      end

      context 'none of the above' do
        let(:params) { nothing_selected }

        it 'redirects to new action' do
          expect(response).to redirect_to(next_flow_step)
        end

        it 'updates the model attribute for no cash income to true' do
          expect(legal_aid_application.reload.no_cash_income).to eq(true)
        end
      end
    end

    context 'invalid update' do
      context 'invalid params' do
        let(:params) { invalid_params }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'shows an error for no amount entered' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_income.blank', category: 'in maintenance',
                                                                                         month: (Time.zone.today - 1.month).strftime('%B')))
        end

        it 'shows an error for an invalid amount' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_income.invalid_type'))
        end

        it 'shows an error for a negtive amount' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_income.negative'))
        end

        it 'shows an error for an amount with too many decimals' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_income.too_many_decimals'))
        end
      end

      context 'no params' do
        let(:params) { { aggregated_cash_income: { check_box_benefits: '' } } }

        it 'shows an error if nothing selected' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.aggregated_cash_income.credits.attributes.cash_income.blank'))
        end
      end
    end

    def nothing_selected
      {
        aggregated_cash_income: {
          check_box_benefits: '',
          none_selected: 'true'
        }
      }
    end

    def valid_params
      {
        aggregated_cash_income: {
          check_box_benefits: 'true',
          benefits1: '1',
          benefits2: '2',
          benefits3: '3',
          none_selected: ''
        }
      }
    end

    def invalid_params
      {
        aggregated_cash_income: {
          check_box_benefits: 'true',
          benefits1: '1.11111',
          benefits2: '$',
          benefits3: '-1',
          check_box_maintenance_in: 'true',
          maintenance_in1: '',
          maintenance_in2: '',
          maintenance_in3: ''
        }
      }
    end
  end
end
