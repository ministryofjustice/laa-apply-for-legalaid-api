class CashTransaction < ApplicationRecord
  # The CashTransaction records the monthly amount paid or received by an applicant in cash for a particular month
  # for a particular TransactionType.  These records always come in threes, representing each of the last three months
  # before an application was made.  The transaction date is set to the first of the month.

  belongs_to :legal_aid_application
  belongs_to :transaction_type

  validates :month_number, inclusion: { in: [1, 2, 3] }

  scope :credits, -> do
    includes(:transaction_type)
      .where(transaction_types: { operation: :credit })
  end

  scope :debits, -> do
    includes(:transaction_type)
      .where(transaction_types: { operation: :debit })
  end

  scope :by_parent_transaction_type, -> do
    includes(:transaction_type)
      .where.not(transaction_type_id: nil)
      .group_by(&:parent_transaction_type)
  end

  scope :for_transaction_type, ->(tt_id) { where(transaction_type_id: tt_id).order(transaction_date: :asc) }

  def self.amounts
    group(:transaction_type_id).sum(:amount)
  end

  def self.amounts_for_application(application_id)
    where(legal_aid_application_id: application_id)
      .includes(:transaction_type)
      .group(:name)
      .sum(:amount)
  end

  def period_start
    transaction_date.beginning_of_month.strftime('%d %b')
  end

  def period_end
    transaction_date.end_of_month.strftime('%d %b')
  end

  def parent_transaction_type
    transaction_type.parent_or_self
  end
end
