module ProceedingMeritsTask
  class ChancesOfSuccess < ApplicationRecord
    belongs_to :application_proceeding_type

    PRETTY_SUCCESS_PROSPECTS = {
      likely: 'Likely (>50%)',
      marginal: 'Marginal (45-49%)',
      poor: 'Poor (<45%)',
      borderline: 'Borderline',
      not_known: 'Uncertain'

    }.freeze

    enum success_prospect: {
      likely: 'likely'.freeze,
      marginal: 'marginal'.freeze,
      poor: 'poor'.freeze,
      borderline: 'borderline'.freeze,
      not_known: 'not_known'.freeze
    }, _prefix: true

    def self.prospects_unlikely_to_succeed
      success_prospects.except(:likely).keys
    end

    def submit!
      update!(submitted_at: Time.current) unless submitted_at?
      ActiveSupport::Notifications.instrument 'dashboard.application_submitted'
    end

    def pretty_success_prospect
      PRETTY_SUCCESS_PROSPECTS[success_prospect.to_sym]
    end

    def statement_of_case_uploaded?
      legal_aid_application.attachments.statement_of_case.any?
    end

    def legal_aid_application
      application_proceeding_type.legal_aid_application
    end
  end
end
