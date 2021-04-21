require 'rails_helper'

module Reports
  module MIS
    RSpec.describe ApplicationDetailsReport do
      let!(:unsubmitted_applications) { create_list :legal_aid_application, 3, :with_passported_state_machine, :with_proceeding_types }
      let!(:submitted_applications) { create_list :legal_aid_application, 3, :with_passported_state_machine, :at_assessment_submitted, :with_proceeding_types, :with_merits_submitted_at  }
      let!(:applications_being_submitted) { create :legal_aid_application, :with_passported_state_machine, :at_submitting_assessment, :with_proceeding_types, :with_merits_submitted_at }
      let(:report) { described_class.new }

      describe '#run' do
        context 'testing ActiveRecord calls' do
          let(:joined_applications) { double LegalAidApplication }
          let(:selected_applications) { double LegalAidApplication }
          let(:sorted_applications) { double LegalAidApplication }

          it 'gets only applications in assessment submitted or submitting assessment states' do
            expect(LegalAidApplication).to receive(:joins).with(:state_machine).and_return(joined_applications)
            expect(joined_applications).to receive(:where).with({ state_machine_proxies: { aasm_state: %w[submitting_assessment assessment_submitted] } })
                                                          .and_return(selected_applications)
            expect(selected_applications).to receive(:order).with(:created_at).and_return(sorted_applications)
            expect(sorted_applications).to receive(:find_each)

            report.run
          end
        end

        it 'returns a csv string with a header line' do
          csv_string = report.run
          lines = csv_string.split("\n")
          expect(lines.first).to match(/^Firm name,User name,Office ID/)
        end

        it 'returns a header and four detail lines' do
          csv_string = report.run
          lines = csv_string.split("\n")
          expect(lines.size).to eq 5
        end
      end
    end
  end
end
