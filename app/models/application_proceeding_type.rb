class ApplicationProceedingType < ApplicationRecord
  FIRST_PROCEEDING_CASE_ID = 55_000_000

  belongs_to :legal_aid_application
  belongs_to :proceeding_type
  has_many :application_proceeding_types_scope_limitations, dependent: :destroy
  has_many :application_proceeding_type_linked_children, class_name: 'ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild', dependent: :destroy

  has_many :involved_children,
           through: :application_proceeding_type_linked_children,
           source: :involved_child

  has_many :assigned_scope_limitations,
           through: :application_proceeding_types_scope_limitations,
           source: :scope_limitation

  has_one :chances_of_success, class_name: 'ProceedingMeritsTask::ChancesOfSuccess', dependent: :destroy

  has_one :substantive_scope_limitation_join, class_name: 'AssignedSubstantiveScopeLimitation', dependent: :destroy

  has_one :substantive_scope_limitation, through: :substantive_scope_limitation_join, source: :scope_limitation

  has_one :delegated_functions_scope_limitation_join, class_name: 'AssignedDfScopeLimitation', dependent: :destroy

  has_one :delegated_functions_scope_limitation, through: :delegated_functions_scope_limitation_join, source: :scope_limitation

  has_one :attempts_to_settle, class_name: 'ProceedingMeritsTask::AttemptsToSettle', dependent: :destroy

  delegate :default_substantive_scope_limitation,
           :default_delegated_functions_scope_limitation,
           :domestic_abuse?,
           to: :proceeding_type

  scope :using_delegated_functions, -> { where.not(used_delegated_functions_on: nil).order(:used_delegated_functions_on) }

  before_save :check_only_one_lead_proceedig

  before_create do
    self.proceeding_case_id = highest_proceeding_case_id + 1 if proceeding_case_id.blank?
  end

  def used_delegated_functions?
    used_delegated_functions_on.present?
  end

  ##############################
  # SCOPE LIMITATIONS
  def add_default_substantive_scope_limitation
    new_scope_limitation = AssignedSubstantiveScopeLimitation.new(scope_limitation: default_substantive_scope_limitation)
    add_scope_limitation_unless_duplicate new_scope_limitation
  end

  def add_default_delegated_functions_scope_limitation
    new_scope_limitation = AssignedDfScopeLimitation.new(scope_limitation: default_delegated_functions_scope_limitation)
    add_scope_limitation_unless_duplicate new_scope_limitation
  end

  def add_scope_limitation_unless_duplicate(new_scope_limitation)
    duplicated = application_proceeding_types_scope_limitations.map(&:scope_limitation_id).include?(new_scope_limitation.scope_limitation_id)
    application_proceeding_types_scope_limitations << new_scope_limitation unless duplicated
  end

  def remove_default_delegated_functions_scope_limitation
    delegated_functions_scope_limitation_join&.destroy!
  end
  ##############################

  def proceeding_case_p_num
    "P_#{proceeding_case_id}"
  end

  def pretty_df_date
    used_delegated_functions_on&.strftime('%F') || 'n/a'
  end

  private

  def check_only_one_lead_proceedig
    return if lead_proceeding == false

    apt = legal_aid_application.application_proceeding_types.detect { |rec| rec.lead_proceeding? && rec.id != id }
    return if apt.nil?

    Sentry.capture_message "Duplicate lead proceedings detected for application #{legal_aid_application.application_ref}: #{id}, #{apt.id}"
  end

  def highest_proceeding_case_id
    rec = self.class.order(proceeding_case_id: :desc).first
    rec.nil? || rec.proceeding_case_id.nil? ? FIRST_PROCEEDING_CASE_ID : rec.proceeding_case_id
  end

end
