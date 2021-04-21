require 'rails_helper'

# rubocop:disable Layout/LineLength
module Dashboard
  module WidgetDataProviders
    RSpec.describe Applications do
      describe '.handle' do
        it 'returns the unqualified widget name' do
          expect(described_class.handle).to eq 'applications'
        end
      end

      describe '.dataset_definition' do
        it 'returns hash of field definitions' do
          expected_definition = { fields:
                                    [
                                      { name: 'Date', type: 'date' },
                                      { name: 'Started applications', optional: false, type: 'number' },
                                      { name: 'Submitted applications', optional: false, type: 'number' },
                                      { name: 'Submitted passported applications', optional: false, type: 'number' },
                                      { name: 'Submitted nonpassported applications', optional: false, type: 'number' },
                                      { name: 'Total submitted applications', optional: false, type: 'number' },
                                      { name: 'Failed applications', optional: false, type: 'number' },
                                      { name: 'Delegated function applications', optional: false, type: 'number' }
                                    ], unique_by: ['date'] }.to_json
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe '.data' do
        before { create_apps }
        let(:date) { Date.new(2019, 12, 12) }
        it 'returns the expected data' do
          travel_to(date) do
            expect(described_class.data).to eq expected_data
          end
        end

        def expected_data # rubocop:disable Metrics/MethodLength
          [
            { 'date' => '2019-11-22', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-23', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-24', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-25', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-26', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-27', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-28', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-29', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-11-30', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-01', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-02', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-03', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-04', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-05', 'started_apps' => 0, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-06', 'started_apps' => 3, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-07', 'started_apps' => 2, 'submitted_apps' => 0, 'total_submitted_apps' => 0, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 1, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-08', 'started_apps' => 2, 'submitted_apps' => 1, 'total_submitted_apps' => 1, 'submitted_passported_apps' => 1, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 2 },
            { 'date' => '2019-12-09', 'started_apps' => 1, 'submitted_apps' => 0, 'total_submitted_apps' => 1, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-10', 'started_apps' => 5, 'submitted_apps' => 0, 'total_submitted_apps' => 1, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 0 },
            { 'date' => '2019-12-11', 'started_apps' => 8, 'submitted_apps' => 3, 'total_submitted_apps' => 4, 'submitted_passported_apps' => 2, 'submitted_nonpassported_apps' => 1, 'failed_apps' => 0, 'delegated_func_apps' => 4 },
            { 'date' => '2019-12-12', 'started_apps' => 5, 'submitted_apps' => 0, 'total_submitted_apps' => 4, 'submitted_passported_apps' => 0, 'submitted_nonpassported_apps' => 0, 'failed_apps' => 0, 'delegated_func_apps' => 4 }
          ]
        end

        def expected_apps
          # pattern is days_ago => [created applications, ccms_submission failures, delegated_function applications, submitted passported applications, submitted non_passported applications]
          {
            6 => [3, 0, 0, 0, 0, 0],
            5 => [1, 1, 0, 0, 0, 0],
            4 => [0, 0, 1, 0, 1, 0],
            3 => [1, 0, 0, 0, 0, 0],
            2 => [5, 0, 0, 0, 0, 0],
            1 => [3, 0, 2, 1, 2, 0],
            0 => [1, 0, 0, 0, 0, 2]
          }
        end

        def create_apps
          expected_apps.each do |num_days, num_apps|
            travel_to(date - num_days.days) do
              create_fake_applications(num_apps)
            end
          end
        end

        def create_fake_applications(num_apps)
          FactoryBot.create_list :legal_aid_application, num_apps[0]
          FactoryBot.create_list :ccms_submission, num_apps[1], aasm_state: 'failed'
          FactoryBot.create_list :legal_aid_application, num_apps[2], :with_delegated_functions
          FactoryBot.create_list :legal_aid_application, num_apps[3], :non_passported, merits_submitted_at: Time.zone.today
          FactoryBot.create_list :legal_aid_application, num_apps[4], :passported, :with_delegated_functions, merits_submitted_at: Time.zone.today
          FactoryBot.create_list :legal_aid_application, num_apps[5], :passported, :with_delegated_functions # unsubmitted application
          FactoryBot.create_list :legal_aid_application, num_apps[5], :non_passported, :with_delegated_functions # unsubmitted application
        end
      end
    end
  end
end
# rubocop:enable Layout/LineLength
