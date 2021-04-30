FactoryBot.define do
  factory :legal_framework_serializable_merits_task_list, class: LegalFramework::SerializableMeritsTaskList do
    initialize_with { new(**lfa_response) }

    lfa_response do
      {
        request_id: SecureRandom.uuid,
        application: {
          tasks: {
            latest_incident_details: [],
            opponent_details: []
          }
        },
        proceeding_types: [
          {
            ccms_code: 'DA005',
            tasks: {
              chances_of_success: []
            }
          },
          {
            ccms_code: 'DA001',
            tasks: {
              chances_of_success: [:opponent_details]
            }
          }
        ]
      }
    end
  end
end
