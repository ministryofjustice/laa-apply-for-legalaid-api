class Dependant < ApplicationRecord
  default_scope { order(number: :asc) }

  belongs_to :legal_aid_application

  DEFAULT_VALUES = {
    in_full_time_education: false,
    relationship: 'child_relative',
    monthly_income: 0.0,
    assets_value: 0.0
  }.freeze

  enum relationship: {
    child_relative: 'child_relative'.freeze,
    adult_relative: 'adult_relative'.freeze
  }

  def ordinal_number
    I18n.t("generic.ordinal_number.#{number}", default: number.ordinalize)
  end

  def age
    AgeCalculator.call(date_of_birth, legal_aid_application.calculation_date)
  end

  def over_fifteen?
    age > 15
  end

  def eighteen_or_less?
    age < 19
  end

  def fifteen_or_less?
    age < 16
  end

  def sixteen_or_over?
    age > 15
  end

  def as_json
    {
      date_of_birth: date_of_birth.strftime('%Y-%m-%d'),
      relationship: value_or_default(:relationship),
      monthly_income: value_or_default(:monthly_income),
      in_full_time_education: value_or_default(:in_full_time_education),
      assets_value: value_or_default(:assets_value)
    }
  end

  def ccms_relationship_to_client
    return 'Dependant adult' if adult_relative?

    return 'Child aged 15 and under' if fifteen_or_less?

    'Child aged 16 and over'
  end

  def assets_over_threshold?
    return false if assets_value.nil?

    assets_value > 8_000.0
  end

  private

  def value_or_default(attribute)
    __send__(attribute) || DEFAULT_VALUES[attribute]
  end
end
