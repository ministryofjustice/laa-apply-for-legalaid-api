require 'rails_helper'

RSpec.describe LegalAidApplications::CalculationDateService do
  let(:used_delegated_functions_on) { Faker::Date.backward }
  let(:transaction_period_finish_on) { Faker::Date.backward }
  let(:merits_submitted_at) { Faker::Date.backward }
  let(:applicant_receives_benefit) { Faker::Boolean.boolean }
  let(:benefit_check_result) { create :benefit_check_result, result: applicant_receives_benefit ? 'yes' : 'no' }
  let(:legal_aid_application) do
    create :legal_aid_application,
           used_delegated_functions_on: used_delegated_functions_on,
           used_delegated_functions: used_delegated_functions,
           transaction_period_finish_on: transaction_period_finish_on,
           benefit_check_result: benefit_check_result,
           merits_submitted_at: merits_submitted_at
  end

  subject { described_class.call(legal_aid_application) }

  context 'delegated functions are used' do
    let(:used_delegated_functions) { true }

    it 'returns date delegated functions were used' do
      expect(subject).to eq(used_delegated_functions_on)
    end
  end

  context 'delegated functions are not used' do
    let(:used_delegated_functions) { false }

    context 'applicant receives benefits' do
      let(:applicant_receives_benefit) { true }

      it 'returns date of submission' do
        expect(subject).to eq(merits_submitted_at)
      end
    end

    context 'applicant does not receive benefits' do
      let(:applicant_receives_benefit) { false }

      it 'returns most recent date bank transactions downloaded' do
        expect(subject).to eq(transaction_period_finish_on)
      end
    end
  end
end
