module Banking
  class BankTransactionBalanceCalculator
    delegate :applicant, to: :legal_aid_application
    delegate :bank_providers, to: :applicant

    attr_reader :legal_aid_application

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      bank_providers.each { |bank| process_bank(bank) }
    end

    private

    def process_bank(bank)
      bank.bank_accounts.each { |acct| process_account(acct) }
    end

    def process_account(acct)
      txs = acct.bank_transactions.most_recent_first
      calculated_balance = acct.balance
      txs.each do |tx|
        tx.update(running_balance: format('%.2f', calculated_balance))
        calculated_balance -= tx.amount
      end
    end
  end
end
