require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountHoldersService do
  let(:bank_provider) { create :bank_provider }
  let(:api_client) { TrueLayer::ApiClient.new(bank_provider.token) }

  subject { described_class.new(api_client, bank_provider) }

  describe '#call' do
    let(:mock_account_holder_1) { TrueLayerHelpers::MOCK_DATA[:account_holders][0] }
    let(:mock_account_holder_2) { TrueLayerHelpers::MOCK_DATA[:account_holders][1] }
    let(:bank_account_holder_1) { bank_provider.bank_account_holders.find_by(full_name: mock_account_holder_1[:full_name]) }
    let(:bank_account_holder_2) { bank_provider.bank_account_holders.find_by(full_name: mock_account_holder_2[:full_name]) }
    let!(:existing_bank_account_holder) { create :bank_account_holder, bank_provider: bank_provider }

    context 'request is successful' do
      before do
        stub_true_layer_account_holders
      end

      it 'adds the bank account holders to the bank_provider' do
        subject.call
        expect(bank_account_holder_1.full_name).to eq(mock_account_holder_1[:full_name])
        expect(bank_account_holder_1.true_layer_response).to eq(mock_account_holder_1.deep_stringify_keys)
        expected_full_address = mock_account_holder_1[:addresses]&.map do |address|
                                  address.values.join(', ')
                                end&.join('; ')
        expect(bank_account_holder_1.full_address).to eq(expected_full_address)
        expect(bank_account_holder_1.date_of_birth).to eq(mock_account_holder_1[:date_of_birth].to_date)
        expect(bank_account_holder_2.full_name).to eq(mock_account_holder_2[:full_name])
      end

      it 'removes existing bank account holders' do
        subject.call
        expect { existing_bank_account_holder.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'leaves the list of bank account holders empty' do
        expect { subject.call }.to change { bank_provider.bank_account_holders.count }.to(0)
      end
    end
  end
end
