require 'rails_helper'

RSpec.describe Citizens::CashOutgoingsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }
  let!(:child_care) { create :transaction_type, :child_care }
  let!(:maintenance_out) { create :transaction_type, :maintenance_out }
  let(:next_flow_step) { flow_forward_path }

  before { legal_aid_application.set_transaction_period }

  describe 'GET /citizens/cash_outgoings' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_cash_outgoing_path
    end

    it 'shows the page' do
      get citizens_cash_outgoing_path
      expect(response.body).to include(I18n.t('citizens.cash_outgoings.show.page_heading'))
    end
  end

  describe 'PATCH /citizens/cash_outgoing' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      patch citizens_cash_outgoing_path, params: params
    end

    context 'valid update' do
      context 'valid params' do
        let(:params) { valid_params }

        it 'redirects to new action' do
          expect(response).to redirect_to(next_flow_step)
        end

        it 'updates the model attribute for no cash outgoings to false' do
          expect(legal_aid_application.reload.no_cash_outgoings).to be(false)
        end
      end

      context 'none of the above' do
        let(:params) { nothing_selected }

        it 'redirects to new action' do
          expect(response).to redirect_to(next_flow_step)
        end

        it 'updates the model attribute for no cash outgoings to true' do
          expect(legal_aid_application.reload.no_cash_outgoings).to eq(true)
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
          expected_month = (Time.zone.today - 1.month).strftime('%B')
          expect(response.body).to include(I18n.t('errors.aggregated_cash_outgoings.blank', category: 'in maintenance', month: expected_month))
        end

        it 'shows an error for an invalid amount' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_outgoings.invalid_type'))
        end

        it 'shows an error for a negtive amount' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_outgoings.negative'))
        end

        it 'shows an error for an amount with too many decimals' do
          expect(response.body).to include(I18n.t('errors.aggregated_cash_outgoings.too_many_decimals'))
        end
      end

      context 'no params' do
        let(:params) { { aggregated_cash_outgoings: { check_box_child_care: '' } } }

        it 'shows an error if nothing selected' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.aggregated_cash_outgoings.debits.attributes.cash_outgoings.blank'))
        end
      end
    end

    def nothing_selected
      {
        aggregated_cash_outgoings: {
          check_box_child_care: '',
          none_selected: 'true'
        }
      }
    end

    def valid_params
      {
        aggregated_cash_outgoings: {
          check_box_child_care: 'true',
          child_care1: '1',
          child_care2: '2',
          child_care3: '3',
          none_selected: ''
        }
      }
    end

    def invalid_params
      {
        aggregated_cash_outgoings: {
          check_box_child_care: 'true',
          child_care1: '1.11111',
          child_care2: '$',
          child_care3: '-1',
          check_box_maintenance_out: 'true',
          maintenance_out1: '',
          maintenance_out2: '',
          maintenance_out3: ''
        }
      }
    end
  end
end
