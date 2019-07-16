# TODO: Think about how we refactor this class to make it smaller
class LegalAidApplication < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include TranslatableModelAttribute
  include LegalAidApplicationStateMachine # States are defined here

  SHARED_OWNERSHIP_YES_REASONS = %w[partner_or_ex_partner housing_assocation_or_landlord friend_family_member_or_other_individual].freeze
  SHARED_OWNERSHIP_NO_REASONS = %w[no_sole_owner].freeze
  SHARED_OWNERSHIP_REASONS =  SHARED_OWNERSHIP_YES_REASONS + SHARED_OWNERSHIP_NO_REASONS
  SECURE_ID_DAYS_TO_EXPIRE = 7
  WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION = 10

  belongs_to :applicant, optional: true
  belongs_to :provider, optional: false
  belongs_to :office, optional: true
  has_many :application_proceeding_types, dependent: :destroy
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result, dependent: :destroy
  has_one :other_assets_declaration, dependent: :destroy
  has_one :savings_amount, dependent: :destroy
  has_one :merits_assessment, dependent: :destroy
  has_one :statement_of_case, dependent: :destroy
  has_one :respondent, dependent: :destroy
  has_one :latest_incident, -> { order(occurred_on: :desc) }, class_name: :Incident, dependent: :destroy
  has_many :legal_aid_application_transaction_types, dependent: :destroy
  has_many :transaction_types, through: :legal_aid_application_transaction_types
  has_many :dependants, dependent: :destroy
  has_many :ccms_submissions, class_name: 'CCMS::Submission', dependent: :destroy
  has_one :most_recent_ccms_submission, -> { order(:created_at) }, class_name: 'CCMS::Submission'
  has_one :vehicle, dependent: :destroy
  has_many :application_scope_limitations, dependent: :destroy
  has_many :scope_limitations, through: :application_scope_limitations, dependent: :destroy

  before_create :create_app_ref
  before_save :set_open_banking_consent_choice_at

  attr_reader :proceeding_type_codes
  validate :proceeding_type_codes_existence
  validates :provider, presence: true

  delegate :full_name, to: :applicant, prefix: true, allow_nil: true

  scope :latest, -> { order(created_at: :desc) }

  enum(
    own_home: {
      no: 'no'.freeze,
      mortgage: 'mortgage'.freeze,
      owned_outright: 'owned_outright'.freeze
    },
    _prefix: true
  )

  def bank_transactions
    return applicant.bank_transactions if Setting.mock_true_layer_data?

    set_transaction_period unless transaction_period_start_at? && transaction_period_finish_at?
    applicant.bank_transactions.where(
      happened_at: transaction_period_start_at..transaction_period_finish_at
    )
  end

  def generate_secure_id
    SecureData.create_and_store!(
      legal_aid_application: { id: id },
      expired_at: (Time.current + SECURE_ID_DAYS_TO_EXPIRE.days).end_of_day,
      # So each secure data payload is unique
      token: SecureRandom.hex
    )
  end

  def set_transaction_period
    update!(
      transaction_period_start_at: 3.months.ago.beginning_of_day,
      transaction_period_finish_at: Time.now.beginning_of_day
    )
  end

  def proceeding_type_codes=(codes)
    @proceeding_type_codes = codes
    self.proceeding_types = ProceedingType.where(code: codes)
  end

  def add_benefit_check_result
    benefit_check_response = BenefitCheckService.call(self)
    self.benefit_check_result ||= build_benefit_check_result
    benefit_check_result.update!(
      result: benefit_check_response.dig(:benefit_checker_status),
      dwp_ref: benefit_check_response.dig(:confirmation_ref)
    )
  end

  def applicant_receives_benefit?
    benefit_check_result.positive?
  end

  def benefit_check_result_needs_updating?
    return true unless benefit_check_result

    applicant_updated_after_benefit_check_result_updated?
  end

  def outstanding_mortgage?
    outstanding_mortgage_amount?
  end

  def shared_ownership?
    SHARED_OWNERSHIP_YES_REASONS.include?(shared_ownership)
  end

  def own_home?
    own_home.present? && !own_home_no?
  end

  def own_capital?
    own_home? || other_assets? || savings_amount?
  end

  def savings_amount?
    savings_amount.present? && savings_amount.positive?
  end

  def other_assets?
    other_assets_declaration.present? && other_assets_declaration.positive?
  end

  # Refactored into its own method because there may be multiple conditions in the future
  # which make it read only.
  def read_only?
    provider_submitted? || checking_citizen_answers?
  end

  def checking_answers?
    checking_client_details_answers? ||
      checking_citizen_answers? ||
      checking_passported_answers? ||
      checking_merits_answers? ||
      provider_checking_citizens_means_answers?
  end

  def submission_date
    transaction_period_finish_at.to_date
  end

  def opponents
    [Opponent.dummy_opponent]
  end

  def wage_slips
    [] # TODO: CCMS placeholder
  end

  def opponent_other_parties
    [Opponent.dummy_opponent]
  end

  def ccms_case_reference
    most_recent_ccms_submission.case_ccms_reference
  end

  def add_default_scope_limitation!
    if used_delegated_functions?
      add_default_delegated_functions_scope_limitation!
    else
      add_default_substantive_scope_limitation!
    end
  end

  def add_default_substantive_scope_limitation!
    ApplicationScopeLimitation.create!(
      legal_aid_application: self,
      scope_limitation: default_substantive_scope_limitation_for_first_proceeding_type,
      substantive: true
    )
  end

  def add_default_delegated_functions_scope_limitation!
    ApplicationScopeLimitation.create!(
      legal_aid_application: self,
      scope_limitation: default_delegated_functions_scope_limitation_for_first_proceeding_type,
      substantive: false
    )
  end

  def default_substantive_scope_limitation_for_first_proceeding_type
    proceeding_types.first.default_substantive_scope_limitation
  end

  def default_delegated_functions_scope_limitation_for_first_proceeding_type
    proceeding_types.first.default_delegated_functions_scope_limitation
  end

  def substantive_scope_limitation
    application_scope_limitations.find_by(substantive: true).scope_limitation
  end

  def delegated_functions_scope_limitation
    application_scope_limitations.find_by(substantive: false)&.scope_limitation
  end

  def reset_delegated_functions
    self.used_delegated_functions = false
    self.used_delegated_functions_on = nil
  end

  def reset_proceeding_types!
    proceeding_types.clear
    scope_limitations.clear
    reset_delegated_functions
  end

  private

  def applicant_updated_after_benefit_check_result_updated?
    benefit_check_result.updated_at < applicant.updated_at
  end

  def proceeding_type_codes_existence
    return unless proceeding_type_codes.present?

    errors.add(:proceeding_type_codes, :invalid) if proceeding_types.size != proceeding_type_codes.size
  end

  def create_app_ref
    self.application_ref = ReferenceNumberCreator.call unless application_ref.present?
  end

  def set_open_banking_consent_choice_at
    self.open_banking_consent_choice_at = Time.current if will_save_change_to_open_banking_consent?
  end
end
