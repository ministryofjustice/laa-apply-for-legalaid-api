class LegalAidApplication < ApplicationRecord
  include TranslatableModelAttribute
  include Discard::Model
  include DelegatedFunctions

  SHARED_OWNERSHIP_YES_REASONS = %w[partner_or_ex_partner housing_assocation_or_landlord friend_family_member_or_other_individual].freeze
  SHARED_OWNERSHIP_NO_REASONS = %w[no_sole_owner].freeze
  SHARED_OWNERSHIP_REASONS =  SHARED_OWNERSHIP_YES_REASONS + SHARED_OWNERSHIP_NO_REASONS
  SECURE_ID_DAYS_TO_EXPIRE = 7
  WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION = 20
  CCMS_SUBMITTED_STATES = %w[generating_reports submitting_assessment assessment_submitted].freeze
  POLICY_DISREGARDS_START_DATE = Rails.configuration.x.policy_disregards_start_date

  belongs_to :applicant, optional: true, dependent: :destroy
  belongs_to :provider, optional: false
  belongs_to :office, optional: true
  has_many :application_proceeding_types, -> { order(:created_at) }, dependent: :destroy
  has_many :chances_of_success, through: :application_proceeding_types
  has_many :attachments, dependent: :destroy
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result, dependent: :destroy
  has_one :other_assets_declaration, dependent: :destroy
  has_one :savings_amount, dependent: :destroy
  has_one :statement_of_case, class_name: 'ApplicationMeritsTask::StatementOfCase', dependent: :destroy
  has_one :gateway_evidence, dependent: :destroy
  has_one :opponent, class_name: 'ApplicationMeritsTask::Opponent', dependent: :destroy
  has_one :latest_incident, -> { order(occurred_on: :desc) }, class_name: 'ApplicationMeritsTask::Incident', inverse_of: :legal_aid_application, dependent: :destroy
  has_many :attempts_to_settles, class_name: 'ProceedingMeritsTask::AttemptsToSettle', through: :application_proceeding_types
  has_many :legal_aid_application_transaction_types, dependent: :destroy
  has_many :transaction_types, through: :legal_aid_application_transaction_types
  has_many :cash_transactions, dependent: :destroy
  has_many :irregular_incomes, dependent: :destroy
  has_many :dependants, dependent: :destroy
  has_one :ccms_submission, -> { order(created_at: :desc) }, class_name: 'CCMS::Submission', inverse_of: :legal_aid_application, dependent: :destroy
  has_one :vehicle, dependent: :destroy
  has_one :policy_disregards, dependent: :destroy
  has_one :dwp_override, dependent: :destroy
  has_one :bank_transaction_report, -> { where(attachment_type: 'bank_transaction_report') }, class_name: 'Attachment', inverse_of: :legal_aid_application
  has_many :legal_framework_submissions, -> { order(created_at: :asc) }, class_name: 'LegalFramework::Submission', inverse_of: :legal_aid_application, dependent: :destroy
  has_one :legal_framework_merits_task_list, class_name: 'LegalFramework::MeritsTaskList', inverse_of: :legal_aid_application, dependent: :destroy
  has_one :merits_report, -> { where(attachment_type: 'merits_report') }, class_name: 'Attachment', inverse_of: :legal_aid_application
  has_one :means_report, -> { where(attachment_type: 'means_report') }, class_name: 'Attachment', inverse_of: :legal_aid_application
  has_many :cfe_submissions, -> { order(created_at: :asc) }, class_name: 'CFE::Submission', inverse_of: :legal_aid_application, dependent: :destroy
  has_one :most_recent_cfe_submission, -> { order(created_at: :desc) }, class_name: 'CFE::Submission', inverse_of: :legal_aid_application
  has_many :scheduled_mailings, dependent: :destroy
  has_one :state_machine, class_name: 'BaseStateMachine', dependent: :destroy
  has_many :involved_children, class_name: 'ApplicationMeritsTask::InvolvedChild', dependent: :destroy

  before_save :set_open_banking_consent_choice_at
  before_create :create_app_ref
  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.application_created', id: id, state: state
  end

  after_save do
    ActiveSupport::Notifications.instrument 'dashboard.delegated_functions_used' if used_delegated_functions?
    ActiveSupport::Notifications.instrument 'dashboard.declined_open_banking' if saved_change_to_open_banking_consent?
    ActiveSupport::Notifications.instrument('dashboard.provider_updated', provider_id: provider.id) if proc { |laa| laa.state }.eql?(:assessment_submitted)
  end

  attr_reader :proceeding_type_codes

  validate :proceeding_type_codes_existence
  validates :provider, presence: true

  delegate :bank_transactions, to: :applicant, allow_nil: true
  delegate :full_name, to: :applicant, prefix: true, allow_nil: true
  delegate :case_ccms_reference, to: :ccms_submission, allow_nil: true
  delegate :applicant_enter_means!,
           :await_applicant!,
           :check_applicant_details!,
           :check_citizen_answers!,
           :check_merits_answers!,
           :check_non_passported_means!,
           :check_passported_answers!,
           :complete_bank_transaction_analysis!,
           :complete_passported_means!,
           :enter_applicant_details!,
           :provider_confirm_applicant_eligibility!,
           :provider_enter_means!,
           :provider_enter_merits!,
           :provider_used_delegated_functions!,
           :reset!,
           :reset_from_use_ccms!,
           :reset_to_applicant_entering_means!,
           :submitted_assessment!,
           :use_ccms!,
           :applicant_details_checked?,
           :applicant_entering_means?,
           :assessment_submitted?,
           :awaiting_applicant?,
           :checking_applicant_details?,
           :checking_citizen_answers?,
           :checking_merits_answers?,
           :checking_non_passported_means?,
           :checking_passported_answers?,
           :entering_applicant_details?,
           :generating_reports?,
           :may_generate_reports?,
           :provider_assessing_means?,
           :provider_checking_or_checked_citizens_means_answers?,
           :provider_entering_means?,
           :provider_entering_merits?,
           :submitting_assessment?,
           :use_ccms?,
           :summary_state,
           :ccms_reason,
           to: :state_machine_proxy

  scope :latest, -> { order(created_at: :desc) }
  scope :search, ->(term) do
    attributes = [
      'application_ref',
      'concat(applicants.first_name, applicants.last_name)',
      'ccms_submissions.case_ccms_reference'
    ]
    clean_term = term.to_s.downcase.gsub(/[^0-9a-z\\s]/i, '')
    queries = attributes.map do |attribute|
      left_joins(:applicant, :ccms_submission).where("regexp_replace(lower(#{attribute}),'[^[:alnum:]]', '', 'g') like ?", "%#{clean_term}%")
    end
    applications = queries.first
    queries[1..].each { |query| applications = applications.or(query) }
    applications
  end

  scope :submitted_applications, -> { joins(:state_machine).where(state_machine_proxies: { aasm_state: CCMS_SUBMITTED_STATES }).order(created_at: :desc) }

  enum(
    own_home: {
      no: 'no'.freeze,
      mortgage: 'mortgage'.freeze,
      owned_outright: 'owned_outright'.freeze
    },
    _prefix: true
  )

  def lead_proceeding_type
    ProceedingType.find(lead_application_proceeding_type.proceeding_type_id)
  end

  def lead_application_proceeding_type
    application_proceeding_types.find_by(lead_proceeding: true)
  end

  def find_or_create_lead_proceeding_type
    apt = lead_application_proceeding_type
    if apt.nil?
      apt = application_proceeding_types.detect(&:domestic_abuse?)
      apt.update!(lead_proceeding: true)
    end
    apt.proceeding_type
  end

  def application_proceedings_by_name
    types = application_proceeding_types.map do |application_proceeding_type|
      proceeding_type = ProceedingType.find(application_proceeding_type.proceeding_type_id)
      OpenStruct.new({
                       name: proceeding_type.name,
                       meaning: proceeding_type.meaning,
                       application_proceeding_type: application_proceeding_type
                     })
    end

    types.sort_by(&:meaning)
  end

  def section_8_proceedings?
    proceeding_types.any? { |type| type.ccms_matter_code.eql?('KSEC8') }
  end

  def cfe_result
    most_recent_cfe_submission&.result
  end

  def calculation_date
    LegalAidApplications::CalculationDateService.call(self)
  end

  def year_to_calculation_date
    [calculation_date - 1.year + 1.day, calculation_date]
  end

  def capture_policy_disregards?
    (calculation_date || Time.zone.today) >= POLICY_DISREGARDS_START_DATE
  end

  def transactions_total_by_category(category_id)
    bank_trx_total = transactions_total_by_type(:bank, category_id).abs
    cash_trx_total = transactions_total_by_type(:cash, category_id).abs
    cash_trx_total + bank_trx_total
  end

  def applicant_employed?
    applicant&.employed?
  end

  def pre_dwp_check?
    BaseStateMachine::PRE_DWP_STATES.include? state.to_sym
  end

  def income_types?
    transaction_types.credits.any?
  end

  def outgoing_types?
    transaction_types.debits.any?
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
    return if transaction_period_start_on? && transaction_period_finish_on?

    date_to = used_delegated_functions_on || Date.current
    date_from = date_to - 3.months

    update!(
      transaction_period_start_on: date_from,
      transaction_period_finish_on: date_to
    )
  end

  def lowest_prospect_of_success
    min_rank = application_proceeding_types.map(&:chances_of_success).map(&:prospect_of_success_rank).min
    ProceedingMeritsTask::ChancesOfSuccess.rank_and_prettify(min_rank)
  end

  def parent_transaction_types
    ids = transaction_types.map(&:parent_or_self).map(&:id)
    TransactionType.where(id: ids)
  end

  # type is either :credit or :debit
  def uncategorised_transactions?(type)
    bank_trx = bank_transactions_by_type(type)
    cash_trx = cash_transactions_by_type(type)
    parent_transaction_types.__send__("#{type}s").each do |transaction_type|
      uncategorised_transactions_errors(transaction_type) unless any_transactions_selected?(transaction_type, bank_trx, cash_trx)
    end
    errors.present?
  end

  def proceeding_type_codes=(codes)
    @proceeding_type_codes = codes
    self.proceeding_types = ProceedingType.where(code: codes)
  end

  def add_benefit_check_result
    benefit_check_response = BenefitCheckService.call(self)
    return false unless benefit_check_response

    self.benefit_check_result ||= build_benefit_check_result
    benefit_check_result.update!(
      result: benefit_check_response[:benefit_checker_status],
      dwp_ref: benefit_check_response[:confirmation_ref]
    )
  end

  def applicant_receives_benefit?
    return true if dwp_override&.has_evidence_of_benefit?

    benefit_check_result&.positive? || false
  end

  alias passported? applicant_receives_benefit?

  def non_passported?
    !passported?
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

  def shared_ownership=(new_val)
    self[:shared_ownership] = new_val
    self[:percentage_home] = 100.0 if new_val == 'no_sole_owner'
  end

  def own_home?
    own_home.present? && !own_home_no?
  end

  def own_capital?
    own_home? || other_assets? || savings_amount?
  end

  def savings_amount?
    (savings_amount.present? && savings_amount&.values?)
  end

  def offline_savings?
    savings_amount&.offline_savings_accounts.present?
  end

  def offline_savings_value
    savings_amount.offline_savings_accounts
  end

  def online_savings_accounts_balance
    applicant.bank_accounts.savings.sum(&:latest_balance)
  end

  def online_current_accounts_balance
    applicant.bank_accounts.current.sum(&:latest_balance)
  end

  def other_assets?
    other_assets_declaration.present? && other_assets_declaration.positive?
  end

  # Refactored into its own method because there may be multiple conditions in the future
  # which make it read only.
  def read_only?
    checking_citizen_answers? || with_applicant?
  end

  def with_applicant?
    applicant_entering_means? || awaiting_applicant?
  end

  def submitted_to_ccms?
    generating_reports? ||
      submitting_assessment? ||
      assessment_submitted?
  end

  def checking_answers?
    checking_applicant_details? ||
      checking_passported_answers? ||
      checking_merits_answers? ||
      checking_citizen_answers? ||
      checking_non_passported_means?
  end

  def reset_proceeding_types!
    proceeding_types.clear
    application_proceeding_types.map(&:clear_scopes!)
  end

  def receives_student_finance?
    student_finance?
  end

  def value_of_student_finance
    receives_student_finance? ? irregular_incomes.student_finance.order('created_at').last.amount : nil
  end

  def default_cost_limitation
    default_substantive_cost_limitation
  end

  def default_substantive_cost_limitation
    lead_proceeding_type.default_cost_limitation_substantive
  end

  def default_delegated_functions_cost_limitation
    lead_proceeding_type.default_cost_limitation_delegated_functions
  end

  def find_or_create_ccms_submission
    create_ccms_submission! unless ccms_submission
    ccms_submission
  end

  def ccms_submission_date
    association(:ccms_submission).load_target&.created_at
  end

  def state
    state_machine_proxy.aasm_state
  end

  def state_machine_proxy
    if state_machine.nil?
      save!
      create_state_machine(type: 'PassportedStateMachine')
    end
    state_machine
  end

  def change_state_machine_type(state_machine_type)
    save!
    state_machine.update!(type: state_machine_type)
    reload
  end

  def applicant_details_checked!
    state_machine_proxy.applicant_details_checked!(self)
  end

  def generate_reports!
    state_machine_proxy.generate_reports!(self)
  end

  def generated_reports!
    state_machine_proxy.generated_reports!(self)
  end

  def statement_of_case_uploaded?
    attachments.statement_of_case.any?
  end

  def complete_non_passported_means!
    state_machine_proxy.complete_non_passported_means!(self)
  end

  def merits_complete!
    update!(merits_submitted_at: Time.current) unless merits_submitted_at?
    ActiveSupport::Notifications.instrument 'dashboard.application_submitted'
  end

  def summary_state
    return :submitted if merits_submitted_at

    :in_progress
  end

  def policy_disregards?
    policy_disregards&.any? ? true : false
  end

  def transactions_total_by_type(transaction_type, category_id)
    __send__("#{transaction_type}_transactions").amounts.fetch(category_id, 0)
  end

  private

  def bank_transactions_by_type(type)
    bank_transactions.__send__(type).order(happened_at: :desc).by_parent_transaction_type
  end

  def cash_transactions_by_type(type)
    cash_transactions.__send__("#{type}s").order(transaction_date: :desc).by_parent_transaction_type
  end

  def any_transactions_selected?(transaction_type, bank_trx, cash_trx)
    bank_trx[transaction_type].present? || cash_trx[transaction_type].present?
  end

  def applicant_updated_after_benefit_check_result_updated?
    benefit_check_result.updated_at < applicant.updated_at
  end

  def proceeding_type_codes_existence
    return if proceeding_type_codes.blank?

    errors.add(:proceeding_type_codes, :invalid) if proceeding_types.size != proceeding_type_codes.size
  end

  def uncategorised_transactions_errors(transaction_type)
    add_uncategorised_transaction_error(transaction_type)
    transaction_type.children.each { |child| add_uncategorised_transaction_error(child) }
  end

  def add_uncategorised_transaction_error(transaction_type)
    return if transaction_type.name == 'excluded_benefits'

    errors.add(transaction_type.name, I18n.t('activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message'))
  end

  def create_app_ref
    self.application_ref = ReferenceNumberCreator.call if application_ref.blank?
  end

  def set_open_banking_consent_choice_at
    self.open_banking_consent_choice_at = Time.current if will_save_change_to_open_banking_consent?
  end
end
