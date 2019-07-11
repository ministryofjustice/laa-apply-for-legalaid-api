require 'rails_helper'

RSpec.describe ProceedingTypePopulator do
  describe '#call' do
    let(:seed_file) { Rails.root.join('db', 'seeds', 'proceeding_types.csv') }
    let(:proceeding_type) { ProceedingType.order('created_at ASC').first }

    it 'create instances from the seed file' do
      expect { described_class.call }.to change { ProceedingType.count }.by(seed_file.readlines.size - 1)
    end

    it 'creates an instance with correct data' do
      described_class.call
      expect(proceeding_type.code).to eq(CSV.read(seed_file, headers: true)[0][0])
    end

    context 'when a proceeding_type already exists' do
      let!(:proceeding_type) { create :proceeding_type, :with_real_data }
      it 'creates one less proceeding_code' do
        expect { described_class.call }.to change { ProceedingType.count }.by(seed_file.readlines.size - 2)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of proceeding_types' do
        expect {
          described_class.call
          described_class.call
        }.to change { ProceedingType.count }.by(seed_file.readlines.size - 1)
      end
    end
  end
end
