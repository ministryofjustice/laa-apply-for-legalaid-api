require 'rails_helper'

RSpec.describe ProceedingMeritsTask::ChancesOfSuccess, type: :model do
  describe '#pretty_success_propsect' do
    let(:chances_of_success) { create :chances_of_success, :with_application_proceeding_type, success_prospect: prospect }

    context 'likely' do
      let(:prospect) { 'likely' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Likely (>50%)'
      end
    end

    context 'likely' do
      let(:prospect) { 'likely' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Likely (>50%)'
      end
    end

    context 'marginal' do
      let(:prospect) { 'marginal' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Marginal (45-49%)'
      end
    end

    context 'poor' do
      let(:prospect) { 'poor' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Poor (<45%)'
      end
    end

    context 'borderline' do
      let(:prospect) { 'borderline' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Borderline'
      end
    end

    context 'not_known' do
      let(:prospect) { 'not_known' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Uncertain'
      end
    end
  end
end
