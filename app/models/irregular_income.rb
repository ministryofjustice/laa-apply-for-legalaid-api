class IrregularIncome < ApplicationRecord
  belongs_to :legal_aid_application

  PERMITTED_TYPES = /\Astudent_loan\z/.freeze
  PERMITTED_FREQUENCY = /\Aannual\z/.freeze

  validates :income_type, format: { with: PERMITTED_TYPES }
  validates :frequency, format: { with: PERMITTED_FREQUENCY }
end
