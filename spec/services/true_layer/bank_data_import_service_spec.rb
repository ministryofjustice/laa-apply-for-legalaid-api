require 'rails_helper'

RSpec.describe TrueLayer::BankDataImportService do
  let(:token) { SecureRandom.hex }
  let(:applicant) { create :applicant }
  let(:bank_provider) { applicant.bank_providers.find_by(token: token) }
  let(:mock_data) { TrueLayerHelpers::MOCK_DATA }

  subject { described_class.new(applicant: applicant, token: token) }

  describe '#call' do
    before { stub_true_layer }

    it 'imports the bank provider' do
      expect { subject.call }.to change { applicant.bank_providers.count }.by(1)
      expect(bank_provider.credentials_id).to eq(mock_data[:provider][:credentials_id])
    end

    it 'imports the bank accounts' do
      expect { subject.call }.to change { BankAccount.count }.by(mock_data[:accounts].count)
      mock_account_ids = mock_data[:accounts].pluck(:account_id).sort
      expect(bank_provider.bank_accounts.pluck(:true_layer_id).sort).to eq(mock_account_ids)
    end

    it 'imports the account balances' do
      subject.call
      mock_account_balances = mock_data[:accounts].map { |a| a[:balance][:current].to_s }.sort
      account_balances = bank_provider.bank_accounts.map { |a| a.balance.to_s }.sort
      expect(account_balances).to eq(mock_account_balances)
    end

    it 'imports the bank account holders' do
      expect { subject.call }.to change { BankAccountHolder.count }.by(mock_data[:account_holders].count)
    end

    it 'imports the transactions' do
      mock_transaction_ids = mock_data[:accounts].flat_map { |a| a[:transactions].map { |t| t[:transaction_id] } }.sort
      expect { subject.call }.to change { BankTransaction.count }.by(mock_transaction_ids.count)

      transaction_ids = bank_provider.bank_accounts.flat_map(&:bank_transactions).pluck(:true_layer_id).sort
      expect(transaction_ids).to eq(mock_transaction_ids)
    end
  end
end
