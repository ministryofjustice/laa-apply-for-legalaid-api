require 'rails_helper'

module Banking
  RSpec.describe BankTransactionBalanceCalculator do
    let(:application) { create :legal_aid_application, :with_applicant }
    let(:applicant) { application.applicant }
    let(:bank) { create :bank_provider, applicant: applicant }
    let(:acct1) { create :bank_account, bank_provider: bank, balance: 733.44 }
    let(:acct2) { create :bank_account, bank_provider: bank, balance: 2.36 }

    subject { described_class.call(application) }

    before do
      populate_all_transactions
      subject
    end

    describe '.call' do
      it 'updates the balances on acct1' do
        txs = acct1.bank_transactions.most_recent_first
        expect(txs.map(&:running_balance).map(&:to_f)).to eq [733.44, 634.78, 671.05, 746.27]
      end

      it 'updates the balances on acct2' do
        txs = acct2.bank_transactions.most_recent_first
        expect(txs.map(&:running_balance).map(&:to_f)).to eq [2.36, -96.3, -60.03, 15.19]
      end
    end

    def populate_all_transactions
      populate_transactions(acct1, acct1_tx_seed_data)
      populate_transactions(acct2, acct2_tx_seed_data)
    end

    def populate_transactions(bank_account, seed_data)
      seed_data.each do |row|
        create(:bank_transaction,
               bank_account: bank_account,
               happened_at: Time.parse(row[0]).in_time_zone,
               created_at: Time.parse(row[1]).in_time_zone,
               operation: row[2],
               amount: row[3])
      end
    end

    def acct1_tx_seed_data
      # happened_at, created_at, operation, amount
      [
        ['2021-01-05T01:00:00',  '2021-01-25T10:05:43', :credit, 98.66],
        ['2021-01-05T01:00:00',  '2021-01-25T10:05:42', :debit, -36.27],
        ['2021-01-03T01:00:00',  '2021-01-25T10:05:43', :debit, -75.22],
        ['2021-01-02T01:00:00',  '2021-01-25T10:05:43', :credit, -93.66]
      ]
    end

    def acct2_tx_seed_data
      # happened_at, created_at, operation, amount
      [
        ['2021-01-05T01:00:00',  '2021-01-25T10:05:43', :credit, 98.66],
        ['2021-01-05T01:00:00',  '2021-01-25T10:05:42', :debit, -36.27],
        ['2021-01-03T01:00:00',  '2021-01-25T10:05:43', :debit, -75.22],
        ['2021-01-02T01:00:00',  '2021-01-25T10:05:43', :credit, -93.66]
      ]
    end
  end
end
